import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dekorasi.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/katalog_kategori.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_bar_halaman.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/pesan_kosong.dart';
import '../../data/repositories/kategori_repository.dart';

// Pengelolaan katalog kategori: menambah kategori baru, mengganti nama,
// menyusun ulang urutannya, dan menyunting daftar rincian khasnya.
//
// Kategori bawaan boleh disunting tetapi tidak boleh dihapus, sebab arsip yang
// sudah terbit menunjuk kodenya.
class AdminManageKategoriPage extends StatefulWidget {
  final String ranah;
  final String judul;

  const AdminManageKategoriPage({
    super.key,
    this.ranah = ranahBudaya,
    this.judul = 'Kategori Budaya',
  });

  @override
  State<AdminManageKategoriPage> createState() =>
      _AdminManageKategoriPageState();
}

class _AdminManageKategoriPageState extends State<AdminManageKategoriPage> {
  final KategoriRepository _repository = KategoriRepository();

  List<KategoriItem> _daftar = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final daftar = await _repository.semua(widget.ranah);
    if (!mounted) return;
    setState(() {
      _daftar = daftar;
      _isLoading = false;
    });
  }

  Future<void> _bukaForm({KategoriItem? kategori}) async {
    final tersimpan = await context.push(
      FormKategoriPage(ranah: widget.ranah, kategori: kategori),
    );
    if (tersimpan != true || !mounted) return;
    await _muatData();
  }

  Future<void> _pindahkan(int dari, int ke) async {
    final urut = List<KategoriItem>.from(_daftar);
    final item = urut.removeAt(dari);
    urut.insert(dari < ke ? ke - 1 : ke, item);

    setState(() => _daftar = urut);
    await _repository.urutkan(urut);
  }

  Future<void> _hapus(KategoriItem kategori) async {
    final pemakai = await _repository.jumlahPemakai(kategori);
    if (!mounted) return;

    if (!pemakai.kosong) {
      _beriTahu(
        '${kategori.nama} masih dipakai ${pemakai.ringkasan}.',
        AppColors.error,
      );
      return;
    }

    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Hapus kategori', style: AppTypography.labelBold()),
        content: Text(
          'Kategori ${kategori.nama} akan dihapus dari katalog.',
          style: AppTypography.caption(fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text('Batal', style: AppTypography.labelBold(fontSize: 13)),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              'Hapus',
              style: AppTypography.labelBold(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    await _repository.hapus(kategori);
    if (!mounted) return;
    await _muatData();
    if (!mounted) return;
    _beriTahu('${kategori.nama} dihapus', AppColors.success);
  }

  void _beriTahu(String pesan, Color warna) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: warna,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: widget.judul),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: Text(
          'Tambah',
          style: AppTypography.labelBold(fontSize: 13, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _daftar.isEmpty
                    ? const PesanKosong(
                        ikon: Icons.category_outlined,
                        judul: 'Katalog masih kosong',
                        pesan: 'Tambahkan kategori pertama lewat tombol di '
                            'sudut kanan bawah.',
                      )
                    : Column(
                        children: [
                          _buildRingkasan(),
                          Expanded(child: _buildDaftar()),
                        ],
                      ),
              ),
            ),
    );
  }

  Widget _buildRingkasan() {
    final bawaan = _daftar.where((k) => k.bawaan).length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: AppDekorasi.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ISI KATALOG', style: AppTypography.eyebrow()),
          const SizedBox(height: 3),
          Text(
            '${_daftar.length} kategori, $bawaan bawaan',
            style: AppTypography.labelBold(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Tahan gagang di kiri untuk menyusun ulang urutannya. Kategori '
            'bawaan boleh diganti nama tetapi tidak bisa dihapus.',
            style: AppTypography.caption(fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftar() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 92),
      itemCount: _daftar.length,
      onReorder: _pindahkan,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final kategori = _daftar[index];
        return _buildBaris(kategori, index);
      },
    );
  }

  Widget _buildBaris(KategoriItem kategori, int index) {
    return Container(
      key: ValueKey('kategori-${kategori.id ?? kategori.kode}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 20,
                color: AppColors.surfaceMuted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        kategori.nama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelBold(fontSize: 13),
                      ),
                    ),
                    if (kategori.bawaan) ...[
                      const SizedBox(width: 8),
                      Text(
                        'BAWAAN',
                        style: AppTypography.eyebrow(
                          fontSize: 8.5,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${kategori.kode} · ${kategori.field.length} rincian',
                  style: AppTypography.caption(fontSize: 10.5),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _bukaForm(kategori: kategori),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.primary,
            tooltip: 'Sunting',
            visualDensity: VisualDensity.compact,
          ),
          if (!kategori.bawaan)
            IconButton(
              onPressed: () => _hapus(kategori),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: AppColors.error,
              tooltip: 'Hapus',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

// Kolom isian satu rincian, dikumpulkan supaya controllernya mudah dibuang.
class _BarisField {
  final TextEditingController kunci;
  final TextEditingController label;
  final TextEditingController petunjuk;
  TipeField tipe;

  _BarisField({FieldKategori? awal})
    : kunci = TextEditingController(text: awal?.kunci ?? ''),
      label = TextEditingController(text: awal?.label ?? ''),
      petunjuk = TextEditingController(text: awal?.petunjuk ?? ''),
      tipe = awal?.tipe ?? TipeField.teks;

  void buang() {
    kunci.dispose();
    label.dispose();
    petunjuk.dispose();
  }

  FieldKategori get hasil {
    final isiPetunjuk = petunjuk.text.trim();
    return FieldKategori(
      kunci: kunci.text.trim(),
      label: label.text.trim(),
      tipe: tipe,
      petunjuk: isiPetunjuk.isEmpty ? null : isiPetunjuk,
    );
  }
}

// Form tambah dan sunting satu kategori beserta rincian khasnya. Menutup
// dengan hasil `true` bila ada yang tersimpan.
class FormKategoriPage extends StatefulWidget {
  final String ranah;
  final KategoriItem? kategori;

  const FormKategoriPage({super.key, required this.ranah, this.kategori});

  @override
  State<FormKategoriPage> createState() => _FormKategoriPageState();
}

class _FormKategoriPageState extends State<FormKategoriPage> {
  final KategoriRepository _repository = KategoriRepository();

  late final TextEditingController _kode;
  late final TextEditingController _nama;
  late final List<_BarisField> _field;

  bool _menyimpan = false;

  bool get _isEditing => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    _kode = TextEditingController(text: widget.kategori?.kode ?? '');
    _nama = TextEditingController(text: widget.kategori?.nama ?? '');
    _field = [
      for (final f in widget.kategori?.field ?? const <FieldKategori>[])
        _BarisField(awal: f),
    ];
  }

  @override
  void dispose() {
    _kode.dispose();
    _nama.dispose();
    for (final baris in _field) {
      baris.buang();
    }
    super.dispose();
  }

  void _tambahField() {
    setState(() => _field.add(_BarisField()));
  }

  void _hapusField(int index) {
    setState(() => _field.removeAt(index).buang());
  }

  // Mengembalikan pesan kesalahan pertama, atau null bila isian sudah benar.
  Future<String?> _periksa() async {
    final kode = _kode.text.trim().toUpperCase();
    final nama = _nama.text.trim();

    if (kode.isEmpty) return 'Kode kategori belum diisi.';
    if (!RegExp(r'^[A-Z]{2,6}$').hasMatch(kode)) {
      return 'Kode diisi 2-6 huruf tanpa spasi, mis. KLN.';
    }
    if (nama.isEmpty) return 'Nama kategori belum diisi.';

    final bentrok = await _repository.kodeTerpakai(
      widget.ranah,
      kode,
      kecuali: widget.kategori?.id,
    );
    if (bentrok) return 'Kode $kode sudah dipakai kategori lain.';

    final kunciTerpakai = <String>{};
    for (final baris in _field) {
      final kunci = baris.kunci.text.trim();
      if (kunci.isEmpty) return 'Ada rincian yang kuncinya masih kosong.';
      if (baris.label.text.trim().isEmpty) {
        return 'Rincian $kunci belum punya label.';
      }
      if (!kunciTerpakai.add(kunci)) {
        return 'Kunci $kunci dipakai dua kali.';
      }
    }

    return null;
  }

  Future<void> _simpan() async {
    if (_menyimpan) return;
    setState(() => _menyimpan = true);

    final salah = await _periksa();
    if (!mounted) return;

    if (salah != null) {
      setState(() => _menyimpan = false);
      _beriTahu(salah, AppColors.error);
      return;
    }

    final semula = widget.kategori;
    await _repository.simpan(
      KategoriItem(
        id: semula?.id,
        ranah: widget.ranah,
        kode: _kode.text.trim().toUpperCase(),
        nama: _nama.text.trim(),
        urutan: semula?.urutan ?? 0,
        field: [for (final baris in _field) baris.hasil],
        bawaan: semula?.bawaan ?? false,
      ),
    );

    if (!mounted) return;
    context.pop(true);
  }

  void _beriTahu(String pesan, Color warna) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: warna,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: _isEditing ? 'Sunting Kategori' : 'Kategori Baru',
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AppButton(
          text: _menyimpan ? 'Menyimpan…' : 'Simpan',
          onPressed: _menyimpan ? null : _simpan,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              AppTextField(
                controller: _kode,
                labelText: 'Kode kategori',
                hintText: 'KLN',
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 6),
              Text(
                _isEditing
                    ? 'Mengubah kode akan memutus arsip lama dari kategori '
                          'ini. Ubah hanya bila kategorinya masih kosong.'
                    : 'Kode dipakai menyusun ID tag arsip, mis. BUD-KLN-1.',
                style: AppTypography.caption(fontSize: 11, height: 1.35),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _nama,
                labelText: 'Nama kategori',
                hintText: 'Kuliner Tradisional',
              ),
              const SizedBox(height: 24),
              _buildKepalaRincian(),
              const SizedBox(height: 10),
              if (_field.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: AppDekorasi.panel(garis: AppColors.border),
                  child: Text(
                    'Belum ada rincian. Kategori tanpa rincian tetap bisa '
                    'dipakai, arsipnya hanya menampilkan bagian umum.',
                    style: AppTypography.caption(fontSize: 11.5, height: 1.4),
                  ),
                )
              else
                for (var i = 0; i < _field.length; i++) _buildKartuField(i),
              const SizedBox(height: 10),
              AppButton.outlined(
                text: 'Tambah rincian',
                onPressed: _tambahField,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKepalaRincian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RINCIAN KHAS', style: AppTypography.eyebrow()),
        const SizedBox(height: 3),
        Text(
          'Isian tambahan yang muncul di form konten dan di halaman detail '
          'arsip kategori ini.',
          style: AppTypography.caption(fontSize: 11, height: 1.35),
        ),
      ],
    );
  }

  Widget _buildKartuField(int index) {
    final baris = _field[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'RINCIAN ${index + 1}',
                  style: AppTypography.eyebrow(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _hapusField(index),
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.error,
                tooltip: 'Hapus rincian',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              children: [
                AppTextField(
                  controller: baris.label,
                  labelText: 'Label',
                  hintText: 'Bahan Utama',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: baris.kunci,
                  labelText: 'Kunci',
                  hintText: 'bahanUtama',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: baris.petunjuk,
                  labelText: 'Petunjuk isian',
                  hintText: 'Satu bahan per baris',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bentuk isian',
            style: AppTypography.labelBold(fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              for (final tipe in TipeField.values)
                ChoiceChip(
                  label: Text(
                    labelTipeField(tipe),
                    style: AppTypography.caption(
                      fontSize: 11.5,
                      color: baris.tipe == tipe
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  selected: baris.tipe == tipe,
                  onSelected: (_) => setState(() => baris.tipe = tipe),
                  showCheckmark: false,
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDekorasi.radiusKecil,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
