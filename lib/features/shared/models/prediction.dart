import 'package:cloud_firestore/cloud_firestore.dart';

class Prediction {
  const Prediction({
    required this.id,
    required this.userId,
    required this.averageMood,
    required this.trend,
    required this.alertNeeded,
    required this.generatedAt,
  });

  final String id;
  final String userId;
  final double averageMood; // 1.0–5.0
  final String trend;        // 'improving' | 'stable' | 'declining'
  final bool alertNeeded;
  final DateTime generatedAt;

  factory Prediction.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Prediction(
      id: doc.id,
      userId: data['userId'] as String,
      averageMood: (data['averageMood'] as num).toDouble(),
      trend: data['trend'] as String? ?? 'stable',
      alertNeeded: data['alertNeeded'] as bool? ?? false,
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'averageMood': averageMood,
        'trend': trend,
        'alertNeeded': alertNeeded,
        'generatedAt': Timestamp.fromDate(generatedAt),
      };
}
