import 'package:cloud_firestore/cloud_firestore.dart';

class MoodCheckin {
  const MoodCheckin({
    required this.id,
    required this.userId,
    required this.score,
    required this.label,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final int score; // 1–5
  final String label; // 'Stressed' | 'Sad' | 'Neutral' | 'Happy' | 'Overjoy'
  final DateTime createdAt;

  factory MoodCheckin.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MoodCheckin(
      id: doc.id,
      userId: data['userId'] as String,
      score: data['score'] as int,
      label: data['label'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'score': score,
    'label': label,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
