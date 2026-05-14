import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/shared/models/emotion_result.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';

import 'hugging_face_service.dart';

class JournalService {
  JournalService(this._db, this._hf);

  final FirestoreDatabase _db;
  final HuggingFaceService _hf;

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

  Stream<List<JournalEntry>> watchJournals(String userId) {
    return _db
        .journals(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map(
                    (d) => JournalEntry.fromFirestore(
                      d as DocumentSnapshot<Map<String, dynamic>>,
                    ),
                  )
                  .toList(),
        );
  }

  Future<EmotionResult> analyzeAndSave(
    String userId,
    String content,
    int moodScore,
  ) async {
    // Auto-generate Firestore IDs before writing.
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

    // Fire all three HuggingFace calls in parallel.
    final analysis = await _hf.analyze(content);

    final insight =
        _emotionInsights[analysis.primaryEmotion] ??
        _emotionInsights['neutral']!;
    final reframe =
        analysis.distortionType != null
            ? _distortionReframes[analysis.distortionType]
            : null;

    final resultRef =
        _db.journals(userId).doc(journalId).collection('emotionResults').doc();

    final result = EmotionResult(
      id: resultRef.id,
      journalId: journalId,
      userId: userId,
      primaryEmotion: analysis.primaryEmotion,
      intensity: analysis.intensity,
      secondaryEmotions: analysis.secondaryEmotions,
      sentiment: analysis.sentiment,
      distortionType: analysis.distortionType,
      aiInsight: insight,
      cbtReframe: reframe,
      analyzedAt: DateTime.now(),
    );

    await resultRef.set(result.toFirestore());
    await journalRef.update({'isAnalyzed': true});

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

    final analysis = await _hf.analyze(transcript);
    final insight =
        _emotionInsights[analysis.primaryEmotion] ??
        _emotionInsights['neutral']!;
    final reframe =
        analysis.distortionType != null
            ? _distortionReframes[analysis.distortionType]
            : null;

    final resultRef =
        _db.journals(userId).doc(journalId).collection('emotionResults').doc();

    final result = EmotionResult(
      id: resultRef.id,
      journalId: journalId,
      userId: userId,
      primaryEmotion: analysis.primaryEmotion,
      intensity: analysis.intensity,
      secondaryEmotions: analysis.secondaryEmotions,
      sentiment: analysis.sentiment,
      distortionType: analysis.distortionType,
      aiInsight: insight,
      cbtReframe: reframe,
      analyzedAt: DateTime.now(),
    );

    await resultRef.set(result.toFirestore());
    await journalRef.update({'isAnalyzed': true});
    return result;
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
