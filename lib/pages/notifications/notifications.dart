import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:async';

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
      case '1':
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
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    int id = (week * 100) + (row * 10) + column;

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    print("Notification scheduled for: $scheduledDate");
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  void dispose() {
    _notificationResponseController.close();
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
        print('$week $row $column');
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
}
