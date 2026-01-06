import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static const String _healthReminderKey = 'health_reminder_enabled';
  static const String _weeklyReminderKey = 'weekly_reminder_enabled';
  static const String _healthReminderTimeKey = 'health_reminder_time';
  
  // Notification IDs
  static const int healthReminderId = 1;
  static const int weeklyReminderId = 2;

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // Health Check Reminder (Daily)
  Future<void> scheduleHealthReminder({int hour = 9, int minute = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_healthReminderKey, true);
    await prefs.setString(_healthReminderTimeKey, '$hour:$minute');
    
    await _notifications.zonedSchedule(
      healthReminderId,
      '🩺 Health Check Reminder',
      'Time to check your health metrics! Stay on top of your diabetes management.',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_reminder',
          'Health Reminders',
          channelDescription: 'Daily health check reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'health_check',
    );
  }

  // Weekly Progress Reminder (Every Sunday)
  Future<void> scheduleWeeklyReminder({int hour = 10, int minute = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyReminderKey, true);
    
    await _notifications.zonedSchedule(
      weeklyReminderId,
      '📊 Weekly Progress Check',
      'Review your health progress this week and plan for better diabetes management!',
      _nextInstanceOfWeekday(DateTime.sunday, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_reminder',
          'Weekly Reminders',
          channelDescription: 'Weekly progress reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'weekly_progress',
    );
  }

  Future<void> cancelHealthReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_healthReminderKey, false);
    await _notifications.cancel(healthReminderId);
  }

  Future<void> cancelWeeklyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyReminderKey, false);
    await _notifications.cancel(weeklyReminderId);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Get settings
  Future<bool> isHealthReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_healthReminderKey) ?? false;
  }

  Future<bool> isWeeklyReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklyReminderKey) ?? false;
  }

  Future<TimeOfDay> getHealthReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_healthReminderTimeKey) ?? '9:0';
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Helper to get next occurrence of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Helper to get next occurrence of a specific weekday
  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    var scheduledDate = _nextInstanceOfTime(hour, minute);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Send immediate test notification
  Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      '🎉 Notifications Enabled!',
      'You will now receive health reminders from DiabCheck.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Test notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
