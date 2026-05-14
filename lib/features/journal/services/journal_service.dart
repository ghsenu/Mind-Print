import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/shared/models/emotion_result.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';

import 'hugging_face_service.dart';
import '../../shared/services/rate_limiter_service.dart';
import '../../shared/services/local_storage_service.dart';
import '../../notifications/services/notification_service.dart';

class _GeminiAnalysis {
  _GeminiAnalysis({
    required this.primaryEmotion,
    required this.intensity,
    required this.secondaryEmotions,
    required this.sentiment,
    required this.distortionType,
    required this.aiInsight,
    required this.cbtReframe,
  });

  final String primaryEmotion;
  final double intensity;
  final List<String> secondaryEmotions;
  final String sentiment;
  final String? distortionType;
  final String aiInsight;
  final String? cbtReframe;
}

class JournalService {
  JournalService(
    this._db,
    this._hf,
    this._geminiApiKey,
    this._rateLimiter,
    this._localStorage,
    this._notifications,
  );

  final FirestoreDatabase _db;
  final HuggingFaceService _hf;
  final String _geminiApiKey;
  final RateLimiterService _rateLimiter;
  final LocalStorageService _localStorage;
  final NotificationService _notifications;

  static const Map<String, String> _emotionInsights = {
    'joy':
        'Your entry reflects a positive emotional state. Notice what contributed to these good feelings — they are worth remembering.',
    'sadness':
        'Your entry shows signs of sadness. Acknowledging difficult emotions is the first step toward processing them.',
    'anger':
        'Your entry reflects frustration or anger. These feelings are valid. Consider what boundary or expectation may have been crossed.',
    'fear':
        'Your entry shows signs of anxiety or fear. Naming what you are afraid of can help reduce its hold over you.',
    'surprise':
        'Your entry reflects unexpected events or reactions. Take a moment to process what surprised you and how you would like to respond.',
    'disgust':
        'Your entry shows strong aversion or discomfort. This can signal that a personal value or boundary has been challenged.',
    'neutral':
        'Your entry has a balanced emotional tone. This kind of grounded reflection can help clarify your thoughts over time.',
  };

  static const Map<String, String> _distortionReframes = {
    'overgeneralization':
        'One event does not define a pattern. What evidence exists that this is not always true?',
    'catastrophizing':
        'What is the most realistic outcome here? Worst-case scenarios are often far less likely than they feel in the moment.',
    'black-and-white thinking':
        'Where is the middle ground? Most situations have shades of grey worth exploring.',
    'personalization':
        'How much of this was truly within your control? Others actions reflect their own choices, not your worth.',
    'mental filtering':
        'What positives might you be overlooking? Try to take in the full picture before drawing conclusions.',
  };

