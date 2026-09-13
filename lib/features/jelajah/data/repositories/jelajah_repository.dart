import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import '../models/hasil_jelajah_model.dart';

// enum bagian kecocokan pencarian
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

// enum kategori filter pencarian
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

// model agregasi hasil pencarian
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

// model baris hasil pencarian
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

// repository pencarian jelajah
class JelajahRepository {
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;

  static List<HasilJelajah>? _cachedSemuaArsip;
  static List<HasilJelajah>? _cachedSemuaWilayah;

  JelajahRepository({
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  // section bersihkan cache
  static void bersihkanCache() {
    _cachedSemuaArsip = null;
    _cachedSemuaWilayah = null;
  }

  // section semua arsip
  Future<List<HasilJelajah>> semuaArsip({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedSemuaArsip != null) {
      return _cachedSemuaArsip!;
    }
    final sejarah = await _sejarahRepository.getAllSejarah();
    final budaya = await _budayaRepository.getAllBudaya();
    final list = [
      ...sejarah.map(HasilJelajah.dariSejarah),
      ...budaya.map(HasilJelajah.dariBudaya),
    ];
    _cachedSemuaArsip = list;
    return list;
  }

  // section semua wilayah
  List<HasilJelajah> semuaWilayah() {
    if (_cachedSemuaWilayah != null) return _cachedSemuaWilayah!;
    final list = [
      ...gugusPulauList.map(HasilJelajah.dariPulau),
      ...semuaProvinsi.map(HasilJelajah.dariProvinsi),
    ];
    _cachedSemuaWilayah = list;
    return list;
  }

  // algoritma pemeringkatan pencarian
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

      final aWilayah = a.item.isWilayah ? 0 : 1;
      final bWilayah = b.item.isWilayah ? 0 : 1;
      if (aWilayah != bWilayah) return aWilayah.compareTo(bWilayah);

      final aPanjang = a.item.judul.length;
      final bPanjang = b.item.judul.length;
      if (aPanjang != bPanjang) return aPanjang.compareTo(bPanjang);

      return a.item.judul.toLowerCase().compareTo(b.item.judul.toLowerCase());
    });

    final jumlah = {
      for (final j in SaringJenis.values)
        j: hasil.where((h) => j.cocok(h.item)).length,
    };

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

  static HasilCari? _nilaiItem(HasilJelajah item, List<String> kata) {
    final judul = _normalkan(item.judul);
    final kode = _normalkan(item.kodeTag);
    final sub = _normalkan(item.sub);
    final meta = _normalkan(item.meta);
    final isi = _normalkan(item.isiPencarian);

    var total = 0;
    BagianCocok? terbaik;

    for (final k in kata) {
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

    final frasa = kata.join(' ');
    if (kata.length > 1 && judul.contains(frasa)) total += 400;

    return HasilCari(item: item, skor: total, bagian: terbaik!);
  }

  static int _skor(String ladang, String kata, List<int> bobot) {
    if (ladang.isEmpty) return 0;
    if (ladang == kata) return bobot[0];
    if (ladang.startsWith(kata)) return bobot[1];
    if (ladang.contains(' $kata')) return bobot[2];
    if (ladang.contains(kata)) return bobot[3];
    return 0;
  }

  static const List<int> _bobotJudul = [1000, 700, 500, 220];
  static const List<int> _bobotKode = [900, 600, 400, 180];
  static const List<int> _bobotSub = [200, 160, 130, 70];
  static const List<int> _bobotMeta = [180, 140, 110, 60];
  static const List<int> _bobotIsi = [60, 50, 40, 15];

  static String _normalkan(String teks) => teks
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(' +'), ' ');

  static List<String> _pecahKata(String kataKunci) =>
      _normalkan(kataKunci).split(' ').where((k) => k.isNotEmpty).toList();

  // parser referensi riwayat
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
