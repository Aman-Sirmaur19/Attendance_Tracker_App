import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';
import '../models/attendance.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required int minutesBefore,
  }) async {
    final notificationId = scheduledTime.hashCode;
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
      priority: Priority.high,
    ));
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local)
          .subtract(Duration(minutes: minutesBefore)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> setNotificationsForAttendance(
      Attendance attendance) async {
    final minutesBefore = prefs.getInt('NotificationOffsetMinutes') ?? 60;
    for (var entry in attendance.schedules.entries) {
      final day = entry.key; // e.g., "Monday"
      final timeString = entry.value; // e.g., "10:30 AM"

      if (timeString != null) {
        final DateTime now = DateTime.now();

        // Parse the timeString into hour and minute, adjusting for AM/PM
        final timeParts = timeString.split(" ");
        final hourMinute = timeParts[0].split(":");
        int hour = int.parse(hourMinute[0]);
        final int minute = int.parse(hourMinute[1]);
        final isPM = timeParts[1].toUpperCase() == 'PM';

        // Convert to 24-hour format if necessary
        if (isPM && hour != 12) {
          hour += 12; // PM hours except 12 PM
        } else if (!isPM && hour == 12) {
          hour = 0; // Midnight
        }

        DateTime scheduleTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // Adjust the date to the next occurrence of the day
        while (scheduleTime.weekday != _weekdayFromName(day)) {
          scheduleTime = scheduleTime.add(const Duration(days: 1));
        }

        int total = attendance.present + attendance.absent;
        double miss =
            (100.0 * attendance.present) - (attendance.requirement * total);
        miss /= attendance.requirement;

        String missClass = miss.toStringAsFixed(0);
        String title = miss >= 2
            ? 'You can miss $missClass ${attendance.subject} classes'
            : miss >= 1
                ? 'You can miss $missClass ${attendance.subject} class'
                : 'Don\'t forget to attend ${attendance.subject} class';
        String body =
            'You have ${attendance.subject} class in ${minutesBefore == 60 ? '1 hour.' : minutesBefore > 60 ? '${(minutesBefore / 60).toInt()} hours.' : '$minutesBefore minutes.'}';
        await NotificationService.scheduleNotification(
          title: title,
          body: body,
          scheduledTime: scheduleTime,
          minutesBefore: minutesBefore,
        );
      }
    }
  }

  static int _weekdayFromName(String dayName) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days.indexOf(dayName) + 1;
  }
}
