import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/budaya_kategori.dart';
import '../../../core/constants/wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import 'package:renjana/core/utils/image_picker_helper.dart';
import 'package:renjana/features/kontribusi/data/models/blok_konten_model.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';
import 'package:renjana/features/kontribusi/data/repositories/usulan_repository.dart';
import 'widgets/editor_blok_konten.dart';
import 'widgets/isian_form.dart';

class FormUsulanPage extends StatefulWidget {
  final Usulan? usulanAwal;
  final bool sebagaiAdmin;

  const FormUsulanPage({super.key, this.usulanAwal, this.sebagaiAdmin = false});

  @override
  State<FormUsulanPage> createState() => _FormUsulanPageState();
}

class _FormUsulanPageState extends State<FormUsulanPage> {
  final UsulanRepository _repository = UsulanRepository();
  final _formKey = GlobalKey<FormState>();

  // umum
  late JenisUsulan _jenis;
  String? _provinsi;
  String? _gambar;
  String _jenisMedia = 'gambar';
  final _mediaUrl = TextEditingController();
  bool _menyimpan = false;

  // sejarah
  final _judulSejarah = TextEditingController();
  final _subtitle = TextEditingController();
  final _tanggal = TextEditingController();
  final _ringkasan = TextEditingController();
  String _periode = periodeSejarahList.first.kode;
  String _jenisPeristiwa = peristiwaSejarahList.first.kode;
  final Map<String, TextEditingController> _detailPeristiwa = {};
  final List<_EntriPeristiwa> _peristiwa = [];
  List<BlokKontenModel> _blokKontenSejarah = [];

  // budaya
  final _judulBudaya = TextEditingController();
  final _tagline = TextEditingController();
  final _deskripsi = TextEditingController();
  final _maknaSpiritual = TextEditingController();
  final _konteksBudaya = TextEditingController();
  String _kategoriBudaya = budayaKategoriList.first.kode;
  bool _destinasi = false;
  List<BlokKontenModel> _blokKontenBudaya = [];

  // Isian khas kategori budaya, dibuat sekali untuk seluruh kategori supaya
  // isian yang sudah diketik tidak hilang saat kategorinya diganti.
  final Map<String, TextEditingController> _detail = {};


  // Menyunting usulan yang sudah tersimpan, berbeda dari usulan koreksi yang
  // isinya baru disalin dari arsip dan belum punya id.
  bool get _memperbaiki => widget.usulanAwal?.id != null;

  bool get _koreksi => widget.usulanAwal?.koreksi ?? false;

  @override
  void initState() {
    super.initState();

    for (final kategori in budayaKategoriList) {
      for (final field in kategori.field) {
        _detail.putIfAbsent(field.kunci, () => TextEditingController());
      }
    }

    for (final peristiwa in peristiwaSejarahList) {
      for (final field in peristiwa.field) {
        _detailPeristiwa.putIfAbsent(
          field.kunci,
          () => TextEditingController(),
        );
      }
    }

    final awal = widget.usulanAwal;
    _jenis = awal?.jenis ?? JenisUsulan.budaya;
    if (awal != null) {
      _muatDariUsulan(awal);
    } else {
      _peristiwa.add(_EntriPeristiwa());
    }
  }

