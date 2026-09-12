import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/storage/preference_handler.dart';
import '../../../core/storage/user_session.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/komunitas/data/models/komunitas_model.dart';
import 'package:renjana/features/komunitas/data/repositories/komunitas_repository.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';

// section model item pilihan arsip
class _ItemPilihanArsip {
  final String kodeTag;
  final String judul;
  final String kategori;
  final String? jenis;
  final String? provinsi;

  const _ItemPilihanArsip({
    required this.kodeTag,
    required this.judul,
    required this.kategori,
    this.jenis,
    this.provinsi,
  });
}

// section halaman form diskusi
class FormDiskusiPage extends StatefulWidget {
  final String? refArsipAwal;

  const FormDiskusiPage({super.key, this.refArsipAwal});

  @override
  State<FormDiskusiPage> createState() => _FormDiskusiPageState();
}

class _FormDiskusiPageState extends State<FormDiskusiPage> {
  final _formKey = GlobalKey<FormState>();
  final KomunitasRepository _repository = KomunitasRepository();
  final BudayaRepository _budayaRepository = BudayaRepository();
  final SejarahRepository _sejarahRepository = SejarahRepository();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();

  String? _selectedArsipKode;
  String? _selectedArsipJudul;
  String? _selectedArsipKategori;

  String _kategori = 'Budaya';
  bool _menyimpan = false;

