import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../data/models/budaya_model.dart';
import '../../../data/models/sejarah_model.dart';
import '../../../data/repositories/budaya_repository.dart';
import '../../../data/repositories/sejarah_repository.dart';
import 'widgets/app_image_picker_widget.dart';

class AdminManageContentPage extends StatefulWidget {
  const AdminManageContentPage({super.key});

  @override
  State<AdminManageContentPage> createState() => _AdminManageContentPageState();
}

class _AdminManageContentPageState extends State<AdminManageContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final BudayaRepository _budayaRepository = BudayaRepository();

  List<SejarahModel> _sejarahList = [];
  List<BudayaModel> _budayaList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final sejarah = await _sejarahRepository.getAllSejarah();
    final budaya = await _budayaRepository.getAllBudaya();
    if (!mounted) return;
    setState(() {
      _sejarahList = sejarah;
      _budayaList = budaya;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // SEJARAH CRUD & ALUR PERISTIWA (TIMELINE)
  // ---------------------------------------------------------------------------
  void _showSejarahFormDialog({SejarahModel? sejarahToEdit}) {
    final isEditing = sejarahToEdit != null;
    final kodeTagController = TextEditingController(
      text: isEditing ? sejarahToEdit.kodeTag : 'HIS-170845-1',
    );
    final judulController = TextEditingController(
      text: isEditing ? sejarahToEdit.judul : '',
    );
    final subtitleController = TextEditingController(
      text: isEditing ? sejarahToEdit.subtitle : '17.08.45',
    );
    final tanggalKeyController = TextEditingController(
      text: isEditing ? sejarahToEdit.tanggalKey : '170845',
    );
    final urutanController = TextEditingController(
      text: isEditing ? sejarahToEdit.urutan.toString() : '1',
    );
    final ringkasanController = TextEditingController(
      text: isEditing ? sejarahToEdit.ringkasan : '',
    );
    String selectedImage = isEditing
        ? sejarahToEdit.gambarUtama
        : 'assets/images/170845history.png';

    // Editable Timeline items
    List<TimelineItemModel> timelineItems = isEditing
        ? List.from(sejarahToEdit.alurPeristiwa)
        : [
            const TimelineItemModel(
              date: '16 AGUSTUS 1945 · 03:00 WIB',
              title: 'Peristiwa Rengasdengklok',
              desc: 'Golongan muda mendesak percepatan proklamasi.',
              imgPath: 'assets/images/rengasdengklok.jpg',
              hasImage: true,
            ),
          ];

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing
                                  ? 'Edit Data Sejarah'
                                  : 'Tambah Sejarah Baru',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalCtx),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.primary),
                        const SizedBox(height: 12),

                        // Kode Tag (HIS-ddMMyy-urutan)
                        Text(
                          'ID Tag (Format: HIS-<ddMMyy>-<urutan>)',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: kodeTagController,
                          decoration: _inputDecoration('Contoh: HIS-150845-1'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Kode tag wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Tanggal Key & Urutan
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Key (ddMMyy)',
                                    style: AppTypography.labelBold(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: tanggalKeyController,
                                    decoration: _inputDecoration('150845'),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Urutan',
                                    style: AppTypography.labelBold(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: urutanController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('1'),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Wajib'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Judul
                        Text(
                          'Judul Sejarah',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: judulController,
                          decoration: _inputDecoration('Contoh: Detik Proklamasi'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Judul tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Subtitle / Format Tanggal',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: subtitleController,
                          decoration: _inputDecoration('Contoh: 17.08.45'),
                        ),
                        const SizedBox(height: 12),

                        // Ringkasan
                        Text(
                          'Ringkasan Sejarah',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: ringkasanController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Masukkan narasi ringkasan sejarah...',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Ringkasan tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // Gambar Utama (Upload Widget)
                        AppImagePickerWidget(
                          label: 'Gambar Utama Sejarah',
                          isRequired: true,
                          currentImagePath: selectedImage,
                          onImageSelected: (path) {
                            if (path != null) {
                              setModalState(() => selectedImage = path);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // -----------------------------------------------------
                        // SECTION: ALUR PERISTIWA (TIMELINE ITEMS)
                        // -----------------------------------------------------
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Alur Peristiwa (Timeline)',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                _showTimelineItemDialog(
                                  modalCtx,
                                  onSave: (newItem) {
                                    setModalState(() {
                                      timelineItems.add(newItem);
                                    });
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Tambah Event',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (timelineItems.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Center(
                              child: Text(
                                'Belum ada alur peristiwa. Tekan "Tambah Event".',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          ...List.generate(timelineItems.length, (idx) {
                            final item = timelineItems[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${idx + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.date,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          item.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.desc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (item.hasImage && item.imgPath != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.image,
                                                  size: 14,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.imgPath!.split('/').last,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 10.5,
                                                      color: AppColors.primaryDark,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Colors.blueAccent,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      _showTimelineItemDialog(
                                        modalCtx,
                                        itemToEdit: item,
                                        onSave: (updatedItem) {
                                          setModalState(() {
                                            timelineItems[idx] = updatedItem;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setModalState(() {
                                        timelineItems.removeAt(idx);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 24),

                        // Button Simpan Sejarah
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final model = SejarahModel(
                                id: isEditing ? sejarahToEdit.id : null,
                                kodeTag: kodeTagController.text.trim(),
                                tanggalKey: tanggalKeyController.text.trim(),
                                urutan: int.tryParse(
                                      urutanController.text.trim(),
                                    ) ??
                                    1,
                                judul: judulController.text.trim(),
                                subtitle: subtitleController.text.trim(),
                                ringkasan: ringkasanController.text.trim(),
                                gambarUtama: selectedImage,
                                alurPeristiwa: timelineItems,
                                relatedItems: isEditing
                                    ? sejarahToEdit.relatedItems
                                    : const [],
                              );

                              if (isEditing) {
                                await _sejarahRepository.updateSejarah(model);
                              } else {
                                await _sejarahRepository.tambahSejarah(model);
                              }

                              await _loadAllData();
                              if (!mounted) return;
                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Data sejarah berhasil diperbarui!'
                                        : 'Data sejarah baru berhasil ditambahkan!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Sejarah',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog Helper for adding/editing a Timeline Item
  void _showTimelineItemDialog(
    BuildContext parentCtx, {
    TimelineItemModel? itemToEdit,
    required ValueChanged<TimelineItemModel> onSave,
  }) {
    final isEdit = itemToEdit != null;
    final dateController = TextEditingController(
      text: isEdit ? itemToEdit.date : '16 AGUSTUS 1945 · 03:00 WIB',
    );
    final titleController = TextEditingController(
      text: isEdit ? itemToEdit.title : '',
    );
    final descController = TextEditingController(
      text: isEdit ? itemToEdit.desc : '',
    );
    String? selectedTimelineImage = isEdit ? itemToEdit.imgPath : null;

    showDialog(
      context: parentCtx,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dCtx, setDState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isEdit ? 'Edit Event Alur' : 'Tambah Event Alur',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waktu / Tanggal Event',
                      style: AppTypography.labelBold(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: dateController,
                      decoration: _inputDecoration('16 AGUSTUS 1945 · 03:00 WIB'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Judul Peristiwa',
                      style: AppTypography.labelBold(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: titleController,
                      decoration: _inputDecoration('Peristiwa Rengasdengklok'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Deskripsi Peristiwa',
                      style: AppTypography.labelBold(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: _inputDecoration('Narasi kejadian alur...'),
                    ),
                    const SizedBox(height: 12),
                    AppImagePickerWidget(
                      label: 'Gambar Event (Opsional)',
                      isRequired: false,
                      currentImagePath: selectedTimelineImage,
                      onImageSelected: (path) {
                        setDState(() => selectedTimelineImage = path);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    final item = TimelineItemModel(
                      date: dateController.text.trim(),
                      title: titleController.text.trim(),
                      desc: descController.text.trim(),
                      imgPath: selectedTimelineImage,
                      hasImage: selectedTimelineImage != null &&
                          selectedTimelineImage!.isNotEmpty,
                    );
                    onSave(item);
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(
                    isEdit ? 'Simpan' : 'Tambah',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUDAYA CRUD & SUB-IMAGES (Makna Spiritual & Konteks Budaya)
  // ---------------------------------------------------------------------------
  void _showBudayaFormDialog({BudayaModel? budayaToEdit}) {
    final isEditing = budayaToEdit != null;
    final kodeTagController = TextEditingController(
      text: isEditing ? budayaToEdit.kodeTag : 'BUD-SNJT-1',
    );
    final jenisController = TextEditingController(
      text: isEditing ? budayaToEdit.jenis : 'SNJT',
    );
    final urutanController = TextEditingController(
      text: isEditing ? budayaToEdit.urutan.toString() : '1',
    );
    final judulController = TextEditingController(
      text: isEditing ? budayaToEdit.judul : '',
    );
    final kategoriLabelController = TextEditingController(
      text: isEditing ? budayaToEdit.kategoriLabel : 'SENJATA TRADISIONAL',
    );
    final taglineController = TextEditingController(
      text: isEditing ? budayaToEdit.tagline : '',
    );
    final deskripsiController = TextEditingController(
      text: isEditing ? budayaToEdit.deskripsi : '',
    );
    final maknaSpiritualController = TextEditingController(
      text: isEditing ? (budayaToEdit.maknaSpiritual ?? '') : '',
    );
    final konteksBudayaController = TextEditingController(
      text: isEditing ? (budayaToEdit.konteksBudaya ?? '') : '',
    );

    String selectedImage = isEditing
        ? budayaToEdit.gambarUtama
        : 'assets/images/kerisB.jpg';
    String? selectedMaknaSpiritualImage =
        isEditing ? budayaToEdit.gambarMaknaSpiritual : null;
    String? selectedKonteksBudayaImage =
        isEditing ? budayaToEdit.gambarKonteksBudaya : null;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing
                                  ? 'Edit Data Budaya'
                                  : 'Tambah Budaya Baru',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(modalCtx),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.primary),
                        const SizedBox(height: 12),

                        // ID Tag (BUD-JENIS-urutan)
                        Text(
                          'ID Tag (Format: BUD-<JENIS>-<urutan>)',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: kodeTagController,
                          decoration: _inputDecoration('Contoh: BUD-SNJT-1'),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Kode tag wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Jenis & Urutan
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jenis (SNJT/ADT/TRN/MSK)',
                                    style: AppTypography.labelBold(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: jenisController,
                                    decoration: _inputDecoration('SNJT'),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Wajib diisi'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Urutan',
                                    style: AppTypography.labelBold(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: urutanController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration('1'),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty
                                            ? 'Wajib'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Judul
                        Text(
                          'Judul Budaya',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: judulController,
                          decoration: _inputDecoration(
                            'Contoh: Q-RIS / CANDI BOROBUDUR',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Judul tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Kategori Label
                        Text(
                          'Kategori Label',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: kategoriLabelController,
                          decoration: _inputDecoration('SENJATA TRADISIONAL'),
                        ),
                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Tagline / Kalimat Pengantar',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: taglineController,
                          decoration: _inputDecoration(
                            'Sebilah logam yang menyimpan wibawa...',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Deskripsi
                        Text(
                          'Deskripsi Utama',
                          style: AppTypography.labelBold(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: deskripsiController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Masukkan deskripsi budaya...',
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Deskripsi wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 14),

                        // 1. Gambar Utama Budaya (Wajib)
                        AppImagePickerWidget(
                          label: 'Gambar Utama Budaya',
                          isRequired: true,
                          currentImagePath: selectedImage,
                          onImageSelected: (path) {
                            if (path != null) {
                              setModalState(() => selectedImage = path);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. Makna Spiritual & Gambar Tambahan
                        Text(
                          'Sub-Bagian 1: Makna Spiritual',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: maknaSpiritualController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            'Teks makna filosofis / spiritual...',
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppImagePickerWidget(
                          label: 'Gambar Tambahan: Makna Spiritual',
                          isRequired: false,
                          currentImagePath: selectedMaknaSpiritualImage,
                          onImageSelected: (path) {
                            setModalState(
                              () => selectedMaknaSpiritualImage = path,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Konteks Budaya & Gambar Tambahan
                        Text(
                          'Sub-Bagian 2: Konteks Budaya',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: konteksBudayaController,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            'Teks konteks adat & sosial...',
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppImagePickerWidget(
                          label: 'Gambar Tambahan: Konteks Budaya',
                          isRequired: false,
                          currentImagePath: selectedKonteksBudayaImage,
                          onImageSelected: (path) {
                            setModalState(
                              () => selectedKonteksBudayaImage = path,
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Button Simpan Budaya
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;

                              final model = BudayaModel(
                                id: isEditing ? budayaToEdit.id : null,
                                kodeTag: kodeTagController.text.trim(),
                                jenis: jenisController.text.trim(),
                                urutan: int.tryParse(
                                      urutanController.text.trim(),
                                    ) ??
                                    1,
                                judul: judulController.text.trim(),
                                kategoriLabel: kategoriLabelController.text
                                    .trim(),
                                tagline: taglineController.text.trim(),
                                deskripsi: deskripsiController.text.trim(),
                                gambarUtama: selectedImage,
                                maknaSpiritual: maknaSpiritualController.text
                                        .trim()
                                        .isNotEmpty
                                    ? maknaSpiritualController.text.trim()
                                    : null,
                                gambarMaknaSpiritual: selectedMaknaSpiritualImage,
                                konteksBudaya: konteksBudayaController.text
                                        .trim()
                                        .isNotEmpty
                                    ? konteksBudayaController.text.trim()
                                    : null,
                                gambarKonteksBudaya: selectedKonteksBudayaImage,
                                relatedItems: isEditing
                                    ? budayaToEdit.relatedItems
                                    : const [],
                              );

                              if (isEditing) {
                                await _budayaRepository.updateBudaya(model);
                              } else {
                                await _budayaRepository.tambahBudaya(model);
                              }

                              await _loadAllData();
                              if (!mounted) return;
                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEditing
                                        ? 'Data budaya berhasil diperbarui!'
                                        : 'Data budaya baru berhasil ditambahkan!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                            child: Text(
                              isEditing ? 'Simpan Perubahan' : 'Tambah Budaya',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint.isNotEmpty ? hint : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSejarah = _sejarahList.where((s) {
      final q = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          s.judul.toLowerCase().contains(q) ||
          s.kodeTag.toLowerCase().contains(q) ||
          s.ringkasan.toLowerCase().contains(q);
    }).toList();

    final filteredBudaya = _budayaList.where((b) {
      final q = _searchQuery.toLowerCase();
      return _searchQuery.isEmpty ||
          b.judul.toLowerCase().contains(q) ||
          b.kodeTag.toLowerCase().contains(q) ||
          b.deskripsi.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manage Konten Utama',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Sejarah'),
            Tab(text: 'Budaya'),
          ],
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.primary, width: 0.8),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, tag, atau deskripsi...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: SEJARAH LIST
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSejarah.length,
                        itemBuilder: (context, index) {
                          final item = filteredSejarah[index];
                          return _buildSejarahCard(item);
                        },
                      ),

                      // TAB 2: BUDAYA LIST
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredBudaya.length,
                        itemBuilder: (context, index) {
                          final item = filteredBudaya[index];
                          return _buildBudayaCard(item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          if (_tabController.index == 0) {
            _showSejarahFormDialog();
          } else {
            _showBudayaFormDialog();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'Tambah Sejarah' : 'Tambah Budaya',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSejarahCard(SejarahModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.kodeTag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Urutan ${item.urutan} · ${item.subtitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _showSejarahFormDialog(sejarahToEdit: item),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  onTap: () async {
                    await _sejarahRepository.deleteSejarah(item.kodeTag);
                    await _loadAllData();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data sejarah berhasil dihapus'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: AppImageView(
                      imagePath: item.gambarUtama,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.ringkasan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      if (item.alurPeristiwa.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${item.alurPeristiwa.length} alur peristiwa dicatat',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudayaCard(BudayaModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.kodeTag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.kategoriLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _showBudayaFormDialog(budayaToEdit: item),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  onTap: () async {
                    await _budayaRepository.deleteBudaya(item.kodeTag);
                    await _loadAllData();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data budaya berhasil dihapus'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: AppImageView(
                      imagePath: item.gambarUtama,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      if (item.gambarMaknaSpiritual != null ||
                          item.gambarKonteksBudaya != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Termasuk gambar sub-bagian',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