  void _muatDariUsulan(Usulan awal) {
    _provinsi = awal.provinsi.isEmpty ? null : awal.provinsi;
    _gambar = awal.teks(KunciUsulan.gambar).isEmpty
        ? null
        : awal.teks(KunciUsulan.gambar);
    final jm = awal.teks(KunciUsulan.jenisMedia);
    if (jm.isNotEmpty) _jenisMedia = jm;
    _mediaUrl.text = awal.teks(KunciUsulan.mediaUrl);

    switch (awal.jenis) {
      case JenisUsulan.sejarah:
        _judulSejarah.text = awal.teks(KunciUsulan.judul);
        _subtitle.text = awal.teks(KunciUsulan.subtitle);
        _tanggal.text = awal.teks(KunciUsulan.tanggalKey);
        _ringkasan.text = awal.teks(KunciUsulan.ringkasan);
        final prd = awal.teks(KunciUsulan.periode);
        if (periodeByKode(prd) != null) _periode = prd;
        final jns = awal.teks(KunciUsulan.jenisPeristiwa);
        if (peristiwaByKode(jns) != null) _jenisPeristiwa = jns;

        final detailP = awal.isi[KunciUsulan.detailPeristiwa];
        if (detailP is Map) {
          detailP.forEach((kunci, nilai) {
            final controller = _detailPeristiwa['$kunci'];
            if (controller == null) return;
            controller.text = nilai is List
                ? nilai.join('\n')
                : nilai.toString();
          });
        }

        for (final p in awal.daftar(KunciUsulan.alurPeristiwa)) {
          _peristiwa.add(_EntriPeristiwa.dariMap(p));
        }
        if (_peristiwa.isEmpty) _peristiwa.add(_EntriPeristiwa());
        _blokKontenSejarah = List.from(awal.daftarBlokKonten);

      case JenisUsulan.budaya:
        _judulBudaya.text = awal.teks(KunciUsulan.judul);
        _tagline.text = awal.teks(KunciUsulan.tagline);
        _deskripsi.text = awal.teks(KunciUsulan.deskripsi);
        _maknaSpiritual.text = awal.teks(KunciUsulan.maknaSpiritual);
        _konteksBudaya.text = awal.teks(KunciUsulan.konteksBudaya);
        _destinasi = awal.isi[KunciUsulan.destinasi] == true;
        final kode = awal.teks(KunciUsulan.kategori);
        if (kategoriByKode(kode) != null) _kategoriBudaya = kode;

        final detail = awal.isi[KunciUsulan.detailKategori];
        if (detail is Map) {
          detail.forEach((kunci, nilai) {
            final controller = _detail['$kunci'];
            if (controller == null) return;
            controller.text = nilai is List
                ? nilai.join('\n')
                : nilai.toString();
          });
        }
        _blokKontenBudaya = List.from(awal.daftarBlokKonten);

    }

    if (_peristiwa.isEmpty) _peristiwa.add(_EntriPeristiwa());
  }

  @override
  void dispose() {
    for (final c in [
      _judulSejarah,
      _subtitle,
      _tanggal,
      _ringkasan,
      _judulBudaya,
      _tagline,
      _deskripsi,
      _maknaSpiritual,
      _konteksBudaya,
      _mediaUrl,
      ..._detail.values,
      ..._detailPeristiwa.values,
    ]) {
      c.dispose();
    }
    for (final p in _peristiwa) {
      p.buang();
    }
    super.dispose();
  }

  // Penanda besar di halaman detail memakai format 15.11.46, jadi diturunkan
  // dari tanggal supaya pengusul tidak perlu menghitung sendiri.
  void _isiPenandaDariTanggal(String nilai) {
    final angka = nilai.trim();
    if (angka.length != 6) return;

    final penanda =
        '${angka.substring(0, 2)}.${angka.substring(2, 4)}'
        '.${angka.substring(4, 6)}';
    if (_subtitle.text.trim() == penanda) return;
    setState(() => _subtitle.text = penanda);
  }

  Future<void> _pilihGambar() async {
    final path = await pilihGambarDariGaleri(context);
    if (path == null || !mounted) return;
    setState(() => _gambar = path);
  }

