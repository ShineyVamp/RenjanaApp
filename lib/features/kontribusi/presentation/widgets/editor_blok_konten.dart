import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dekorasi.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/detail_spec_block.dart';
import '../../../sejarah/data/models/sejarah_model.dart';
import 'package:renjana/features/kontribusi/data/models/blok_konten_model.dart';

class EditorBlokKonten extends StatefulWidget {
  final List<BlokKontenModel> daftarAwal;
  final ValueChanged<List<BlokKontenModel>> onChanged;

  const EditorBlokKonten({
    super.key,
    required this.daftarAwal,
    required this.onChanged,
  });

  @override
  State<EditorBlokKonten> createState() => _EditorBlokKontenState();
}

class _EditorBlokKontenState extends State<EditorBlokKonten> {
  late List<BlokKontenModel> _daftarBlok;

  @override
  void initState() {
    super.initState();
    _daftarBlok = List.from(widget.daftarAwal);
  }

  void _notifikasiPerubahan() {
    widget.onChanged(List.unmodifiable(_daftarBlok));
    setState(() {});
  }

  void _tambahBlokBaru(TipeBlokKonten tipe) {
    String judulAwal = '';
    dynamic dataAwal;

    switch (tipe) {
      case TipeBlokKonten.teksPanjang:
        judulAwal = 'Deskripsi Tambahan';
        dataAwal = '';
        break;
      case TipeBlokKonten.daftar:
        judulAwal = 'Daftar / Rincian';
        dataAwal = <String>[''];
        break;
      case TipeBlokKonten.timeline:
        judulAwal = 'Alur Peristiwa';
        dataAwal = <TimelineItemModel>[
          const TimelineItemModel(
            date: '',
            title: '',
            desc: '',
          ),
        ];
        break;
      case TipeBlokKonten.spesifikasi:
        judulAwal = 'Informasi Singkat';
        dataAwal = <SpecItem>[
          const SpecItem('', ''),
        ];
        break;
    }

    _daftarBlok.add(
      BlokKontenModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        tipe: tipe,
        judul: judulAwal,
        data: dataAwal,
      ),
    );
    _notifikasiPerubahan();
  }

  void _hapusBlok(int index) {
    _daftarBlok.removeAt(index);
    _notifikasiPerubahan();
  }

  void _pindahkanBlok(int dari, int ke) {
    if (dari < ke) ke -= 1;
    final item = _daftarBlok.removeAt(dari);
    _daftarBlok.insert(ke, item);
    _notifikasiPerubahan();
  }

  void _tampilkanPilihanTipeBlok() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Jenis Blok Konten',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...TipeBlokKonten.values.map((tipe) {
                  IconData ikon;
                  switch (tipe) {
                    case TipeBlokKonten.teksPanjang:
                      ikon = Icons.notes_rounded;
                      break;
                    case TipeBlokKonten.daftar:
                      ikon = Icons.format_list_numbered_rounded;
                      break;
                    case TipeBlokKonten.timeline:
                      ikon = Icons.timeline_rounded;
                      break;
                    case TipeBlokKonten.spesifikasi:
                      ikon = Icons.tune_rounded;
                      break;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: AppDekorasi.panel(garis: AppColors.border),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight.withAlpha(50),
                        child: Icon(ikon, color: AppColors.primaryDark, size: 22),
                      ),
                      title: Text(
                        tipe.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        tipe.deskripsi,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _tambahBlokBaru(tipe);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SEKSI & BLOK KONTEN',
              style: AppTypography.eyebrow(letterSpacing: 1.1),
            ),
            Text(
              '${_daftarBlok.length} Seksi',
              style: AppTypography.caption(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_daftarBlok.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.post_add_rounded,
                  color: AppColors.surfaceMuted,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum ada seksi tambahan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tambahkan seksi deskripsi, daftar bernomor, timeline alur waktu, atau data singkat sesuai kebutuhan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _daftarBlok.length,
            // ignore: deprecated_member_use
            onReorder: _pindahkanBlok,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final blok = _daftarBlok[index];
              return _ItemEditorBlok(
                key: ValueKey(blok.id),
                blok: blok,
                index: index,
                onHapus: () => _hapusBlok(index),
                onUpdated: _notifikasiPerubahan,
              );
            },
          ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: AppColors.primaryLight.withAlpha(20),
            ),
            onPressed: _tampilkanPilihanTipeBlok,
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryDark),
            label: Text(
              '+ Tambah Seksi / Blok Konten',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemEditorBlok extends StatefulWidget {
  final BlokKontenModel blok;
  final int index;
  final VoidCallback onHapus;
  final VoidCallback onUpdated;

  const _ItemEditorBlok({
    super.key,
    required this.blok,
    required this.index,
    required this.onHapus,
    required this.onUpdated,
  });

  @override
  State<_ItemEditorBlok> createState() => _ItemEditorBlokState();
}

class _ItemEditorBlokState extends State<_ItemEditorBlok> {
  late TextEditingController _judulController;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.blok.judul);
  }

  @override
  void didUpdateWidget(covariant _ItemEditorBlok oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_judulController.text != widget.blok.judul) {
      _judulController.text = widget.blok.judul;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        color: AppColors.textMuted,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppDekorasi.panel(garis: AppColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris Blok
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted.withAlpha(25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: const Border(
                bottom: BorderSide(color: AppColors.border, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.blok.tipe.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  tooltip: 'Hapus Seksi',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onHapus,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Judul Seksi
                Text(
                  'Judul Seksi / Heading',
                  style: AppTypography.labelBold(fontSize: 12),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _judulController,
                  decoration: _inputDeco('Contoh: Makna Spiritual, Bahan & Tata Cara, Latar Belakang...'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                  onChanged: (val) {
                    widget.blok.judul = val;
                    widget.onUpdated();
                  },
                ),
                const SizedBox(height: 12),

                // Editor Spesifik per Tipe
                _buildKontenEditor(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKontenEditor() {
    switch (widget.blok.tipe) {
      case TipeBlokKonten.teksPanjang:
        return _buildEditorTeksPanjang();
      case TipeBlokKonten.daftar:
        return _buildEditorDaftar();
      case TipeBlokKonten.timeline:
        return _buildEditorTimeline();
      case TipeBlokKonten.spesifikasi:
        return _buildEditorSpesifikasi();
    }
  }

  // 1. Editor Teks Panjang
  Widget _buildEditorTeksPanjang() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Isi Paragraf / Penjelasan',
          style: AppTypography.labelBold(fontSize: 12),
        ),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: widget.blok.teks,
          maxLines: 4,
          decoration: _inputDeco('Tuliskan uraian atau penjelasan detail pada seksi ini...'),
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, height: 1.4),
          onChanged: (val) {
            widget.blok.data = val;
            widget.onUpdated();
          },
        ),
      ],
    );
  }

  // 2. Editor Daftar Bernomor
  Widget _buildEditorDaftar() {
    final list = widget.blok.daftar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Butir / Item Daftar',
          style: AppTypography.labelBold(fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...list.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Text(
                    '${idx + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item,
                    decoration: _inputDeco('Tuliskan butir ke-${idx + 1}...'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
                    onChanged: (val) {
                      final updated = List<String>.from(widget.blok.daftar);
                      if (idx < updated.length) {
                        updated[idx] = val;
                        widget.blok.data = updated;
                        widget.onUpdated();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
                  onPressed: () {
                    final updated = List<String>.from(widget.blok.daftar);
                    if (updated.length > 1) {
                      updated.removeAt(idx);
                    } else {
                      updated[0] = '';
                    }
                    widget.blok.data = updated;
                    widget.onUpdated();
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () {
            final updated = List<String>.from(widget.blok.daftar);
            updated.add('');
            widget.blok.data = updated;
            widget.onUpdated();
            setState(() {});
          },
          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
          label: Text(
            '+ Tambah Butir',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Editor Timeline (Urutan Waktu)
  Widget _buildEditorTimeline() {
    final timeline = widget.blok.timeline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kronologi / Urutan Peristiwa',
          style: AppTypography.labelBold(fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...timeline.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Peristiwa #${idx + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        final updated = List<TimelineItemModel>.from(widget.blok.timeline);
                        if (updated.length > 1) {
                          updated.removeAt(idx);
                        } else {
                          updated[0] = const TimelineItemModel(date: '', title: '', desc: '');
                        }
                        widget.blok.data = updated;
                        widget.onUpdated();
                        setState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: item.date,
                  decoration: _inputDeco('Tanggal / Waktu (misal: 17 AGUSTUS 1945 · 10:00 WIB)'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  onChanged: (val) {
                    final updated = List<TimelineItemModel>.from(widget.blok.timeline);
                    updated[idx] = TimelineItemModel(
                      date: val,
                      title: item.title,
                      desc: item.desc,
                      imgPath: item.imgPath,
                      hasImage: item.hasImage,
                    );
                    widget.blok.data = updated;
                    widget.onUpdated();
                  },
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: item.title,
                  decoration: _inputDeco('Judul Peristiwa'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                  onChanged: (val) {
                    final updated = List<TimelineItemModel>.from(widget.blok.timeline);
                    updated[idx] = TimelineItemModel(
                      date: item.date,
                      title: val,
                      desc: item.desc,
                      imgPath: item.imgPath,
                      hasImage: item.hasImage,
                    );
                    widget.blok.data = updated;
                    widget.onUpdated();
                  },
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: item.desc,
                  maxLines: 2,
                  decoration: _inputDeco('Deskripsi / Keterangan peristiwa'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  onChanged: (val) {
                    final updated = List<TimelineItemModel>.from(widget.blok.timeline);
                    updated[idx] = TimelineItemModel(
                      date: item.date,
                      title: item.title,
                      desc: val,
                      imgPath: item.imgPath,
                      hasImage: item.hasImage,
                    );
                    widget.blok.data = updated;
                    widget.onUpdated();
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            final updated = List<TimelineItemModel>.from(widget.blok.timeline);
            updated.add(const TimelineItemModel(date: '', title: '', desc: ''));
            widget.blok.data = updated;
            widget.onUpdated();
            setState(() {});
          },
          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
          label: Text(
            '+ Tambah Peristiwa',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  // 4. Editor Spesifikasi (Data Singkat)
  Widget _buildEditorSpesifikasi() {
    final specs = widget.blok.spesifikasi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pasangan Data (Label & Nilai)',
          style: AppTypography.labelBold(fontSize: 12),
        ),
        const SizedBox(height: 6),
        ...specs.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.label,
                    decoration: _inputDeco('Label (mis. Arsitek)'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                    onChanged: (val) {
                      final updated = List<SpecItem>.from(widget.blok.spesifikasi);
                      updated[idx] = SpecItem(val, item.nilai);
                      widget.blok.data = updated;
                      widget.onUpdated();
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: item.nilai,
                    decoration: _inputDeco('Nilai (mis. F. Silaban)'),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    onChanged: (val) {
                      final updated = List<SpecItem>.from(widget.blok.spesifikasi);
                      updated[idx] = SpecItem(item.label, val);
                      widget.blok.data = updated;
                      widget.onUpdated();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.error),
                  onPressed: () {
                    final updated = List<SpecItem>.from(widget.blok.spesifikasi);
                    if (updated.length > 1) {
                      updated.removeAt(idx);
                    } else {
                      updated[0] = const SpecItem('', '');
                    }
                    widget.blok.data = updated;
                    widget.onUpdated();
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            final updated = List<SpecItem>.from(widget.blok.spesifikasi);
            updated.add(const SpecItem('', ''));
            widget.blok.data = updated;
            widget.onUpdated();
            setState(() {});
          },
          icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
          label: Text(
            '+ Tambah Data Singkat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
