// section model wilayah

class Provinsi {
  final String nama;
  final String ibukota;
  final double lon;
  final double lat;
  final String julukan;
  final String deskripsi;
  final String? gambar;

  const Provinsi(
    this.nama,
    this.ibukota,
    this.lon,
    this.lat, {
    this.julukan = '',
    this.deskripsi = '',
    this.gambar,
  });

  // section serialisasi provinsi
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'ibukota': ibukota,
      'lon': lon,
      'lat': lat,
      'julukan': julukan,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }

  factory Provinsi.fromMap(Map<String, dynamic> map) {
    return Provinsi(
      map['nama'] as String? ?? '',
      map['ibukota'] as String? ?? '',
      (map['lon'] as num?)?.toDouble() ?? 0.0,
      (map['lat'] as num?)?.toDouble() ?? 0.0,
      julukan: map['julukan'] as String? ?? '',
      deskripsi: map['deskripsi'] as String? ?? '',
      gambar: map['gambar'] as String?,
    );
  }
}

class GugusPulau {
  final String id;
  final String nama;
  final double lon;
  final double lat;
  final double lonMin;
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

  // section serialisasi gugus pulau
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'lon': lon,
      'lat': lat,
      'lonMin': lonMin,
      'latMax': latMax,
      'lonMax': lonMax,
      'latMin': latMin,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'provinsi': provinsi.map((p) => p.toMap()).toList(),
    };
  }

  factory GugusPulau.fromMap(Map<String, dynamic> map) {
    final rawProv = map['provinsi'];
    List<Provinsi> provList = [];
    if (rawProv is List) {
      provList = rawProv
          .whereType<Map<String, dynamic>>()
          .map((p) => Provinsi.fromMap(p))
          .toList();
    }
    return GugusPulau(
      id: map['id'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      lon: (map['lon'] as num?)?.toDouble() ?? 0.0,
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lonMin: (map['lonMin'] as num?)?.toDouble() ?? 0.0,
      latMax: (map['latMax'] as num?)?.toDouble() ?? 0.0,
      lonMax: (map['lonMax'] as num?)?.toDouble() ?? 0.0,
      latMin: (map['latMin'] as num?)?.toDouble() ?? 0.0,
      deskripsi: map['deskripsi'] as String? ?? '',
      gambar: map['gambar'] as String? ?? '',
      provinsi: provList,
    );
  }
}
