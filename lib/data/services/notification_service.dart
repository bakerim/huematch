import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:easy_localization/easy_localization.dart'; // 🔥 DİL MOTORU EKLENDİ

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'huematch_channel',
        'HueMatch',
        channelDescription: 'Game rewards and reminders',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF673AB7),
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> scheduleDailySpinNotification() async {
    await _notificationsPlugin.zonedSchedule(
      1,
      'daily_spin_notif_title'.tr(), // 🔥 DİNAMİK YAZI
      'daily_spin_notif_body'.tr(), // 🔥 DİNAMİK YAZI
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleRetentionNotification() async {
    await cancelNotification(2);

    await _notificationsPlugin.zonedSchedule(
      2,
      'retention_notif_title'.tr(), // 🔥 DİNAMİK YAZI
      'retention_notif_body'.tr(), // 🔥 DİNAMİK YAZI
      tz.TZDateTime.now(tz.local).add(const Duration(days: 2)),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}