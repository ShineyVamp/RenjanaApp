import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dekorasi.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/budaya_kategori.dart';
import '../../../core/constants/kuis_kategori.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/models/usulan_model.dart';

// Isi usulan dalam bentuk baca-saja. Dipakai halaman detail usulan milik
// pengguna maupun lembar tinjauan admin, supaya keduanya melihat hal yang
// sama persis.
class PratinjauUsulan extends StatelessWidget {
  final Usulan usulan;

  const PratinjauUsulan({super.key, required this.usulan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (usulan.teks(KunciUsulan.gambar).isNotEmpty) ...[
          ClipRRect(
            borderRadius: AppDekorasi.radiusKartu,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImageView(
                imagePath: usulan.teks(KunciUsulan.gambar),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ..._isi(),
      ],
    );
  }

  List<Widget> _isi() {
    switch (usulan.jenis) {
      case JenisUsulan.sejarah:
        return _isiSejarah();
      case JenisUsulan.budaya:
        return _isiBudaya();
      case JenisUsulan.kuis:
        return _isiKuis();
    }
  }

  List<Widget> _isiSejarah() {
    final peristiwa = usulan.daftar(KunciUsulan.alurPeristiwa);

    return [
      _baris('Judul', usulan.teks(KunciUsulan.judul)),
      _baris('Penanda Tahun', usulan.teks(KunciUsulan.subtitle)),
      _baris('Tanggal', usulan.teks(KunciUsulan.tanggalKey)),
      _baris('Provinsi', usulan.provinsi),
      _blok('Ringkasan', usulan.teks(KunciUsulan.ringkasan)),
      if (peristiwa.isNotEmpty) ...[
        _judul('Alur Peristiwa'),
        ...peristiwa.map(
          (p) => _kotak([
            _baris('Tanggal', p['tanggal']?.toString() ?? ''),
            _baris('Judul', p['judul']?.toString() ?? ''),
            _blok('Keterangan', p['keterangan']?.toString() ?? ''),
          ]),
        ),
      ],
    ];
  }

  List<Widget> _isiBudaya() {
    final kode = usulan.teks(KunciUsulan.kategori);
    final detail = usulan.isi[KunciUsulan.detailKategori];

    return [
      _baris('Nama', usulan.teks(KunciUsulan.judul)),
      _baris('Kategori', namaKategori(kode)),
      _baris('Provinsi', usulan.provinsi),
      if (usulan.isi[KunciUsulan.destinasi] == true)
        _baris('Destinasi', 'Ya, bisa dikunjungi wisatawan'),
      _blok('Tagline', usulan.teks(KunciUsulan.tagline)),
      _blok('Deskripsi', usulan.teks(KunciUsulan.deskripsi)),

      if (detail is Map && detail.isNotEmpty) ...[
        _judul('Rincian ${namaKategori(kode)}'),
        ...fieldKategori(kode).map((field) {
          final nilai = detail[field.kunci];
          if (nilai == null) return const SizedBox.shrink();
          if (nilai is List) {
            return _daftar(field.label, nilai.map((e) => '$e').toList());
          }
          return _blok(field.label, nilai.toString());
        }),
      ],

      _blok('Makna Spiritual', usulan.teks(KunciUsulan.maknaSpiritual)),
      _blok('Konteks Budaya', usulan.teks(KunciUsulan.konteksBudaya)),
    ];
  }

  List<Widget> _isiKuis() {
    final kategori = usulan.teks(KunciUsulan.kategoriKuis);
    final sub = usulan.teks(KunciUsulan.subKategori);
    final soal = usulan.daftar(KunciUsulan.soal);

    return [
      _baris('Tema', usulan.teks(KunciUsulan.tema)),
      _baris('Kategori', kategori),
      if (kategoriPunyaSubKategori(kategori))
        _baris('Kelompok', labelSubKategori(kategori, sub)),
      _baris('Provinsi', usulan.provinsi),
      _judul('${soal.length} Soal'),
      ...List.generate(soal.length, (i) {
        final s = soal[i];
        final jawaban = (s['jawaban'] as List? ?? const [])
            .map((e) => '$e')
            .toList();
        final benar = (s['benar'] as num?)?.toInt() ?? 0;

        return _kotak([
          _blok('Soal ${i + 1}', s['soal']?.toString() ?? ''),
          ...List.generate(jawaban.length, (j) {
            final tepat = j == benar;
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    tepat ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 15,
                    color: tepat ? AppColors.success : AppColors.surfaceMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jawaban[j],
                      style: AppTypography.caption(
                        fontSize: 12,
                        fontWeight: tepat ? FontWeight.w800 : FontWeight.normal,
                        color: tepat
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if ((s['penjelasan']?.toString() ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _blok('Penjelasan', s['penjelasan'].toString()),
            ),
        ]);
      }),
    ];
  }

  // section potongan tampilan

  Widget _judul(String teks) => Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
    child: Text(teks.toUpperCase(), style: AppTypography.eyebrow()),
  );

  Widget _baris(String label, String nilai) {
    if (nilai.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(label, style: AppTypography.caption(fontSize: 11.5)),
          ),
          Expanded(
            child: Text(nilai, style: AppTypography.labelBold(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _blok(String label, String nilai) {
    if (nilai.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(fontSize: 11.5)),
          const SizedBox(height: 3),
          Text(
            nilai,
            style: AppTypography.caption(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _daftar(String label, List<String> isi) {
    if (isi.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(fontSize: 11.5)),
          const SizedBox(height: 3),
          ...isi.map(
            (baris) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '· $baris',
                style: AppTypography.caption(
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kotak(List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
    decoration: AppDekorasi.panel(garis: AppColors.border),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}
