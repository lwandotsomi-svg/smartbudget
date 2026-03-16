import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/goal.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  /// Schedule 3 daily notifications at 8 AM, 12 PM, and 6 PM
  Future<void> scheduleDailyNotifications(Goal goal) async {
    // Morning notification - 8 AM
    await _scheduleNotificationAtTime(
      id: goal.id.hashCode + 1,
      title: '🎯 Morning Motivation',
      body:
          'Hi! Your goal "${goal.title}" needs ${goal.remainingAmount.toStringAsFixed(2)} more. You can do it! 💪',
      hour: 8,
      minute: 0,
    );

    // Afternoon notification - 12 PM
    await _scheduleNotificationAtTime(
      id: goal.id.hashCode + 2,
      title: '📊 Afternoon Reminder',
      body:
          'You are ${goal.progressPercentage.toStringAsFixed(1)}% towards your goal "${goal.title}". Keep going! 🌟',
      hour: 12,
      minute: 0,
    );

    // Evening notification - 6 PM
    await _scheduleNotificationAtTime(
      id: goal.id.hashCode + 3,
      title: '✨ Evening Check-in',
      body:
          'End your day strong! Add to "${goal.title}" and get closer to your dream! 🚀',
      hour: 18,
      minute: 0,
    );
  }

  /// Schedule a notification for a specific time
  Future<void> _scheduleNotificationAtTime({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'smartbudget_channel',
            'SmartBudget Goals',
            channelDescription: 'Notifications for budget goals',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Calculate next instance of time for recurring daily notification
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel all notifications for a goal
  Future<void> cancelNotifications(String goalId) async {
    await _flutterLocalNotificationsPlugin.cancel(goalId.hashCode + 1);
    await _flutterLocalNotificationsPlugin.cancel(goalId.hashCode + 2);
    await _flutterLocalNotificationsPlugin.cancel(goalId.hashCode + 3);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Send immediate notification (for testing)
  Future<void> sendImmediateNotification({
    required String title,
    required String body,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'smartbudget_channel',
        'SmartBudget Goals',
        channelDescription: 'Notifications for budget goals',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
    );
  }
}
