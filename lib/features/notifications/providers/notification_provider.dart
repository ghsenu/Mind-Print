import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/notifications/services/notification_service.dart';
import 'package:mind_print/features/shared/models/notification_item.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FirebaseFirestore.instance);
});

final notificationListProvider = StreamProvider<List<NotificationItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs
                .map((doc) => NotificationItem.fromFirestore(doc))
                .toList(),
      );
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
