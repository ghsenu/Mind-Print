import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionResult {
  const EmotionResult({
    required this.id,
    required this.journalId,
    required this.userId,
    required this.primaryEmotion,
    required this.intensity,
    required this.secondaryEmotions,
    required this.sentiment,
    this.distortionType,
    this.aiInsight,
    this.cbtReframe,
    required this.analyzedAt,
  });

  final String id;
  final String journalId;
  final String userId;
  final String
  primaryEmotion; // joy | sadness | anger | fear | surprise | disgust | neutral
  final double intensity; // 0.0–1.0
  final List<String> secondaryEmotions;
  final String sentiment; // positive | negative | neutral
  final String?
  distortionType; // overgeneralization | catastrophizing | black-and-white | personalization | mental-filtering
  final String? aiInsight;
  final String? cbtReframe;
  final DateTime analyzedAt;

  factory EmotionResult.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return EmotionResult(
      id: doc.id,
      journalId: data['journalId'] as String,
      userId: data['userId'] as String,
      primaryEmotion: data['primaryEmotion'] as String,
      intensity: (data['intensity'] as num).toDouble(),
      secondaryEmotions: List<String>.from(
        data['secondaryEmotions'] as List? ?? [],
      ),
      sentiment: data['sentiment'] as String? ?? 'neutral',
      distortionType: data['distortionType'] as String?,
      aiInsight: data['aiInsight'] as String?,
      cbtReframe: data['cbtReframe'] as String?,
      analyzedAt: (data['analyzedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'journalId': journalId,
    'userId': userId,
    'primaryEmotion': primaryEmotion,
    'intensity': intensity,
    'secondaryEmotions': secondaryEmotions,
    'sentiment': sentiment,
    if (distortionType != null) 'distortionType': distortionType,
    if (aiInsight != null) 'aiInsight': aiInsight,
    if (cbtReframe != null) 'cbtReframe': cbtReframe,
    'analyzedAt': Timestamp.fromDate(analyzedAt),
  };
}
