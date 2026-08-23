import '../../core/constants/wilayah_nusantara.dart';
import '../models/hasil_jelajah_model.dart';
import 'budaya_repository.dart';
import 'sejarah_repository.dart';

// Bagian teks tempat sebuah kata kunci ditemukan. Urutannya dari yang paling
// menentukan, dipakai juga untuk memilih alasan yang ditampilkan.
enum BagianCocok { judul, kodeTag, sub, meta, isi }

extension LabelBagianCocok on BagianCocok {
  String get label {
    switch (this) {
      case BagianCocok.judul:
        return 'judul';
      case BagianCocok.kodeTag:
        return 'ID tag';
      case BagianCocok.sub:
        return 'subjudul';
      case BagianCocok.meta:
        return 'kategori';
      case BagianCocok.isi:
        return 'isi arsip';
    }
  }
}

// Penyaring jenis pada hasil pencarian. Pulau dan provinsi disatukan jadi
// wilayah, sebab bagi pencari keduanya sama-sama "tempat".
enum SaringJenis { sejarah, budaya, wilayah }

extension LabelSaringJenis on SaringJenis {
  String get label {
    switch (this) {
      case SaringJenis.sejarah:
        return 'Sejarah';
      case SaringJenis.budaya:
        return 'Budaya';
      case SaringJenis.wilayah:
        return 'Wilayah';
    }
  }

  bool cocok(HasilJelajah item) {
    switch (this) {
      case SaringJenis.sejarah:
        return item.jenis == JenisArsip.sejarah;
      case SaringJenis.budaya:
        return item.jenis == JenisArsip.budaya;
      case SaringJenis.wilayah:
        return item.isWilayah;
    }
  }
}

// Sekumpulan hasil pencarian beserta hitungan tiap jenisnya.
//
// Hitungannya dihitung sebelum penyaringan dan sebelum pemotongan, sehingga
// chip penyaring tetap menunjukkan berapa banyak yang sebenarnya ada.
class HasilPencarian {
  final List<HasilCari> hasil;
  final Map<SaringJenis, int> jumlah;
  final int totalCocok;
  final bool terpotong;

  const HasilPencarian({
    this.hasil = const [],
    this.jumlah = const {},
    this.totalCocok = 0,
    this.terpotong = false,
  });
}

// Satu baris hasil pencarian beserta nilai dan alasan kecocokannya.
class HasilCari {
  final HasilJelajah item;
  final int skor;
  final BagianCocok bagian;

  const HasilCari({
    required this.item,
    required this.skor,
    required this.bagian,
  });
}

// Pencarian gabungan sejarah, budaya, dan wilayah untuk halaman Jelajah.
class JelajahRepository {
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;