  static const List<String> _kategoriList = [
    'Budaya',
    'Sejarah',
    'Kedaerahan',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.refArsipAwal != null && widget.refArsipAwal!.trim().isNotEmpty) {
      _selectedArsipKode = widget.refArsipAwal!.trim();
      _muatRefAwal(_selectedArsipKode!);
    }
  }

  // section muat detail ref arsip awal
  Future<void> _muatRefAwal(String kode) async {
    if (kode.startsWith('HIS') || kode.contains('history')) {
      final item = await _sejarahRepository.getSejarahByKodeTag(kode);
      if (item != null && mounted) {
        setState(() {
          _selectedArsipJudul = item.judul;
          _selectedArsipKategori = 'Sejarah';
        });
      }
    } else {
      final item = await _budayaRepository.getBudayaByKodeTag(kode);
      if (item != null && mounted) {
        setState(() {
          _selectedArsipJudul = item.judul;
          _selectedArsipKategori = 'Budaya';
        });
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: AppColors.textMuted,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  bool get _isAdmin =>
      PreferenceHandler.isAdmin ||
      (PreferenceHandler.user?.isAdminAccount ?? false);

  String _formatSisaWaktu(Duration d) {
    final jam = d.inHours;
    final menit = d.inMinutes % 60;
    if (jam > 0) {
      return '$jam jam ${menit > 0 ? '$menit menit' : ''}';
    }
    return '$menit menit';
  }

  // section buka pemilih arsip
  Future<void> _bukaPilihArsip() async {
    final hasil = await showModalBottomSheet<_ItemPilihanArsip>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalPilihArsip(
        budayaRepository: _budayaRepository,
        sejarahRepository: _sejarahRepository,
      ),
    );

    if (hasil != null && mounted) {
      setState(() {
        _selectedArsipKode = hasil.kodeTag;
        _selectedArsipJudul = hasil.judul;
        _selectedArsipKategori = hasil.kategori;
      });
    }
  }

  // section simpan diskusi
  Future<void> _simpanDiskusi() async {
    if (!_formKey.currentState!.validate() || _menyimpan) return;

    final userId = idAkunAktif;
    if (!_isAdmin && userId > 0) {
      final terakhir = await _repository.getWaktuDiskusiTerakhir(userId);
      if (terakhir != null) {
        final selisih = DateTime.now().difference(terakhir);
        const batas = Duration(hours: 10);
        if (selisih < batas) {
          final sisa = batas - selisih;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anda dapat membuat diskusi baru dalam ${_formatSisaWaktu(sisa)} lagi.',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    setState(() => _menyimpan = true);

    final user = PreferenceHandler.user;
    final nama = user?.nama.isNotEmpty == true
        ? user!.nama
        : PreferenceHandler.userName;

    final kini = DateTime.now();
    await _repository.tambahDiskusi(
      DiskusiModel(
        userId: userId,
        penulis: nama.isNotEmpty ? nama : 'Pengguna Renjana',
        judul: _judulController.text.trim(),
        isi: _isiController.text.trim(),
        kategori: _kategori,
        refArsip: _selectedArsipKode,
        dibuatPada: kini,
        diperbaruiPada: kini,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mulai Diskusi',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Bahasan',
                style: AppTypography.labelBold(fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: _inputDecoration(''),
                items: _kategoriList
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(
                          k,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _kategori = val);
                },
              ),
              const SizedBox(height: 16),

              Text(
                'Judul Diskusi atau Pertanyaan',
                style: AppTypography.labelBold(fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration(
                  'Contoh: Mengapa Tari Saman ditarikan berkelompok?',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Isi Bahasan atau Ulasan',
                style: AppTypography.labelBold(fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _isiController,
                maxLines: 6,
                decoration: _inputDecoration(
                  'Tuliskan latar belakang pertanyaan, pemikiran, atau ulasan yang ingin Anda diskusikan bersama komunitas...',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Isi bahasan tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Tautan Arsip (Opsional)',
                style: AppTypography.labelBold(fontSize: 13),
              ),
              const SizedBox(height: 6),
              if (_selectedArsipKode == null)
                GestureDetector(
                  onTap: _bukaPilihArsip,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pilih arsip dari basis data...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderPrimary),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedArsipJudul ?? _selectedArsipKode!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_selectedArsipKode • ${_selectedArsipKategori ?? 'Arsip'}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        tooltip: 'Hapus Tautan',
                        onPressed: () {
                          setState(() {
                            _selectedArsipKode = null;
                            _selectedArsipJudul = null;
                            _selectedArsipKategori = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _menyimpan ? null : _simpanDiskusi,
                  child: _menyimpan
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Terbitkan Diskusi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// section modal pilih arsip
class _ModalPilihArsip extends StatefulWidget {
  final BudayaRepository budayaRepository;
  final SejarahRepository sejarahRepository;

  const _ModalPilihArsip({
    required this.budayaRepository,
    required this.sejarahRepository,
  });

  @override
  State<_ModalPilihArsip> createState() => _ModalPilihArsipState();
}

class _ModalPilihArsipState extends State<_ModalPilihArsip> {
  final TextEditingController _cariController = TextEditingController();
  List<_ItemPilihanArsip> _semuaArsip = [];
  String _filterKategori = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatArsip();
  }

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  Future<void> _muatArsip() async {
    try {
      final daftarBudaya = await widget.budayaRepository.getAllBudaya();
      final daftarSejarah = await widget.sejarahRepository.getAllSejarah();

      final list = <_ItemPilihanArsip>[];
      for (final b in daftarBudaya) {
        list.add(
          _ItemPilihanArsip(
            kodeTag: b.kodeTag,
            judul: b.judul,
            kategori: 'Budaya',
            jenis: b.kategoriLabel,
            provinsi: b.provinsi,
          ),
        );
      }
      for (final s in daftarSejarah) {
        list.add(
          _ItemPilihanArsip(
            kodeTag: s.kodeTag,
            judul: s.judul,
            kategori: 'Sejarah',
            jenis: s.namaPeristiwaLabel,
            provinsi: s.provinsi,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _semuaArsip = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<_ItemPilihanArsip> get _arsipTerfilter {
    var list = _semuaArsip;
    if (_filterKategori != 'Semua') {
      list = list.where((a) => a.kategori == _filterKategori).toList();
    }
    final q = _cariController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((a) {
        return a.judul.toLowerCase().contains(q) ||
            a.kodeTag.toLowerCase().contains(q) ||
            (a.provinsi != null && a.provinsi!.toLowerCase().contains(q));
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final list = _arsipTerfilter;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih Arsip Basis Data',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _cariController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari judul, kode tag, atau wilayah...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: _cariController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _cariController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['Semua', 'Budaya', 'Sejarah'].map((kat) {
                final isSelected = _filterKategori == kat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(kat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _filterKategori = kat);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderLight),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : list.isEmpty
                    ? Center(
                        child: Text(
                          'Arsip tidak ditemukan.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        itemCount: list.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: AppColors.borderLight),
                        itemBuilder: (context, index) {
                          final item = list[index];
                          final isBudaya = item.kategori == 'Budaya';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isBudaya
                                    ? AppColors.primary.withAlpha(20)
                                    : Colors.brown.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isBudaya
                                    ? Icons.palette_outlined
                                    : Icons.history_edu_rounded,
                                size: 20,
                                color: isBudaya
                                    ? AppColors.primary
                                    : AppColors.primaryDark,
                              ),
                            ),
                            title: Text(
                              item.judul,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${item.kodeTag} • ${item.kategori}${item.provinsi != null ? ' • ${item.provinsi}' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
