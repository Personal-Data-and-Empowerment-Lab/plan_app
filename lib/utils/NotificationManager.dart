import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:planv3/models/PlanLine.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  print("here's the payload: $payload");
  // await Navigator.push(
  //   context,
  //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  // );
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page

  print("here's the payload: $payload");
  // TODO: probably send a notification to the editor bloc that this happened
}

class NotificationManager {
  static const MethodChannel platform = MethodChannel('pedel/plan');
  static final DateFormat formatter = DateFormat('yyyy-MM-dd THms');
  static Map<DateTime, List<PlanLine>> latestPendingRequests =
      new Map<DateTime, List<PlanLine>>();
  static bool busy = false;

  static Future<int> scheduleNotification(DateTime date, String text) async {
    TZDateTime dateTime = TZDateTime.from(date, tz.local);
    int id = Random().nextInt(999);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        "From your plan",
        text,
        dateTime,
        //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'plan_scheduled_notification_channel',
                'Plan Scheduled Notification Channel',
                'The scheduled notifications for plan')),
        androidAllowWhileIdle: true,
        payload: dateTime.toIso8601String(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    return id;
  }

  static Future<int> scheduleUsageNotification(DateTime date) async {
    // cancel the last one
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    for (PendingNotificationRequest request in pendingNotificationRequests) {
      if (request.payload == "usage_message") {
        await flutterLocalNotificationsPlugin.cancel(request.id);
      }
    }

    TZDateTime dateTime = TZDateTime.from(date, tz.local);
    int id = Random().nextInt(999);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        "You haven't made a plan in a few days",
        "Tap here to make one when you're ready",
        dateTime,
        //tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'plan_scheduled_notification_channel',
                'Plan Scheduled Notification Channel',
                'The scheduled notifications for plan')),
        androidAllowWhileIdle: true,
        payload: "usage_message",
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    return id;
  }

  /*
  This is a tricky function.
  We have to touch ALL the reminders on every edit unfortunately.
  We have to reset all the ones for the current plan date since we don't know which ones changed
  We have to delete ones that were scheduled in the past too just in case
  Also, since this function is async, we can get many similar copies of a reminder line being added
    concurrently so they won't get deleted appropriately
  Below is my best attempt at addressing each of these issues.
   */
  static void updateNotificationList(
      List<PlanLine> reminderTimes, DateTime currentPlanDate,
      {bool override: false}) async {
    if (NotificationManager.busy && !override) {
      // add to queue and exit
      NotificationManager.latestPendingRequests[currentPlanDate] =
          reminderTimes;
      // print("queued $currentPlanDate");
      return;
    } else {
      NotificationManager.busy = true;
      // print("carrying out $currentPlanDate $override");
      NotificationManager.latestPendingRequests.remove(currentPlanDate);

      // get current requests
      final List<PendingNotificationRequest> pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();

      for (PendingNotificationRequest request in pendingNotificationRequests) {
        // print("${request.payload} | ${request.body}");
        // if this is a usage_message notification, leave it
        if (request.payload != "usage_message") {
          TZDateTime scheduledDateTime =
              TZDateTime.from(DateTime.parse(request.payload), tz.local);

          // if the payload wasn't formatted correctly, delete it
          if (scheduledDateTime == null) {
            await flutterLocalNotificationsPlugin.cancel(request.id);
          }
          // if request's payload is a date before now OR for the current plan day, cancel it
          if (scheduledDateTime.isBefore(DateTime.now()) ||
              (scheduledDateTime.year == currentPlanDate.year &&
                  scheduledDateTime.month == currentPlanDate.month &&
                  scheduledDateTime.day == currentPlanDate.day)) {
            // print("deleting ${request.payload} | ${request.body}");
            await flutterLocalNotificationsPlugin.cancel(request.id);
          } else {
            // print("not deleting ${request.payload} | ${request.body}");
          }
        }
      }

      // flutterLocalNotificationsPlugin.cancelAll();
      for (PlanLine reminderTime in reminderTimes) {
        // set reminderTime date to match currentPlanDate
        reminderTime.startTime = new DateTime(
            currentPlanDate.year,
            currentPlanDate.month,
            currentPlanDate.day,
            reminderTime.startTime.hour,
            reminderTime.startTime.minute);
        // print("adding: ${reminderTime.startTime} | ${reminderTime.rawText}");
        scheduleNotification(reminderTime.startTime, reminderTime.rawText);
      }

      // print("finished $currentPlanDate $override");
      // if any have come in while we were doing this one, get started on the pending ones
      if (NotificationManager.latestPendingRequests.isNotEmpty) {
        DateTime nextPlanDate =
            NotificationManager.latestPendingRequests.keys.first;

        NotificationManager.updateNotificationList(
            NotificationManager.latestPendingRequests[nextPlanDate],
            nextPlanDate,
            override: true);
      }
      // if we're all caught up
      else {
        NotificationManager.busy = false;
      }

      // final List<PendingNotificationRequest> currentRequests =
      //   await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      // print("REQUESTS");
      // for (PendingNotificationRequest request in currentRequests) {
      //   print("${request.payload} | ${request.body}");
      // }
      // print("END REQUESTS");
    }
  }

  static void initializeNotifications() async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_plan');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification,
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    // final MacOSInitializationSettings initializationSettingsMacOS =
    // MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      // macOS: initializationSettingsMacOS
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }
}