  // Muatan disusun sesuai jenisnya; kunci-kuncinya dari KunciUsulan supaya
  // panel admin membaca nama yang sama.
  Map<String, dynamic> _rakitMuatan() {
    final isi = <String, dynamic>{};
    if ((_gambar ?? '').trim().isNotEmpty) {
      isi[KunciUsulan.gambar] = _gambar!.trim();
    }

    switch (_jenis) {
      case JenisUsulan.sejarah:
        isi[KunciUsulan.judul] = _judulSejarah.text.trim();
        isi[KunciUsulan.subtitle] = _subtitle.text.trim();
        isi[KunciUsulan.tanggalKey] = _tanggal.text.trim();
        isi[KunciUsulan.ringkasan] = _ringkasan.text.trim();
        isi[KunciUsulan.periode] = _periode;
        isi[KunciUsulan.jenisPeristiwa] = _jenisPeristiwa;
        isi[KunciUsulan.detailPeristiwa] = _rakitDetailPeristiwa();
        isi[KunciUsulan.jenisMedia] = _jenisMedia;
        isi[KunciUsulan.mediaUrl] = _jenisMedia == 'gambar'
            ? ''
            : _mediaUrl.text.trim();
        isi[KunciUsulan.blokKonten] =
            BlokKontenModel.listToMapList(_blokKontenSejarah);
        final daftar = _peristiwa
            .map((p) => p.toMap())
            .where((m) => (m['judul'] as String).isNotEmpty)
            .toList();
        if (daftar.isNotEmpty) isi[KunciUsulan.alurPeristiwa] = daftar;

      case JenisUsulan.budaya:
        isi[KunciUsulan.judul] = _judulBudaya.text.trim();
        isi[KunciUsulan.kategori] = _kategoriBudaya;
        isi[KunciUsulan.tagline] = _tagline.text.trim();
        isi[KunciUsulan.deskripsi] = _deskripsi.text.trim();
        isi[KunciUsulan.maknaSpiritual] = _maknaSpiritual.text.trim();
        isi[KunciUsulan.konteksBudaya] = _konteksBudaya.text.trim();
        isi[KunciUsulan.destinasi] = _destinasi;
        isi[KunciUsulan.detailKategori] = _rakitDetail();
        isi[KunciUsulan.jenisMedia] = _jenisMedia;
        isi[KunciUsulan.mediaUrl] = _jenisMedia == 'gambar'
            ? ''
            : _mediaUrl.text.trim();
        isi[KunciUsulan.blokKonten] =
            BlokKontenModel.listToMapList(_blokKontenBudaya);
    }
    return isi;
  }

  // Hanya field milik jenis peristiwa terpilih yang ikut, dan yang kosong dibuang.
  Map<String, dynamic> _rakitDetailPeristiwa() {
    final hasil = <String, dynamic>{};
    for (final field in fieldPeristiwa(_jenisPeristiwa)) {
      final teks = _detailPeristiwa[field.kunci]?.text.trim() ?? '';
      if (teks.isEmpty) continue;

      if (field.tipe == TipeField.daftar) {
        final baris = teks
            .split('\n')
            .map((b) => b.trim())
            .where((b) => b.isNotEmpty)
            .toList();
        if (baris.isNotEmpty) hasil[field.kunci] = baris;
      } else {
        hasil[field.kunci] = teks;
      }
    }
    return hasil;
  }

  // Hanya field milik kategori terpilih yang ikut, dan yang kosong dibuang.
  Map<String, dynamic> _rakitDetail() {
    final hasil = <String, dynamic>{};
    for (final field in fieldKategori(_kategoriBudaya)) {
      final teks = _detail[field.kunci]?.text.trim() ?? '';
      if (teks.isEmpty) continue;

      if (field.tipe == TipeField.daftar) {
        final baris = teks
            .split('\n')
            .map((b) => b.trim())
            .where((b) => b.isNotEmpty)
            .toList();
        if (baris.isNotEmpty) hasil[field.kunci] = baris;
      } else {
        hasil[field.kunci] = teks;
      }
    }
    return hasil;
  }

  String get _judulRingkas {
    switch (_jenis) {
      case JenisUsulan.sejarah:
        return _judulSejarah.text.trim();
      case JenisUsulan.budaya:
        return _judulBudaya.text.trim();
    }
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) {
      _beriTahu('Masih ada isian wajib yang kosong.', gagal: true);
      return;
    }

    // Batas harian hanya berlaku untuk usulan baru dari pengguna; memperbaiki
    // usulan lama maupun suntingan admin tidak memakan jatah.
    if (!_memperbaiki &&
        !widget.sebagaiAdmin &&
        !await _repository.masihBolehMengusulkan()) {
      if (!mounted) return;
      _beriTahu(
        'Jatah usulan hari ini sudah habis, maksimal '
        '${UsulanRepository.batasUsulanHarian} per hari. Coba lagi besok.',
        gagal: true,
      );
      return;
    }
    if (!mounted) return;

    setState(() => _menyimpan = true);

