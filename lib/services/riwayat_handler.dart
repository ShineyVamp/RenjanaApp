import 'package:shared_preferences/shared_preferences.dart';

// Riwayat lokal untuk halaman Jelajah: kata kunci yang pernah dicari dan
// arsip yang pernah dibuka. Keduanya hanya disimpan di perangkat.
class RiwayatHandler {
  RiwayatHandler._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyPencarian = 'riwayatPencarian';
  static const _keyDibuka = 'riwayatDibuka';

  static const int batasPencarian = 8;
  static const int batasDibuka = 6;

  // section riwayat pencarian

  static List<String> get pencarian =>
      _prefs.getStringList(_keyPencarian) ?? const [];

  static Future<void> catatPencarian(String kataKunci) async {
    final bersih = kataKunci.trim();
    if (bersih.isEmpty) return;

    final daftar = List<String>.from(pencarian)
      ..removeWhere((k) => k.toLowerCase() == bersih.toLowerCase())
      ..insert(0, bersih);

    if (daftar.length > batasPencarian) {
      daftar.removeRange(batasPencarian, daftar.length);
    }
    await _prefs.setStringList(_keyPencarian, daftar);
  }

  static Future<void> hapusPencarian() async {
    await _prefs.remove(_keyPencarian);
  }

  // section arsip yang dibuka
  // Disimpan sebagai 'jenis|kodeTag', mis. 'budaya|BUD-RMH-1-D'.

  static List<String> get dibuka =>
      _prefs.getStringList(_keyDibuka) ?? const [];

  static Future<void> catatDibuka(String jenis, String kodeTag) async {
    final ref = '$jenis|${kodeTag.trim()}';
    if (kodeTag.trim().isEmpty) return;

    final daftar = List<String>.from(dibuka)
      ..remove(ref)
      ..insert(0, ref);

    if (daftar.length > batasDibuka) {
      daftar.removeRange(batasDibuka, daftar.length);
    }
    await _prefs.setStringList(_keyDibuka, daftar);
  }

  static Future<void> hapusDibuka() async {
    await _prefs.remove(_keyDibuka);
  }
}
