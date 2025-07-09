import 'package:enhud/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enhud/main.dart';

class Notifications {
  static final Notifications _instance = Notifications._internal();
  factory Notifications() => _instance;
  Notifications._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Stream for notification responses
  final StreamController<NotificationResponse> _notificationResponseController =
      StreamController<NotificationResponse>.broadcast();
  Stream<NotificationResponse> get notificationResponseStream =>
      _notificationResponseController.stream;

  // Background notification handler (must be top-level or static)
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    print('Background notification action: ${response.actionId}');
  }

  // Initialization
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Initialize timezone database
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // InitializationSettings for all platforms
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize notifications plugin
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap/action when app is in foreground
        _handleNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create notification channel (Android only)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_channel_id',
      'daily_notification',
      description: 'Daily Notification channel',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  void _handleNotificationResponse(NotificationResponse response) {
    print('Notification action pressed: ${response.actionId}');
    _notificationResponseController.add(response);

    // Handle specific actions
    switch (response.actionId) {
      case '1': // Done action
        print('User pressed Done');
        _markNotificationAsDone(response.payload);
        break;
      case '2':
        print('User pressed Snooze');
        break;
      default:
        print('Notification tapped (no action)');
        break;
    }
  }

  void _markNotificationAsDone(String? payload) {
    if (payload == null) return;

    try {
      // Parse the notification ID from the payload
      int notificationId = int.parse(payload);

      // Extract week, row, and column from the ID
      int column = notificationId % 10;
      int row = (notificationId % 100) ~/ 10;
      int week = notificationId ~/ 100;

      if (!mybox!.isOpen) return;

      var data = mybox!.get('noti');
      if (data is List) {
        // Properly cast each item in the list to Map<String, dynamic>
        List<Map<String, dynamic>> notifications = [];

        for (var item in data) {
          if (item is Map) {
            // Convert each map to Map<String, dynamic>
            notifications.add(Map<String, dynamic>.from(item));
          }
        }

        // Find and update the notification with matching week, row, column
        for (int i = 0; i < notifications.length; i++) {
          if (notifications[i]['week'] == week &&
              notifications[i]['row'] == row &&
              notifications[i]['column'] == column) {
            notifications[i]['done'] = true;
            mybox!.put('noti', notifications);
            notificationItemMap = notifications;
            print(
                'Notification marked as done: week=$week, row=$row, column=$column');
            break;
          }
        }
      }
    } catch (e) {
      print('Error marking notification as done: $e');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'daily_notification',
        channelDescription: 'Daily Notification channel',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        // Notification actions
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            '1',
            'Done',
            titleColor: Colors.green,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            '2',
            'Snooze',
            titleColor: Colors.orange,
            showsUserInterface: true,
          ),
        ],
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int week,
    required int row,
    required int column,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    // Create ID in format: weekrowcolumn (e.g., 123 for week 1, row 2, column 3)
    int id = (week * 100) + (row * 10) + column;

    // Initialize timezone database
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Get the current date and time in local timezone
    final now = tz.TZDateTime.now(tz.local);

    // Map column index to day of week (1-7 where 1 is Monday, 7 is Sunday)
    int targetDayOfWeek;

    // This mapping assumes:
    // Column 0 = Time column (not a day)
    // Column 1 = Saturday
    // Column 2 = Sunday
    // Column 3 = Monday
    // Column 4 = Tuesday
    // Column 5 = Wednesday
    // Column 6 = Thursday
    // Column 7 = Friday
    switch (column) {
      case 1:
        targetDayOfWeek = 6;
        break; // Saturday
      case 2:
        targetDayOfWeek = 7;
        break; // Sunday
      case 3:
        targetDayOfWeek = 1;
        break; // Monday
      case 4:
        targetDayOfWeek = 2;
        break; // Tuesday
      case 5:
        targetDayOfWeek = 3;
        break; // Wednesday
      case 6:
        targetDayOfWeek = 4;
        break; // Thursday
      case 7:
        targetDayOfWeek = 5;
        break; // Friday
      default:
        targetDayOfWeek = column; // Fallback
    }

    // Calculate days to add
    int daysToAdd = 0;

    if (week == 0) {
      // For current week
      if (targetDayOfWeek == now.weekday) {
        // Same day - check time
        if (hour > now.hour || (hour == now.hour && minute > now.minute)) {
          // Later today
          daysToAdd = 0;
        } else {
          // If it's just a few minutes in the past, still schedule for today
          // but add a small buffer (e.g., schedule for 2 minutes from now)
          DateTime scheduledTime =
              DateTime(now.year, now.month, now.day, hour, minute);
          DateTime currentTime = DateTime.now();

          if (currentTime.difference(scheduledTime).inMinutes < 5) {
            // If less than 5 minutes in the past, schedule for a few minutes from now
            hour = now.hour;
            minute = now.minute + 2; // Add 2 minutes buffer
            if (minute >= 60) {
              hour += 1;
              minute -= 60;
            }
            daysToAdd = 0;
          } else {
            // Otherwise schedule for next week
            daysToAdd = 7;
          }
        }
      } else if (targetDayOfWeek > now.weekday) {
        // Later this week
        daysToAdd = targetDayOfWeek - now.weekday;
      } else {
        // Earlier this week (already passed) - schedule for next week
        daysToAdd = 7 + (targetDayOfWeek - now.weekday);
      }
    } else {
      // For future weeks
      if (targetDayOfWeek >= now.weekday) {
        daysToAdd = targetDayOfWeek - now.weekday + (week * 7);
      } else {
        daysToAdd = (targetDayOfWeek - now.weekday + 7) + (week * 7);
      }
    }

    // Create the scheduled date
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysToAdd,
      hour,
      minute,
    );

    // Double-check that the date is in the future
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: id.toString(), // Pass the ID as payload
    );

    print("Notification scheduled for: $scheduledDate with ID: $id");
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationByPosition(
      int week, int row, int column) async {
    int id = (week * 100) + (row * 10) + column;
    await notificationsPlugin.cancel(id);
    print("Cancelled notification with ID: $id");
  }

  void dispose() {
    _notificationResponseController.close();
  }
}
