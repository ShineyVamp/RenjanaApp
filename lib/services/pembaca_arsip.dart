import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

enum StatusPembaca { diam, membaca, jeda }

// Layanan pembaca teks suara (Text-to-Speech) untuk membacakan isi arsip.
class PembacaArsip {
  static final PembacaArsip _instance = PembacaArsip._internal();
  factory PembacaArsip() => _instance;

  final FlutterTts _tts = FlutterTts();

  StatusPembaca _status = StatusPembaca.diam;
  String _teksAktif = '';
  double _kecepatan = 0.5; // default rate pada flutter_tts (0.0 s.d 1.0)
  void Function(StatusPembaca)? onStatusBerubah;
  void Function(int start, int end, String word)? onKata;

  StatusPembaca get status => _status;
  bool get sedangMembaca => _status == StatusPembaca.membaca;
  bool get sedangJeda => _status == StatusPembaca.jeda;
  bool get aktif => _status != StatusPembaca.diam;
  double get kecepatan => _kecepatan;

  PembacaArsip._internal() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(_kecepatan);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _status = StatusPembaca.membaca;
        onStatusBerubah?.call(_status);
      });

      _tts.setCompletionHandler(() {
        _status = StatusPembaca.diam;
        _teksAktif = '';
        onStatusBerubah?.call(_status);
      });

      _tts.setPauseHandler(() {
        _status = StatusPembaca.jeda;
        onStatusBerubah?.call(_status);
      });

      _tts.setContinueHandler(() {
        _status = StatusPembaca.membaca;
        onStatusBerubah?.call(_status);
      });

      _tts.setCancelHandler(() {
        _status = StatusPembaca.diam;
        _teksAktif = '';
        onStatusBerubah?.call(_status);
      });

      _tts.setErrorHandler((msg) {
        _status = StatusPembaca.diam;
        _teksAktif = '';
        onStatusBerubah?.call(_status);
      });

      _tts.setProgressHandler((text, start, end, word) {
        onKata?.call(start, end, word);
      });
    } catch (_) {}
  }

  Future<void> setKecepatan(double speed) async {
    _kecepatan = speed;
    try {
      await _tts.setSpeechRate(speed);
    } catch (_) {}
  }

  // Mulai membacakan teks arsip. Bila sedang membaca teks yang sama, dihentikan.
  Future<void> baca(String teks) async {
    final bersih = teks.trim();
    if (bersih.isEmpty) return;

    if (_status == StatusPembaca.membaca) {
      await berhenti();
      return;
    }

    _teksAktif = bersih;
    _status = StatusPembaca.membaca;
    onStatusBerubah?.call(_status);

    try {
      await _tts.stop();
      await _tts.speak(bersih);
    } catch (_) {
      _status = StatusPembaca.diam;
      onStatusBerubah?.call(_status);
    }
  }

  Future<void> jeda() async {
    if (_status != StatusPembaca.membaca) return;
    try {
      await _tts.pause();
      _status = StatusPembaca.jeda;
      onStatusBerubah?.call(_status);
    } catch (_) {}
  }

  Future<void> lanjut() async {
    if (_status != StatusPembaca.jeda) return;
    try {
      if (_teksAktif.isNotEmpty) {
        await _tts.speak(_teksAktif);
      }
    } catch (_) {}
  }

  Future<void> toggle(String teks) async {
    if (_status == StatusPembaca.membaca) {
      await jeda();
    } else if (_status == StatusPembaca.jeda) {
      await lanjut();
    } else {
      await baca(teks);
    }
  }

  Future<void> berhenti() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _status = StatusPembaca.diam;
    _teksAktif = '';
    onStatusBerubah?.call(_status);
  }
}
