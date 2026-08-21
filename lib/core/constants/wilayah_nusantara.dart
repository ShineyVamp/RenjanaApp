// Katalog wilayah untuk Peta Nusantara: 7 gugus pulau, 38 provinsi.
// Koordinat dipakai untuk menempatkan penanda di peta.

class Provinsi {
  final String nama;
  final String ibukota;
  final double lon;
  final double lat;

  const Provinsi(this.nama, this.ibukota, this.lon, this.lat);
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
  });
}

const List<GugusPulau> gugusPulauList = [
  GugusPulau(
    id: 'sumatera',
    nama: 'Sumatera',
    lon: 101.5,
    lat: -0.5,
    lonMin: 94.5,
    latMax: 6.5,
    lonMax: 107,
    latMin: -6.5,
    provinsi: [
      Provinsi('Aceh', 'Banda Aceh', 95.32, 5.55),
      Provinsi('Sumatera Utara', 'Medan', 98.67, 3.59),
      Provinsi('Sumatera Barat', 'Padang', 100.35, -0.95),
      Provinsi('Riau', 'Pekanbaru', 101.45, 0.51),
      Provinsi('Kepulauan Riau', 'Tanjungpinang', 104.46, 0.92),
      Provinsi('Jambi', 'Jambi', 103.61, -1.61),
      Provinsi('Bengkulu', 'Bengkulu', 102.26, -3.80),
      Provinsi('Sumatera Selatan', 'Palembang', 104.76, -2.99),
      Provinsi('Kepulauan Bangka Belitung', 'Pangkalpinang', 106.11, -2.13),
      Provinsi('Lampung', 'Bandar Lampung', 105.26, -5.43),
    ],
  ),
  GugusPulau(
    id: 'jawa',
    nama: 'Jawa',
    lon: 110,
    lat: -7.4,
    lonMin: 105,
    latMax: -5.5,
    lonMax: 115.5,
    latMin: -9,
    provinsi: [
      Provinsi('Banten', 'Serang', 106.15, -6.12),
      Provinsi('DKI Jakarta', 'Jakarta', 106.85, -6.21),
      Provinsi('Jawa Barat', 'Bandung', 107.61, -6.91),
      Provinsi('Jawa Tengah', 'Semarang', 110.42, -6.97),
      Provinsi('DI Yogyakarta', 'Yogyakarta', 110.36, -7.80),
      Provinsi('Jawa Timur', 'Surabaya', 112.75, -7.25),
    ],
  ),
  GugusPulau(
    id: 'kalimantan',
    nama: 'Kalimantan',
    lon: 114,
    lat: 0.5,
    lonMin: 108.5,
    latMax: 4.5,
    lonMax: 119.5,
    latMin: -4.5,
    provinsi: [
      Provinsi('Kalimantan Barat', 'Pontianak', 109.33, -0.03),
      Provinsi('Kalimantan Tengah', 'Palangka Raya', 113.92, -2.21),
      Provinsi('Kalimantan Selatan', 'Banjarbaru', 114.83, -3.44),
      Provinsi('Kalimantan Timur', 'Samarinda', 117.15, -0.50),
      Provinsi('Kalimantan Utara', 'Tanjung Selor', 117.37, 2.84),
    ],
  ),
  GugusPulau(
    id: 'sulawesi',
    nama: 'Sulawesi',
    lon: 121,
    lat: -2,
    lonMin: 118,
    latMax: 2.5,
    lonMax: 125.5,
    latMin: -6.5,
    provinsi: [
      Provinsi('Sulawesi Utara', 'Manado', 124.84, 1.47),
      Provinsi('Gorontalo', 'Gorontalo', 123.06, 0.54),
      Provinsi('Sulawesi Tengah', 'Palu', 119.87, -0.90),
      Provinsi('Sulawesi Barat', 'Mamuju', 118.89, -2.68),
      Provinsi('Sulawesi Selatan', 'Makassar', 119.43, -5.15),
      Provinsi('Sulawesi Tenggara', 'Kendari', 122.51, -3.99),
    ],
  ),
  GugusPulau(
    id: 'balinusra',
    nama: 'Bali & Nusa Tenggara',
    lon: 119.5,
    lat: -9,
    lonMin: 114,
    latMax: -7.8,
    lonMax: 125.5,
    latMin: -11,
    provinsi: [
      Provinsi('Bali', 'Denpasar', 115.50, -8.65),
      Provinsi('Nusa Tenggara Barat', 'Mataram', 117.80, -8.58),
      Provinsi('Nusa Tenggara Timur', 'Kupang', 123.60, -10.18),
    ],
  ),
  GugusPulau(
    id: 'maluku',
    nama: 'Maluku',
    lon: 128,
    lat: -1.5,
    lonMin: 124.5,
    latMax: 3,
    lonMax: 135,
    latMin: -8.5,
    provinsi: [
      Provinsi('Maluku Utara', 'Sofifi', 127.57, 0.73),
      Provinsi('Maluku', 'Ambon', 128.18, -3.70),
    ],
  ),
  GugusPulau(
    id: 'papua',
    nama: 'Papua',
    lon: 137,
    lat: -4,
    lonMin: 130.5,
    latMax: 0.5,
    lonMax: 141.5,
    latMin: -9.5,
    provinsi: [
      Provinsi('Papua Barat Daya', 'Sorong', 131.25, -0.88),
      Provinsi('Papua Barat', 'Manokwari', 134.06, -0.86),
      Provinsi('Papua Tengah', 'Nabire', 135.50, -3.36),
      Provinsi('Papua Pegunungan', 'Wamena', 138.95, -4.10),
      Provinsi('Papua', 'Jayapura', 140.72, -2.53),
      Provinsi('Papua Selatan', 'Merauke', 140.40, -8.49),
    ],
  ),
];

// Kotak tampilan nasional.
const double petaLonMin = 94;
const double petaLatMax = 7.5;
const double petaLonMax = 142;
const double petaLatMin = -12;

int get jumlahProvinsi =>
    gugusPulauList.fold(0, (total, g) => total + g.provinsi.length);
