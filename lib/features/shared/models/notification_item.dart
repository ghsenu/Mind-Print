import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'affirmation' | 'reminder' | 'alert'
  final bool isRead;
  final DateTime createdAt;

  factory NotificationItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return NotificationItem(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      body: data['body'] as String,
      type: data['type'] as String? ?? 'reminder',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
    id: id,
    userId: userId,
    title: title,
    body: body,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
