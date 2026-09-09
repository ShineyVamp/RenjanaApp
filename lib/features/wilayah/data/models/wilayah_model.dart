// Model wilayah untuk Peta Nusantara: gugus pulau dan provinsi.

class Provinsi {
  final String nama;
  final String ibukota;
  final double lon;
  final double lat;
  final String julukan;
  final String deskripsi;
  final String? gambar; // null = ikut gambar pulaunya

  const Provinsi(
    this.nama,
    this.ibukota,
    this.lon,
    this.lat, {
    this.julukan = '',
    this.deskripsi = '',
    this.gambar,
  });
}

class GugusPulau {
  final String id;
  final String nama;
  final double lon; // titik penanda saat tampilan nasional
  final double lat;
  final double lonMin; // kotak zoom saat pulau dibuka
  final double latMax;
  final double lonMax;
  final double latMin;
  final String deskripsi;
  final String gambar;
  final List<Provinsi> provinsi;

  const GugusPulau({
    required this.id,
    required this.nama,
    required this.lon,
    required this.lat,
    required this.lonMin,
    required this.latMax,
    required this.lonMax,
    required this.latMin,
    required this.provinsi,
    this.deskripsi = '',
    this.gambar = '',
  });
}
