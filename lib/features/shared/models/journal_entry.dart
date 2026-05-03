import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.moodScore,
    required this.entryType,
    this.voiceUrl,
    this.isAnalyzed = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String content;
  final int moodScore;    // 1–5
  final String entryType; // 'text' | 'voice'
  final String? voiceUrl;
  final bool isAnalyzed;
  final DateTime createdAt;

  factory JournalEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] as String,
      content: data['content'] as String? ?? '',
      moodScore: data['moodScore'] as int? ?? 3,
      entryType: data['entryType'] as String? ?? 'text',
      voiceUrl: data['voiceUrl'] as String?,
      isAnalyzed: data['isAnalyzed'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'content': content,
        'moodScore': moodScore,
        'entryType': entryType,
        if (voiceUrl != null) 'voiceUrl': voiceUrl,
        'isAnalyzed': isAnalyzed,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