  Future<_GeminiAnalysis?> _analyzeWithGemini(String text) async {
    try {
      // Check rate limit before calling Gemini
      final isAllowed = await _rateLimiter.isAllowed('gemini');
      if (!isAllowed) {
        debugPrint('[JournalService] Gemini rate limit exceeded');
        return null;
      }

      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _geminiApiKey,
      );

      const prompt =
          '''You are a compassionate mental wellness AI analyzing a journal entry from a university student.

Return ONLY a raw JSON object — no markdown, no explanation, no code fences.

Required fields:
- "primaryEmotion": one of "joy", "sadness", "anger", "fear", "surprise", "disgust", "neutral"
- "intensity": number 0.0–1.0 for how strongly the emotion is expressed
- "secondaryEmotions": array of 0–3 emotion strings from the same list
- "sentiment": one of "positive", "negative", "neutral"
- "distortionType": one of "overgeneralization", "catastrophizing", "black-and-white thinking", "personalization", "mental filtering", or null
- "aiInsight": 2–3 sentence personalized insight referencing specific themes from this entry
- "cbtReframe": 1–2 sentence CBT reframe for this entry, or null if no distortion detected

Journal entry:''';

      final response = await model.generateContent([
        Content.text('$prompt\n"""\n$text\n"""'),
      ]);

      final raw = response.text?.trim();
      if (raw == null || raw.isEmpty) return null;

      var jsonStr = raw;
      if (jsonStr.startsWith('```')) {
        jsonStr =
            jsonStr
                .replaceAll(RegExp(r'```json?\s*'), '')
                .replaceAll('```', '')
                .trim();
      }

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _GeminiAnalysis(
        primaryEmotion: decoded['primaryEmotion'] as String? ?? 'neutral',
        intensity: (decoded['intensity'] as num?)?.toDouble() ?? 0.5,
        secondaryEmotions: List<String>.from(
          decoded['secondaryEmotions'] as List? ?? [],
        ),
        sentiment: decoded['sentiment'] as String? ?? 'neutral',
        distortionType: decoded['distortionType'] as String?,
        aiInsight:
            decoded['aiInsight'] as String? ?? _emotionInsights['neutral']!,
        cbtReframe: decoded['cbtReframe'] as String?,
      );
    } catch (e) {
      debugPrint('[JournalService] Gemini analysis failed: $e');
      return null;
    }
  }

  Stream<List<JournalEntry>> watchJournals(String userId) async* {
    // 1. Yield cached data immediately for instant load
    final cached = await _localStorage.getCachedJournalEntries(userId);
    if (cached.isNotEmpty) {
      yield cached;
    }

    // 2. Listen to Firestore and update cache
    yield* _db
        .journals(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final entries =
          snap.docs
              .map(
                (d) => JournalEntry.fromFirestore(
                  d as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();

      // Update local cache in background
      _localStorage.saveJournalEntries(entries);

      return entries;
    });
  }

  Future<EmotionResult> analyzeAndSave(
    String userId,
    String content,
    int moodScore,
  ) async {
    final journalRef = _db.journals(userId).doc();
    final journalId = journalRef.id;

    final entry = JournalEntry(
      id: journalId,
      userId: userId,
      content: content,
      moodScore: moodScore,
      entryType: 'text',
      createdAt: DateTime.now(),
    );
    await journalRef.set(entry.toFirestore());
    await _localStorage.saveJournalEntries([entry]);

    final (
      primaryEmotion,
      intensity,
      secondaryEmotions,
      sentiment,
      distortionType,
      insight,
      reframe,
    ) = await _runAnalysis(content);

    final resultRef =
        _db.journals(userId).doc(journalId).collection('emotionResults').doc();

    final result = EmotionResult(
      id: resultRef.id,
      journalId: journalId,
      userId: userId,
      primaryEmotion: primaryEmotion,
      intensity: intensity,
      secondaryEmotions: secondaryEmotions,
      sentiment: sentiment,
      distortionType: distortionType,
      aiInsight: insight,
      cbtReframe: reframe,
      analyzedAt: DateTime.now(),
    );

    await resultRef.set(result.toFirestore());
    await journalRef.update({'isAnalyzed': true});

    // Send notification
    await _notifications.createNotification(
      userId: userId,
      title: 'Analysis Complete',
      body: 'Your entry has been analyzed. You felt $primaryEmotion.',
      type: 'analysis',
    );

    return result;
  }

  Future<EmotionResult> analyzeVoiceEntry(
    String userId,
    String transcript,
    int moodScore, {
    String? voiceUrl,
  }) async {
    final journalRef = _db.journals(userId).doc();
    final journalId = journalRef.id;

    final entry = JournalEntry(
      id: journalId,
      userId: userId,
      content: transcript,
      moodScore: moodScore,
      entryType: 'voice',
      voiceUrl: voiceUrl,
      createdAt: DateTime.now(),
    );
    await journalRef.set(entry.toFirestore());
    await _localStorage.saveJournalEntries([entry]);

    final (
      primaryEmotion,
      intensity,
      secondaryEmotions,
      sentiment,
      distortionType,
      insight,
      reframe,
    ) = await _runAnalysis(transcript);

    final resultRef =
        _db.journals(userId).doc(journalId).collection('emotionResults').doc();

    final result = EmotionResult(
      id: resultRef.id,
      journalId: journalId,
      userId: userId,
      primaryEmotion: primaryEmotion,
      intensity: intensity,
      secondaryEmotions: secondaryEmotions,
      sentiment: sentiment,
      distortionType: distortionType,
      aiInsight: insight,
      cbtReframe: reframe,
      analyzedAt: DateTime.now(),
    );

    await resultRef.set(result.toFirestore());
    await journalRef.update({'isAnalyzed': true});

    // Send notification
    await _notifications.createNotification(
      userId: userId,
      title: 'Voice Entry Analyzed',
      body: 'Your recording has been processed. You felt $primaryEmotion.',
      type: 'analysis',
    );
    return result;
  }

  Future<
    (
      String primaryEmotion,
      double intensity,
      List<String> secondaryEmotions,
      String sentiment,
      String? distortionType,
      String insight,
      String? reframe,
    )
  >
  _runAnalysis(String text) async {
    // Try Gemini first — personalized, reliable, no cold-start issues.
    final gemini = await _analyzeWithGemini(text);
    if (gemini != null) {
      return (
        gemini.primaryEmotion,
        gemini.intensity,
        gemini.secondaryEmotions,
        gemini.sentiment,
        gemini.distortionType,
        gemini.aiInsight,
        gemini.cbtReframe,
      );
    }

    // Fall back to HuggingFace with static insight lookup.
    final hf = await _hf.analyze(text);
    final insight =
        _emotionInsights[hf.primaryEmotion] ?? _emotionInsights['neutral']!;
    final reframe =
        hf.distortionType != null
            ? _distortionReframes[hf.distortionType]
            : null;
    return (
      hf.primaryEmotion,
      hf.intensity,
      hf.secondaryEmotions,
      hf.sentiment,
      hf.distortionType,
      insight,
      reframe,
    );
  }

  Future<void> deleteEntry(String userId, String journalId) {
    return _db.journals(userId).doc(journalId).delete();
  }

  Future<EmotionResult?> getEmotionResult(
    String userId,
    String journalId,
  ) async {
    final snap =
        await _db
            .journals(userId)
            .doc(journalId)
            .collection('emotionResults')
            .orderBy('analyzedAt', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return EmotionResult.fromFirestore(
      snap.docs.first as DocumentSnapshot<Map<String, dynamic>>,
    );
  }
}