    // upload gambar utama ke cloudinary
    if (_gambar != null && _gambar!.trim().isNotEmpty && !_gambar!.startsWith('http')) {
      final berkas = File(_gambar!.trim());
      if (berkas.existsSync()) {
        final res = await CloudinaryService().uploadImage(berkas, subFolder: 'usulan');
        if (res.isSuccess && res.secureUrl != null) {
          _gambar = res.secureUrl;
        }
      }
    }

    // upload gambar peristiwa ke cloudinary
    for (final p in _peristiwa) {
      if (p.gambar != null && p.gambar!.trim().isNotEmpty && !p.gambar!.startsWith('http')) {
        final berkas = File(p.gambar!.trim());
        if (berkas.existsSync()) {
          final res = await CloudinaryService().uploadImage(berkas, subFolder: 'usulan');
          if (res.isSuccess && res.secureUrl != null) {
            p.gambar = res.secureUrl;
          }
        }
      }
    }

    final sekarang = DateTime.now();
    final awal = widget.usulanAwal;

    final usulan = Usulan(
      id: awal?.id,
      jenis: _jenis,
      maksud: awal?.maksud ?? MaksudUsulan.baru,
      targetKodeTag: awal?.targetKodeTag ?? '',
      provinsi: _provinsi ?? '',
      judul: _judulRingkas,
      isi: _rakitMuatan(),
      dibuatPada: awal?.dibuatPada ?? sekarang,
      diperbaruiPada: sekarang,
    );

    final berhasil = widget.sebagaiAdmin
        ? await _repository.perbaruiSebagaiAdmin(usulan)
        : (_memperbaiki
              ? await _repository.perbarui(usulan)
              : await _repository.kirim(usulan));
    if (!mounted) return;
    setState(() => _menyimpan = false);

    if (!berhasil) {
      _beriTahu('Usulan gagal dikirim. Coba lagi.', gagal: true);
      return;
    }

