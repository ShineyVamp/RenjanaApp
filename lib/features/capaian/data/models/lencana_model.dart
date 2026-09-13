// section katalog dan syarat lencana
import '../../../../core/constants/budaya_kategori.dart';
import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';

enum JenisSyarat {
  // seluruh arsip pada satu kategori budaya sudah dibuka
  arsipKategori,
  // seluruh arsip pada satu periode sejarah sudah dibuka
  arsipPeriode,
  // seluruh arsip pada satu gugus pulau sudah dibuka
  arsipPulau,
  // runtun harian terpanjang mencapai sekian hari
  runtun,
  // sejumlah arsip berbeda pernah dibuka
  jumlahArsip,
  // sejumlah usulan konten pernah disetujui admin
  usulanDisetujui,
}

class Lencana {
  final String kode;
  final String nama;
  final String keterangan;
  final JenisSyarat syarat;

  // kode acuan kategori, periode, atau pulau
  final String acuan;

  // ambang batas target
  final int ambang;

  const Lencana({
    required this.kode,
    required this.nama,
    required this.keterangan,
    required this.syarat,
    this.acuan = '',
    this.ambang = 0,
  });
}

// section lencana kategori budaya
List<Lencana> get _lencanaKategori => [
  for (final k in budayaKategoriList)
    Lencana(
      kode: 'KAT-${k.kode}',
      nama: 'Penekun ${k.nama}',
      keterangan: 'Buka seluruh arsip kategori ${k.nama}',
      syarat: JenisSyarat.arsipKategori,
      acuan: k.kode,
    ),
];

// section lencana periode sejarah
List<Lencana> get _lencanaPeriode => [
  for (final p in periodeSejarahList)
    Lencana(
      kode: 'PRD-${p.kode}',
      nama: 'Saksi ${p.nama}',
      keterangan: 'Buka seluruh arsip sejarah era ${p.nama}',
      syarat: JenisSyarat.arsipPeriode,
      acuan: p.kode,
    ),
];

// section lencana gugus pulau
final List<Lencana> _lencanaPulau = [
  for (final p in gugusPulauList)
    Lencana(
      kode: 'PLU-${p.id}',
      nama: 'Penjelajah ${p.nama}',
      keterangan: 'Buka seluruh arsip dari ${p.nama}',
      syarat: JenisSyarat.arsipPulau,
      acuan: p.id,
    ),
];

const List<Lencana> _lencanaKebiasaan = [
  Lencana(
    kode: 'RTN-3',
    nama: 'Tiga Hari Berturut',
    keterangan: 'Datang tiga hari berturut-turut',
    syarat: JenisSyarat.runtun,
    ambang: 3,
  ),
  Lencana(
    kode: 'RTN-7',
    nama: 'Sepekan Penuh',
    keterangan: 'Datang tujuh hari berturut-turut',
    syarat: JenisSyarat.runtun,
    ambang: 7,
  ),
  Lencana(
    kode: 'RTN-30',
    nama: 'Sebulan Setia',
    keterangan: 'Datang tiga puluh hari berturut-turut',
    syarat: JenisSyarat.runtun,
    ambang: 30,
  ),
  Lencana(
    kode: 'ARS-10',
    nama: 'Pembaca Tekun',
    keterangan: 'Buka sepuluh arsip berbeda',
    syarat: JenisSyarat.jumlahArsip,
    ambang: 10,
  ),
  Lencana(
    kode: 'ARS-25',
    nama: 'Pengelana Arsip',
    keterangan: 'Buka dua puluh lima arsip berbeda',
    syarat: JenisSyarat.jumlahArsip,
    ambang: 25,
  ),
  Lencana(
    kode: 'ARS-50',
    nama: 'Penjaga Ingatan',
    keterangan: 'Buka lima puluh arsip berbeda',
    syarat: JenisSyarat.jumlahArsip,
    ambang: 50,
  ),
  Lencana(
    kode: 'KTB-1',
    nama: 'Penyumbang Arsip',
    keterangan: 'Satu usulan Anda disetujui dan terbit',
    syarat: JenisSyarat.usulanDisetujui,
    ambang: 1,
  ),
  Lencana(
    kode: 'KTB-5',
    nama: 'Penjaga Warisan',
    keterangan: 'Lima usulan Anda disetujui dan terbit',
    syarat: JenisSyarat.usulanDisetujui,
    ambang: 5,
  ),
];

List<Lencana> get lencanaKatalog => [
  ..._lencanaKebiasaan,
  ..._lencanaKategori,
  ..._lencanaPeriode,
  ..._lencanaPulau,
];

// section gelar pengguna
class GelarPengguna {
  final String nama;
  final int ambang;

  const GelarPengguna(this.nama, this.ambang);
}

const List<GelarPengguna> gelarList = [
  GelarPengguna('Pelajar', 0),
  GelarPengguna('Penjelajah', 3),
  GelarPengguna('Kurator', 9),
  GelarPengguna('Sejarawan', 18),
];

GelarPengguna gelarDariLencana(int jumlahTerbuka) {
  var hasil = gelarList.first;
  for (final gelar in gelarList) {
    if (jumlahTerbuka >= gelar.ambang) hasil = gelar;
  }
  return hasil;
}
