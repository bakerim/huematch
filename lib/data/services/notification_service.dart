import 'package:flutter/material.dart'; // İŞTE EKSİK OLAN HAYAT KURTARICI SATIR!
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); // Saat dilimlerini başlat (Zamanlamalar için kritik)

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS için izinleri başta istemiyoruz, oyuncuyu darlamıyoruz. Yeri gelince isteyeceğiz.
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

  // --- BİLDİRİM KANALI AYARLARI (Android'de şık görünmesi için) ---
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'huematch_channel',
        'HueMatch Bildirimleri',
        channelDescription: 'Oyun içi ödüller ve hatırlatmalar',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF673AB7), // Artık motor bu rengi tanıyor!
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // 🔥 1. PUSU: ŞANSLI KART (ÇARK) BİLDİRİMİ (Tam 24 saat sonra)
  Future<void> scheduleDailySpinNotification() async {
    await _notificationsPlugin.zonedSchedule(
      1, // Bildirim ID'si (1 = Çark)
      '🎁 Şanslı Kartın Hazır!',
      'Ücretsiz altınlarını toplama vakti geldi. Hemen çevir!',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)), // 24 saat sonrası
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 🔥 2. PUSU: RETENTION (Oyuncu 2 gün girmezse tetiklenir)
  Future<void> scheduleRetentionNotification() async {
    // Önce eski retention bildirimini iptal et (Oyuncu girdiyse spam yapma)
    await cancelNotification(2);

    await _notificationsPlugin.zonedSchedule(
      2, // Bildirim ID'si (2 = Retention)
      '🚀 HueMatch Seni Özledi!',
      'Odaklan, Eşleştir, Temizle! Kaldığın bölüm seni bekliyor.',
      tz.TZDateTime.now(tz.local).add(const Duration(days: 2)), // 2 Gün Sonrası
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // İptal Motoru
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}