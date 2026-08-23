import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/models/komunitas_model.dart';
import '../../data/repositories/komunitas_repository.dart';
import '../../data/repositories/pemilik_akun.dart';
import '../../services/preference_handler.dart';

class FormDiskusiPage extends StatefulWidget {
  final String? refArsipAwal;

  const FormDiskusiPage({super.key, this.refArsipAwal});

  @override
  State<FormDiskusiPage> createState() => _FormDiskusiPageState();
}

class _FormDiskusiPageState extends State<FormDiskusiPage> {
  final _formKey = GlobalKey<FormState>();
  final KomunitasRepository _repository = KomunitasRepository();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _refArsipController = TextEditingController();

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
    if (widget.refArsipAwal != null) {
      _refArsipController.text = widget.refArsipAwal!;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _refArsipController.dispose();
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

  Future<void> _simpanDiskusi() async {
    if (!_formKey.currentState!.validate() || _menyimpan) return;

    setState(() => _menyimpan = true);

    final user = PreferenceHandler.user;
    final nama = user?.nama.isNotEmpty == true
        ? user!.nama
        : PreferenceHandler.userName;

    final kini = DateTime.now();
    await _repository.tambahDiskusi(
      DiskusiModel(
        userId: idAkunAktif,
        penulis: nama.isNotEmpty ? nama : 'Pengguna Renjana',
        judul: _judulController.text.trim(),
        isi: _isiController.text.trim(),
        kategori: _kategori,
        refArsip: _refArsipController.text.trim().isEmpty
            ? null
            : _refArsipController.text.trim(),
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
              TextFormField(
                controller: _refArsipController,
                decoration: _inputDecoration(
                  'Contoh: BUD-SNJT-1 atau HIS-01',
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
