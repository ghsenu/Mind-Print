import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mind_print/features/shared/models/notification_item.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore;

  NotificationService(this._firestore);

  Future<void> initialize() async {
    // 1. Request permissions for FCM
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize local notifications
    tz.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings);

    // 3. Request permissions for local notifications (Android 13+)
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // 4. Setup FCM foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(
          title: message.notification!.title,
          body: message.notification!.body,
        );
      }
    });

    // 5. Schedule daily local notifications
    await _scheduleDailyNotifications();
  }

  Future<String?> getFcmToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> saveTokenToUserProfile(String userId) async {
    final token = await getFcmToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    // Listen for token refreshes
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _firestore.collection('users').doc(userId).set({
        'fcmToken': newToken,
      }, SetOptions(merge: true));
    });
  }

  Future<void> _showLocalNotification({String? title, String? body}) async {
    const androidDetails = AndroidNotificationDetails(
      'mind_print_channel',
      'MindPrint Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }

  Future<void> _scheduleDailyNotifications() async {
    await _localNotifications.cancelAll(); // Reset previous schedules

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 8 AM Affirmation
    await _localNotifications.zonedSchedule(
      1,
      'Morning Affirmation',
      'Take a deep breath and have a great day ahead!',
      _nextInstanceOfTime(8, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // 7 PM Journal Reminder
    await _localNotifications.zonedSchedule(
      2,
      'Evening Reflection',
      'How was your day? Take a moment to log your journal.',
      _nextInstanceOfTime(19, 0),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
      '✅ Local notifications scheduled: 8 AM & 7 PM (repeating daily)',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    final notification = NotificationItem(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toFirestore());
  }
}
