import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_image.dart';

// Potongan isian yang dipakai berulang di form usulan. Diletakkan di sini,
// bukan di core/widgets, karena hanya alur kontribusi yang memakainya.

// Judul satu bagian form beserta keterangan singkatnya.
class JudulBagian extends StatelessWidget {
  final String teks;
  final String? keterangan;

  const JudulBagian({super.key, required this.teks, this.keterangan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(teks.toUpperCase(), style: AppTypography.eyebrow()),
          if (keterangan != null) ...[
            const SizedBox(height: 3),
            Text(
              keterangan!,
              style: AppTypography.caption(fontSize: 11, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class IsianTeks extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? petunjuk;
  final int baris;
  final bool wajib;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  // Menolak apa pun selain angka saat diketik, bukan sekadar mengubah papan
  // tombol yang masih bisa diakali.
  final bool hanyaAngka;

  final int? panjangMaksimum;

  const IsianTeks({
    super.key,
    required this.label,
    required this.controller,
    this.petunjuk,
    this.baris = 1,
    this.wajib = false,
    this.keyboard,
    this.validator,
    this.onChanged,
    this.hanyaAngka = false,
    this.panjangMaksimum,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.labelBold(fontSize: 13)),
              if (wajib)
                Text(
                  ' *',
                  style: AppTypography.labelBold(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: baris,
            keyboardType: keyboard,
            onChanged: onChanged,
            maxLength: panjangMaksimum,
            inputFormatters: [
              if (hanyaAngka) FilteringTextInputFormatter.digitsOnly,
            ],
            validator:
                validator ??
                (wajib
                    ? (nilai) => (nilai ?? '').trim().isEmpty
                          ? '$label belum diisi'
                          : null
                    : null),
            style: AppTypography.caption(
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              counterText: '',
              helperText: petunjuk,
              helperMaxLines: 2,
              helperStyle: AppTypography.caption(fontSize: 10.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PilihanDropdown<T> extends StatelessWidget {
  final String label;
  final T? nilai;
  final List<DropdownMenuItem<T>> pilihan;
  final ValueChanged<T?> onChanged;
  final String? petunjuk;
  final bool wajib;

  const PilihanDropdown({
    super.key,
    required this.label,
    required this.nilai,
    required this.pilihan,
    required this.onChanged,
    this.petunjuk,
    this.wajib = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTypography.labelBold(fontSize: 13)),
              if (wajib)
                Text(
                  ' *',
                  style: AppTypography.labelBold(
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            initialValue: nilai,
            isExpanded: true,
            items: pilihan,
            onChanged: onChanged,
            validator: wajib
                ? (v) => v == null ? '$label belum dipilih' : null
                : null,
            style: AppTypography.caption(
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              helperText: petunjuk,
              helperMaxLines: 2,
              helperStyle: AppTypography.caption(fontSize: 10.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDekorasi.radiusKecil,
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pemilih gambar beserta pratinjaunya. Path yang dipilih milik perangkat ini.
class PemilihGambarUsulan extends StatelessWidget {
  final String? path;
  final VoidCallback onPilih;
  final VoidCallback onHapus;

  const PemilihGambarUsulan({
    super.key,
    required this.path,
    required this.onPilih,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final ada = (path ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gambar', style: AppTypography.labelBold(fontSize: 13)),
          const SizedBox(height: 6),
          if (ada)
            ClipRRect(
              borderRadius: AppDekorasi.radiusKartu,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: AppImageView(imagePath: path!, fit: BoxFit.cover),
              ),
            ),
          if (ada) const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDekorasi.radiusKecil,
                  ),
                ),
                onPressed: onPilih,
                icon: const Icon(
                  Icons.photo_library_outlined,
                  size: 17,
                  color: AppColors.primary,
                ),
                label: Text(
                  ada ? 'Ganti gambar' : 'Pilih gambar',
                  style: AppTypography.labelBold(
                    fontSize: 12.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (ada)
                TextButton.icon(
                  onPressed: onHapus,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 17,
                    color: AppColors.error,
                  ),
                  label: Text(
                    'Hapus',
                    style: AppTypography.labelBold(
                      fontSize: 12.5,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            'Boleh dikosongkan. Admin bisa melengkapinya saat meninjau.',
            style: AppTypography.caption(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

// Kotak satu entri berulang, mis. satu peristiwa atau satu soal, beserta
// tombol hapusnya.
class KotakEntri extends StatelessWidget {
  final String judul;
  final VoidCallback? onHapus;
  final List<Widget> children;

  const KotakEntri({
    super.key,
    required this.judul,
    required this.children,
    this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 2),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(judul, style: AppTypography.eyebrow(fontSize: 9.5)),
              ),
              if (onHapus != null)
                GestureDetector(
                  onTap: onHapus,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
