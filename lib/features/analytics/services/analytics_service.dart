import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mind_print/core/database/firestore_database.dart';
import 'package:mind_print/features/shared/models/emotion_result.dart';
import 'package:mind_print/features/shared/models/journal_entry.dart';
import 'package:mind_print/features/shared/models/prediction.dart';

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.totalEntries,
    required this.avgMood,
    required this.bestDay,
    required this.emotionValues,
    required this.emotionLabels,
    required this.distortionCounts,
  });

  final int totalEntries;
  final double avgMood;
  final String bestDay;
  // 5 values in order: joy, sadness, anger, fear, neutral — normalized 0–1
  final List<double> emotionValues;
  final List<String> emotionLabels;
  final Map<String, int> distortionCounts;

  static AnalyticsSummary empty() => const AnalyticsSummary(
    totalEntries: 0,
    avgMood: 0,
    bestDay: '—',
    emotionValues: [0, 0, 0, 0, 0],
    emotionLabels: ['Joy', 'Sadness', 'Anger', 'Fear', 'Neutral'],
    distortionCounts: {},
  );
}

class AnalyticsService {
  AnalyticsService(this._db);

  final FirestoreDatabase _db;

  static const List<String> _radarEmotions = [
    'joy',
    'sadness',
    'anger',
    'fear',
    'neutral',
  ];

  static const List<String> _radarLabels = [
    'Joy',
    'Sadness',
    'Anger',
    'Fear',
    'Neutral',
  ];

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  Future<AnalyticsSummary> getAnalyticsSummary(String userId) async {
    // Fetch last 30 journals
    final journalSnap =
        await _db
            .journals(userId)
            .orderBy('createdAt', descending: true)
            .limit(30)
            .get();

    final journals =
        journalSnap.docs
            .map(
              (d) => JournalEntry.fromFirestore(
                d as DocumentSnapshot<Map<String, dynamic>>,
              ),
            )
            .toList();

    if (journals.isEmpty) return AnalyticsSummary.empty();

    // Total entries and avg mood
    final totalEntries = journals.length;
    final avgMood =
        journals.map((j) => j.moodScore).reduce((a, b) => a + b) / totalEntries;

    // Best day (weekday with highest average mood score)
    final Map<int, List<int>> dayScores = {};
    for (final j in journals) {
      final wd = j.createdAt.weekday; // 1=Mon … 7=Sun
      dayScores.putIfAbsent(wd, () => []).add(j.moodScore);
    }
    int bestWd = 1;
    double bestAvg = 0;
    dayScores.forEach((wd, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestWd = wd;
      }
    });
    final bestDay = _weekdays[bestWd - 1];

    // Fetch emotion results for analyzed journals in parallel (max 20)
    final analyzed = journals.where((j) => j.isAnalyzed).take(20).toList();
    final emotionFutures = analyzed.map(
      (j) =>
          _db
              .journals(userId)
              .doc(j.id)
              .collection('emotionResults')
              .limit(1)
              .get(),
    );
    final emotionSnaps = await Future.wait(emotionFutures);

    final List<EmotionResult> emotions = [];
    for (final snap in emotionSnaps) {
      if (snap.docs.isNotEmpty) {
        emotions.add(
          EmotionResult.fromFirestore(
            snap.docs.first as DocumentSnapshot<Map<String, dynamic>>,
          ),
        );
      }
    }

    // Emotion frequency → radar values (normalized)
    final Map<String, int> emotionCounts = {};
    for (final e in emotions) {
      emotionCounts[e.primaryEmotion] =
          (emotionCounts[e.primaryEmotion] ?? 0) + 1;
    }
    final maxCount =
        emotionCounts.values.isEmpty ? 1 : emotionCounts.values.reduce(max);
    final emotionValues =
        _radarEmotions
            .map(
              (em) => maxCount > 0 ? (emotionCounts[em] ?? 0) / maxCount : 0.0,
            )
            .toList();

    // Distortion counts
    final Map<String, int> distortionCounts = {};
    for (final e in emotions) {
      if (e.distortionType != null) {
        distortionCounts[e.distortionType!] =
            (distortionCounts[e.distortionType!] ?? 0) + 1;
      }
    }

    return AnalyticsSummary(
      totalEntries: totalEntries,
      avgMood: double.parse(avgMood.toStringAsFixed(1)),
      bestDay: bestDay,
      emotionValues: emotionValues,
      emotionLabels: _radarLabels,
      distortionCounts: distortionCounts,
    );
  }

  Future<Prediction> generateAndSavePrediction(
    String userId,
    List<JournalEntry> journals,
  ) async {
    final recent = journals.take(7).toList();
    final count = recent.length;

    double averageMood =
        recent.map((j) => j.moodScore).reduce((a, b) => a + b) / count;

    String trend = 'stable';
    bool alertNeeded = false;

    if (count >= 6) {
      final recentAvg =
          recent.take(3).map((j) => j.moodScore).reduce((a, b) => a + b) / 3;
      final earlyAvg =
          recent
              .skip(count - 3)
              .map((j) => j.moodScore)
              .reduce((a, b) => a + b) /
          3;
      final delta = recentAvg - earlyAvg;
      if (delta > 0.5) {
        trend = 'improving';
      } else if (delta < -0.5) {
        trend = 'declining';
        alertNeeded = true;
      }
    }

    final ref = _db.predictions(userId).doc();
    final prediction = Prediction(
      id: ref.id,
      userId: userId,
      averageMood: double.parse(averageMood.toStringAsFixed(2)),
      trend: trend,
      alertNeeded: alertNeeded,
      generatedAt: DateTime.now(),
    );
    await ref.set(prediction.toFirestore());
    return prediction;
  }

  Future<Prediction?> getLatestPrediction(String userId) async {
    final snap =
        await _db
            .predictions(userId)
            .orderBy('generatedAt', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isEmpty) return null;
    return Prediction.fromFirestore(
      snap.docs.first as DocumentSnapshot<Map<String, dynamic>>,
    );
  }
}