    context.pop(true);
    _beriTahu(
      widget.sebagaiAdmin
          ? 'Usulan diperbarui'
          : (_memperbaiki
                ? 'Perbaikan terkirim, menunggu ditinjau lagi'
                : 'Usulan terkirim, menunggu ditinjau admin'),
    );
  }


  void _beriTahu(String pesan, {bool gagal = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: gagal ? AppColors.primaryDark : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(
        judul: widget.sebagaiAdmin
            ? 'Sunting Usulan'
            : (_koreksi
                  ? 'Usulkan Koreksi'
                  : (_memperbaiki ? 'Perbaiki Usulan' : 'Ajukan Usulan')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                if (_koreksi) ...[
                  _buildKeteranganKoreksi(),
                  const SizedBox(height: 20),
                ],

                if (!_memperbaiki && !_koreksi) ...[
                  const JudulBagian(
                    teks: 'Jenis Usulan',
                    keterangan:
                        'Pilih bentuk arsip yang ingin Anda usulkan. Isiannya '
                        'menyesuaikan pilihan ini.',
                  ),
                  _buildPilihanJenis(),
                  const SizedBox(height: 22),
                ],

                const JudulBagian(
                  teks: 'Asal Daerah',
                  keterangan:
                      'Provinsi tempat arsip ini berasal, bukan tempat Anda '
                      'tinggal sekarang.',
                ),
                PilihanDropdown<String>(
                  label: 'Provinsi',
                  nilai: _provinsi,
                  wajib: true,
                  pilihan: [
                    for (final p in semuaProvinsi)
                      DropdownMenuItem(value: p.nama, child: Text(p.nama)),
                  ],
                  onChanged: (nilai) => setState(() => _provinsi = nilai),
                ),
                const SizedBox(height: 8),

                ..._buildIsianJenis(),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDekorasi.radiusKecil,
                      ),
                    ),
                    onPressed: _menyimpan ? null : _kirim,
                    child: Text(
                      _menyimpan
                          ? 'Menyimpan…'
                          : (widget.sebagaiAdmin
                                ? 'Simpan Perubahan'
                                : (_memperbaiki
                                      ? 'Kirim Perbaikan'
                                      : 'Kirim Usulan')),
                      style: AppTypography.buttonText().copyWith(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.sebagaiAdmin
                      ? 'Perubahan tersimpan pada usulan. Terbitkan ulang dari '
                            'lembar tinjauan agar arsipnya ikut diperbarui.'
                      : 'Usulan akan ditinjau admin. Anda bisa memantau '
                            'statusnya di halaman Kontribusi Saya.',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Penanda bahwa yang sedang diisi adalah perbaikan arsip yang sudah terbit,
  // bukan arsip baru.
  Widget _buildKeteranganKoreksi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDekorasi.panelCapaian(AppColors.warning),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text('MENGOREKSI ARSIP', style: AppTypography.eyebrow()),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.usulanAwal?.targetKodeTag ?? '',
            style: AppTypography.labelBold(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Isian sudah terisi dengan data arsip yang sekarang. Ubah bagian '
            'yang keliru saja; yang Anda kosongkan akan dibiarkan seperti '
            'semula.',
            style: AppTypography.caption(fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPilihanJenis() {
    return Row(
      children: [
        for (final jenis in JenisUsulan.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _jenis = jenis),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: AppDekorasi.panel(
                  garis: _jenis == jenis ? AppColors.primary : AppColors.border,
                  tebal: _jenis == jenis ? 1.4 : 1,
                ),
                child: Column(
                  children: [
                    Icon(
                      jenis.ikon,
                      size: 22,
                      color: _jenis == jenis
                          ? AppColors.primary
                          : AppColors.surfaceMuted,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      jenis.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(
                        fontSize: 10.5,
                        fontWeight: _jenis == jenis
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _jenis == jenis
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (jenis != JenisUsulan.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  List<Widget> _buildIsianJenis() {
    switch (_jenis) {
      case JenisUsulan.sejarah:
        return _buildIsianSejarah();
      case JenisUsulan.budaya:
        return _buildIsianBudaya();
    }
  }

  List<Widget> _buildIsianSejarah() {
    final peristiwa = peristiwaByKode(_jenisPeristiwa);

    return [
      const JudulBagian(teks: 'Peristiwa Sejarah'),
      PilihanDropdown<String>(
        label: 'Periode / Era Sejarah',
        nilai: _periode,
        wajib: true,
        pilihan: [
          for (final p in periodeSejarahList)
            DropdownMenuItem(value: p.kode, child: Text(p.nama)),
        ],
        onChanged: (nilai) {
          if (nilai == null) return;
          setState(() => _periode = nilai);
        },
      ),
      PilihanDropdown<String>(
        label: 'Jenis Peristiwa',
        nilai: _jenisPeristiwa,
        wajib: true,
        pilihan: [
          for (final p in peristiwaSejarahList)
            DropdownMenuItem(value: p.kode, child: Text(p.nama)),
        ],
        onChanged: (nilai) {
          if (nilai == null) return;
          setState(() => _jenisPeristiwa = nilai);
        },
        petunjuk: 'Menentukan rincian data khas peristiwa di bawah.',
      ),
      IsianTeks(
        label: 'Judul',
        controller: _judulSejarah,
        wajib: true,
        petunjuk: 'Contoh: Perundingan Linggarjati',
      ),
      IsianTeks(
        label: 'Tanggal',
        controller: _tanggal,
        keyboard: TextInputType.number,
        hanyaAngka: true,
        panjangMaksimum: 6,
        petunjuk: 'Enam angka ddMMyy, mis. 151146. Boleh dikosongkan.',
        onChanged: _isiPenandaDariTanggal,
      ),
      IsianTeks(
        label: 'Penanda Tanggal',
        controller: _subtitle,
        petunjuk:
            'Angka besar di halaman detail, format 15.11.46. Terisi sendiri '
            'dari tanggal di atas.',
      ),
      IsianTeks(
        label: 'Ringkasan',
        controller: _ringkasan,
        baris: 5,
        wajib: true,
        petunjuk: 'Ceritakan peristiwanya dengan bahasa Anda sendiri.',
      ),
      PemilihGambarUsulan(
        path: _gambar,
        onPilih: _pilihGambar,
        onHapus: () => setState(() => _gambar = null),
      ),
      PilihanDropdown<String>(
        label: 'Format Media Utama',
        nilai: _jenisMedia,
        wajib: true,
        pilihan: const [
          DropdownMenuItem(value: 'gambar', child: Text('Foto / Gambar Saja')),
          DropdownMenuItem(
            value: 'video',
            child: Text('Video Berkas / Galeri'),
          ),
          DropdownMenuItem(
            value: 'youtube',
            child: Text('Video Tautan YouTube'),
          ),
        ],
        onChanged: (nilai) {
          if (nilai == null) return;
          setState(() => _jenisMedia = nilai);
        },
      ),
      if (_jenisMedia != 'gambar')
        IsianTeks(
          label: _jenisMedia == 'youtube'
              ? 'Tautan Video YouTube'
              : 'Path / URL Video',
          controller: _mediaUrl,
          petunjuk: _jenisMedia == 'youtube'
              ? 'Contoh: https://www.youtube.com/watch?v=...'
              : 'Contoh: https://... atau path berkas video',
        ),

      if (peristiwa != null && peristiwa.field.isNotEmpty) ...[
        JudulBagian(
          teks: 'Rincian ${peristiwa.nama}',
          keterangan:
              'Isian khas jenis peristiwa. Boleh diisi sebagian atau dilewati.',
        ),
        for (final field in peristiwa.field)
          IsianTeks(
            label: field.label,
            controller: _detailPeristiwa[field.kunci]!,
            baris: field.tipe == TipeField.daftar
                ? 4
                : (field.tipe == TipeField.teksPanjang ? 3 : 1),
            petunjuk: field.tipe == TipeField.daftar
                ? '${field.petunjuk ?? ''} (tulis satu entri per baris)'
                : field.petunjuk,
          ),
      ],

      const JudulBagian(
        teks: 'Alur Peristiwa',
        keterangan:
            'Boleh dilewati. Isi bila Anda tahu urutan kejadiannya secara '
            'rinci.',
      ),
      ...List.generate(_peristiwa.length, (i) {
        final entri = _peristiwa[i];
        return KotakEntri(
          judul: 'PERISTIWA ${i + 1}',
          onHapus: _peristiwa.length > 1
              ? () => setState(() => _peristiwa.removeAt(i).buang())
              : null,
          children: [
            IsianTeks(label: 'Tanggal', controller: entri.tanggal),
            IsianTeks(label: 'Judul', controller: entri.judul),
            IsianTeks(
              label: 'Keterangan',
              controller: entri.keterangan,
              baris: 3,
            ),
            PemilihGambarUsulan(
              path: entri.gambar,
              onPilih: () async {
                final path = await pilihGambarDariGaleri(context);
                if (path == null || !mounted) return;
                setState(() => entri.gambar = path);
              },
              onHapus: () => setState(() => entri.gambar = null),
            ),
          ],
        );
      }),
      _buildTombolTambah(
        'Tambah peristiwa',
        () => setState(() => _peristiwa.add(_EntriPeristiwa())),
      ),
      const SizedBox(height: 18),
      EditorBlokKonten(
        daftarAwal: _blokKontenSejarah,
        onChanged: (list) => _blokKontenSejarah = List.from(list),
      ),
    ];
  }

  List<Widget> _buildIsianBudaya() {
    final kategori = kategoriByKode(_kategoriBudaya);

    return [
      const JudulBagian(teks: 'Warisan Budaya'),
      PilihanDropdown<String>(
        label: 'Kategori',
        nilai: _kategoriBudaya,
        wajib: true,
        pilihan: [
          for (final k in budayaKategoriList)
            DropdownMenuItem(value: k.kode, child: Text(k.nama)),
        ],
        onChanged: (nilai) {
          if (nilai == null) return;
          setState(() => _kategoriBudaya = nilai);
        },
        petunjuk: 'Menentukan isian rinci yang muncul di bawah.',
      ),
      IsianTeks(
        label: 'Nama',
        controller: _judulBudaya,
        wajib: true,
        petunjuk: 'Contoh: Tari Piring',
      ),
      IsianTeks(
        label: 'Tagline',
        controller: _tagline,
        baris: 2,
        petunjuk: 'Satu kalimat yang menangkap intinya.',
      ),
      IsianTeks(
        label: 'Deskripsi',
        controller: _deskripsi,
        baris: 5,
        wajib: true,
      ),
      PemilihGambarUsulan(
        path: _gambar,
        onPilih: _pilihGambar,
        onHapus: () => setState(() => _gambar = null),
      ),
      PilihanDropdown<String>(
        label: 'Format Media Utama',
        nilai: _jenisMedia,
        wajib: true,
        pilihan: const [
          DropdownMenuItem(value: 'gambar', child: Text('Foto / Gambar Saja')),
          DropdownMenuItem(
            value: 'video',
            child: Text('Video Berkas / Galeri'),
          ),
          DropdownMenuItem(
            value: 'youtube',
            child: Text('Video Tautan YouTube'),
          ),
        ],
        onChanged: (nilai) {
          if (nilai == null) return;
          setState(() => _jenisMedia = nilai);
        },
      ),
      if (_jenisMedia != 'gambar')
        IsianTeks(
          label: _jenisMedia == 'youtube'
              ? 'Tautan Video YouTube'
              : 'Path / URL Video',
          controller: _mediaUrl,
          petunjuk: _jenisMedia == 'youtube'
              ? 'Contoh: https://www.youtube.com/watch?v=...'
              : 'Contoh: https://... atau path berkas video',
        ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => setState(() => _destinasi = !_destinasi),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(
                _destinasi
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: _destinasi ? AppColors.primary : AppColors.surfaceMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tempat ini bisa dikunjungi wisatawan',
                  style: AppTypography.caption(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      if (kategori != null && kategori.field.isNotEmpty) ...[
        JudulBagian(
          teks: 'Rincian ${kategori.nama}',
          keterangan:
              'Isian ini menyesuaikan kategori yang dipilih. Boleh diisi '
              'sebagian saja.',
        ),
        ...kategori.field.map((field) {
          final controller = _detail[field.kunci];
          if (controller == null) return const SizedBox.shrink();
          final daftar = field.tipe == TipeField.daftar;

          return IsianTeks(
            label: field.label,
            controller: controller,
            baris: daftar ? 4 : (field.tipe == TipeField.teksPanjang ? 4 : 1),
            petunjuk: daftar ? 'Satu baris untuk satu entri' : field.petunjuk,
          );
        }),
      ],

      const JudulBagian(teks: 'Makna dan Konteks', keterangan: 'Opsional.'),
      IsianTeks(
        label: 'Makna Spiritual',
        controller: _maknaSpiritual,
        baris: 4,
      ),
      IsianTeks(label: 'Konteks Budaya', controller: _konteksBudaya, baris: 4),
      const SizedBox(height: 18),
      EditorBlokKonten(
        daftarAwal: _blokKontenBudaya,
        onChanged: (list) => _blokKontenBudaya = List.from(list),
      ),
    ];
  }


  Widget _buildTombolTambah(String teks, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: AppDekorasi.radiusKecil,
            ),
          ),
          onPressed: onTap,
          icon: const Icon(
            Icons.add_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          label: Text(
            teks,
            style: AppTypography.labelBold(
              fontSize: 12.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

// Satu baris alur peristiwa selagi diisi di form.
class _EntriPeristiwa {
  final TextEditingController tanggal = TextEditingController();
  final TextEditingController judul = TextEditingController();
  final TextEditingController keterangan = TextEditingController();
  String? gambar;

  _EntriPeristiwa();

  factory _EntriPeristiwa.dariMap(Map<String, dynamic> map) {
    final entri = _EntriPeristiwa();
    entri.tanggal.text = map['tanggal']?.toString() ?? '';
    entri.judul.text = map['judul']?.toString() ?? '';
    entri.keterangan.text = map['keterangan']?.toString() ?? '';
    final gambar = map['gambar']?.toString() ?? '';
    entri.gambar = gambar.isEmpty ? null : gambar;
    return entri;
  }

  Map<String, dynamic> toMap() => {
    'tanggal': tanggal.text.trim(),
    'judul': judul.text.trim(),
    'keterangan': keterangan.text.trim(),
    'gambar': gambar ?? '',
  };

  void buang() {
    tanggal.dispose();
    judul.dispose();
    keterangan.dispose();
  }
}