  JelajahRepository({
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  // Seluruh arsip sejarah dan budaya, tanpa wilayah. Dipakai juga
  // WilayahRepository untuk menghitung arsip per daerah.
  Future<List<HasilJelajah>> semuaArsip() async {
    final sejarah = await _sejarahRepository.getAllSejarah();
    final budaya = await _budayaRepository.getAllBudaya();
    return [
      ...sejarah.map(HasilJelajah.dariSejarah),
      ...budaya.map(HasilJelajah.dariBudaya),
    ];
  }

  // Tujuh pulau dan 38 provinsi sebagai baris hasil pencarian.
  List<HasilJelajah> semuaWilayah() => [
    ...gugusPulauList.map(HasilJelajah.dariPulau),
    ...semuaProvinsi.map(HasilJelajah.dariProvinsi),
  ];

  // Mencari dengan pemberian skor, bukan sekadar cocok atau tidak.
  //
  // Kata kunci dipecah per kata dan setiap kata dinilai terhadap tiap bagian
  // teks secara terpisah. Bagian yang lebih menentukan diberi bobot lebih
  // besar, sehingga judul yang persis sama selalu di atas judul yang hanya
  // mengandung kata kunci di tengah kata.
  Future<HasilPencarian> cari(
    String kataKunci, {
    int batas = 60,
    SaringJenis? saring,
  }) async {
    final kata = _pecahKata(kataKunci);
    if (kata.isEmpty) return const HasilPencarian();

    final sumber = [...await semuaArsip(), ...semuaWilayah()];
    final hasil = <HasilCari>[];

    for (final item in sumber) {
      final nilai = _nilaiItem(item, kata);
      if (nilai != null) hasil.add(nilai);
    }

    hasil.sort((a, b) {
      if (a.skor != b.skor) return b.skor.compareTo(a.skor);

      // wilayah didahulukan atas arsip pada skor yang sama
      final aWilayah = a.item.isWilayah ? 0 : 1;
      final bWilayah = b.item.isWilayah ? 0 : 1;
      if (aWilayah != bWilayah) return aWilayah.compareTo(bWilayah);

      // judul lebih pendek berarti kata kuncinya menempati porsi lebih besar
      final aPanjang = a.item.judul.length;
      final bPanjang = b.item.judul.length;
      if (aPanjang != bPanjang) return aPanjang.compareTo(bPanjang);

      return a.item.judul.toLowerCase().compareTo(b.item.judul.toLowerCase());
    });

    final jumlah = {
      for (final j in SaringJenis.values)
        j: hasil.where((h) => j.cocok(h.item)).length,
    };

    // Penyaringan dilakukan sebelum pemotongan, jadi memilih satu jenis tidak
    // kehilangan hasil yang tergeser keluar batas oleh jenis lain.
    final tersaring = saring == null
        ? hasil
        : hasil.where((h) => saring.cocok(h.item)).toList();

    return HasilPencarian(
      hasil: tersaring.length > batas ? tersaring.sublist(0, batas) : tersaring,
      jumlah: jumlah,
      totalCocok: tersaring.length,
      terpotong: tersaring.length > batas,
    );
  }

  // Nilai satu item, atau null bila ada kata kunci yang tidak ketemu sama
  // sekali. Seluruh kata harus cocok, bukan salah satunya saja.
  static HasilCari? _nilaiItem(HasilJelajah item, List<String> kata) {
    final judul = _normalkan(item.judul);
    final kode = _normalkan(item.kodeTag);
    final sub = _normalkan(item.sub);
    final meta = _normalkan(item.meta);
    final isi = _normalkan(item.isiPencarian);

    var total = 0;
    BagianCocok? terbaik;

    for (final k in kata) {
      // Kata pendek tidak menyentuh isi deskripsi; tanpa aturan ini mengetik
      // satu huruf akan mencocokkan hampir semua arsip.
      final pendek = k.length < 3;

      final calon = <(int, BagianCocok)>[
        (_skor(judul, k, _bobotJudul), BagianCocok.judul),
        (_skor(kode, k, _bobotKode), BagianCocok.kodeTag),
        if (!pendek) (_skor(sub, k, _bobotSub), BagianCocok.sub),
        if (!pendek) (_skor(meta, k, _bobotMeta), BagianCocok.meta),
        if (!pendek) (_skor(isi, k, _bobotIsi), BagianCocok.isi),
      ];

      var skorKata = 0;
      BagianCocok? bagianKata;
      for (final (nilai, bagian) in calon) {
        if (nilai > skorKata) {
          skorKata = nilai;
          bagianKata = bagian;
        }
      }

      if (skorKata == 0) return null;
      total += skorKata;
      if (terbaik == null || bagianKata!.index < terbaik.index) {
        terbaik = bagianKata;
      }
    }

    // Seluruh kata kunci muncul berurutan di judul, bukan tersebar.
    final frasa = kata.join(' ');
    if (kata.length > 1 && judul.contains(frasa)) total += 400;

    return HasilCari(item: item, skor: total, bagian: terbaik!);
  }

  // Empat tingkat kecocokan, dari yang paling meyakinkan ke yang paling
  // longgar: sama persis, jadi awalan, jatuh di awal sebuah kata, dan muncul
  // di tengah kata.
  static int _skor(String ladang, String kata, List<int> bobot) {
    if (ladang.isEmpty) return 0;
    if (ladang == kata) return bobot[0];
    if (ladang.startsWith(kata)) return bobot[1];
    if (ladang.contains(' $kata')) return bobot[2];
    if (ladang.contains(kata)) return bobot[3];
    return 0;
  }

  // [persis, awalan, awal kata, tengah kata]
  static const List<int> _bobotJudul = [1000, 700, 500, 220];
  static const List<int> _bobotKode = [900, 600, 400, 180];
  static const List<int> _bobotSub = [200, 160, 130, 70];
  static const List<int> _bobotMeta = [180, 140, 110, 60];
  static const List<int> _bobotIsi = [60, 50, 40, 15];

  // Huruf kecil, tanda baca jadi spasi, spasi ganda dirapatkan. Bentuk ini
  // membuat "Rambu Solo" ketemu dengan "rambu-solo".
  static String _normalkan(String teks) => teks
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(' +'), ' ');

  static List<String> _pecahKata(String kataKunci) =>
      _normalkan(kataKunci).split(' ').where((k) => k.isNotEmpty).toList();

  // Mengubah daftar ref riwayat ('jenis|kodeTag') jadi arsip yang masih ada,
  // urut sesuai urutan riwayat.
  Future<List<HasilJelajah>> ambilDariRiwayat(
    List<String> refs, {
    int? batas,
  }) async {
    if (refs.isEmpty) return [];

    final indeks = {
      for (final item in await semuaArsip()) item.refRiwayat: item,
    };
    final hasil = <HasilJelajah>[];
    for (final ref in refs) {
      final item = indeks[ref];
      if (item != null) hasil.add(item);
      if (batas != null && hasil.length >= batas) break;
    }
    return hasil;
  }
}
