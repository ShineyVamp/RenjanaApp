import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../core/constants/app_colors.dart';
import '../../data/static/data_wilayah_nusantara.dart';

// Garis pantai hasil ekstraksi Natural Earth 110m. Titik disimpan sebagai
// Offset(lon, lat), bukan koordinat layar.
class PetaGeometri {
  final List<List<List<Offset>>> indonesia;
  final List<List<List<Offset>>> tetangga;

  const PetaGeometri({required this.indonesia, required this.tetangga});

  static PetaGeometri? _cache;

  static Future<PetaGeometri> muat() async {
    if (_cache != null) return _cache!;
    final mentah = await rootBundle.loadString(
      'assets/data/peta_nusantara.json',
    );
    final data = jsonDecode(mentah) as Map<String, dynamic>;

    List<List<List<Offset>>> baca(String kunci) {
      return (data[kunci] as List)
          .map(
            (poligon) => (poligon as List)
                .map(
                  (ring) => (ring as List)
                      .map(
                        (titik) => Offset(
                          (titik[0] as num).toDouble(),
                          (titik[1] as num).toDouble(),
                        ),
                      )
                      .toList(),
                )
                .toList(),
          )
          .toList();
    }

    _cache = PetaGeometri(
      indonesia: baca('indonesia'),
      tetangga: baca('tetangga'),
    );
    return _cache!;
  }
}

// Proyeksi Mercator yang dipaskan ke kotak tampilan nasional, sama seperti
// d3.geoMercator().fitExtent() pada prototipe.
class ProyeksiPeta {
  final double skala;
  final double geserX;
  final double geserY;

  const ProyeksiPeta._(this.skala, this.geserX, this.geserY);

  static double _mentahX(double lon) => lon * pi / 180;

  static double _mentahY(double lat) {
    final phi = lat * pi / 180;
    return log(tan(pi / 4 + phi / 2));
  }

  factory ProyeksiPeta.paskan(Size ukuran) {
    const tepiX = 16.0;
    const tepiY = 20.0;

    final x0 = _mentahX(petaLonMin);
    final x1 = _mentahX(petaLonMax);
    final y0 = _mentahY(petaLatMax);
    final y1 = _mentahY(petaLatMin);

    final lebar = max(1.0, ukuran.width - tepiX * 2);
    final tinggi = max(1.0, ukuran.height - tepiY * 2);
    final skala = min(lebar / (x1 - x0).abs(), tinggi / (y0 - y1).abs());

    final pusatX = (x0 + x1) / 2;
    final pusatY = (y0 + y1) / 2;

    return ProyeksiPeta._(
      skala,
      ukuran.width / 2 - skala * pusatX,
      ukuran.height / 2 + skala * pusatY,
    );
  }

  // section proyeksi paskan kotak pulau
  factory ProyeksiPeta.paskanKotak(
    Size ukuran, {
    required double lonMin,
    required double latMax,
    required double lonMax,
    required double latMin,
    double tepiX = 24.0,
    double tepiY = 24.0,
  }) {
    final x0 = _mentahX(lonMin);
    final x1 = _mentahX(lonMax);
    final y0 = _mentahY(latMax);
    final y1 = _mentahY(latMin);

    final lebar = max(1.0, ukuran.width - tepiX * 2);
    final tinggi = max(1.0, ukuran.height - tepiY * 2);
    final skala = min(lebar / (x1 - x0).abs(), tinggi / (y0 - y1).abs());

    final pusatX = (x0 + x1) / 2;
    final pusatY = (y0 + y1) / 2;

    return ProyeksiPeta._(
      skala,
      ukuran.width / 2 - skala * pusatX,
      ukuran.height / 2 + skala * pusatY,
    );
  }

  Offset titik(double lon, double lat) =>
      Offset(skala * _mentahX(lon) + geserX, geserY - skala * _mentahY(lat));

  Path bangunPath(List<List<List<Offset>>> poligonList) {
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final poligon in poligonList) {
      for (final ring in poligon) {
        if (ring.isEmpty) continue;
        final awal = titik(ring.first.dx, ring.first.dy);
        path.moveTo(awal.dx, awal.dy);
        for (var i = 1; i < ring.length; i++) {
          final p = titik(ring[i].dx, ring[i].dy);
          path.lineTo(p.dx, p.dy);
        }
        path.close();
      }
    }
    return path;
  }
}

class PetaPainter extends CustomPainter {
  final Path pathIndonesia;
  final Path pathTetangga;

  // Ketebalan garis dibagi skala peta, hasilnya tebal yang tetap di layar.
  final double skalaTampilan;

  const PetaPainter({
    required this.pathIndonesia,
    required this.pathTetangga,
    required this.skalaTampilan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final k = skalaTampilan <= 0 ? 1.0 : skalaTampilan;

    canvas.drawPath(
      pathTetangga,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFE7E1D4),
    );
    canvas.drawPath(
      pathTetangga,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 / k
        ..color = AppColors.border,
    );

    canvas.drawPath(
      pathIndonesia,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.surfaceMuted,
    );
    canvas.drawPath(
      pathIndonesia,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9 / k
        ..strokeJoin = ui.StrokeJoin.round
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(PetaPainter old) =>
      old.pathIndonesia != pathIndonesia ||
      old.pathTetangga != pathTetangga ||
      old.skalaTampilan != skalaTampilan;
}

// section siluet pulau painter
class SiluetPulauPainter extends CustomPainter {
  final Path pathIndonesia;
  final Path pathTetangga;

  const SiluetPulauPainter({
    required this.pathIndonesia,
    required this.pathTetangga,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEDE8DD),
          Color(0xFFE4DDD0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;
    for (double x = 32; x < size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 32; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(
      pathTetangga,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFDED8CB),
    );
    canvas.drawPath(
      pathTetangga,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = AppColors.border,
    );

    canvas.drawShadow(pathIndonesia, Colors.black, 3.0, false);

    canvas.drawPath(
      pathIndonesia,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.surfaceMuted,
    );
    canvas.drawPath(
      pathIndonesia,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeJoin = ui.StrokeJoin.round
        ..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant SiluetPulauPainter oldDelegate) =>
      oldDelegate.pathIndonesia != pathIndonesia ||
      oldDelegate.pathTetangga != pathTetangga;
}

