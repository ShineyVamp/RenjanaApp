import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Layanan notifikasi lokal untuk pengingat harian retensi & gamifikasi.
class LayananNotifikasi {
  static final LayananNotifikasi _instance = LayananNotifikasi._internal();
  factory LayananNotifikasi() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _terinisialisasi = false;

  static const String _kunciPengingatAktif = 'pengingat_harian_aktif';
  static const int idPengingatHarian = 101;

  LayananNotifikasi._internal();

  Future<void> inisialisasi() async {
    if (_terinisialisasi) return;

    tz.initializeTimeZones();
    // Default WIB (UTC+7) / Asia/Jakarta
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _plugin.initialize(initSettings);
      _terinisialisasi = true;

      final aktif = await isPengingatAktif();
      if (aktif) {
        await jadwalkanPengingatHarian();
      }
    } catch (_) {}
  }

  Future<bool> isPengingatAktif() async {
    try {
      final pref = await SharedPreferences.getInstance();
      return pref.getBool(_kunciPengingatAktif) ?? true; // Default aktif
    } catch (_) {
      return true;
    }
  }

  Future<void> setPengingatAktif(bool aktif) async {
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setBool(_kunciPengingatAktif, aktif);

      if (aktif) {
        await jadwalkanPengingatHarian();
      } else {
        await batalkanPengingat();
      }
    } catch (_) {}
  }

  Future<void> jadwalkanPengingatHarian({
    int jam = 19,
    int menit = 0,
  }) async {
    try {
      await _plugin.cancel(idPengingatHarian);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        jam,
        menit,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'renjana_harian',
        'Pengingat Harian Renjana',
        channelDescription: 'Pengingat membaca arsip budaya dan menjaga runtun harian',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        idPengingatHarian,
        'Renjana Nusantara',
        'Sudah jelajahi budaya hari ini? Mari luangkan sejenak untuk menjaga runtun harian Anda!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> batalkanPengingat() async {
    try {
      await _plugin.cancel(idPengingatHarian);
    } catch (_) {}
  }

  Future<void> tampilkanNotifikasiLangsung({
    required String judul,
    required String pesan,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'renjana_info',
        'Informasi Renjana',
        channelDescription: 'Notifikasi pencapaian dan aktivitas Renjana',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(
        DateTime.now().millisecond,
        judul,
        pesan,
        details,
      );
    } catch (_) {}
  }
}
