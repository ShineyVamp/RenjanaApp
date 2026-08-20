import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_image.dart';

class AppImagePickerWidget extends StatelessWidget {
  final String label;
  final String? currentImagePath;
  final bool isRequired;
  final ValueChanged<String?> onImageSelected;

  static const List<String> defaultAssets = [
    'assets/images/1308history.png',
    'assets/images/170845history.png',
    'assets/images/borobudurB.jpg',
    'assets/images/kerisB.jpg',
    'assets/images/rengasdengklok.jpg',
    'assets/images/perumusan.jpg',
    'assets/images/onboardin1.jpg',
    'assets/images/onboardin2.jpg',
    'assets/images/onboardin3.jpg',
  ];

  const AppImagePickerWidget({
    super.key,
    required this.label,
    required this.currentImagePath,
    this.isRequired = false,
    required this.onImageSelected,
  });

  Future<bool> _requestGalleryPermission(BuildContext context) async {
    try {
      // Check photos permission (Android 13+ / iOS) or storage (Android <13)
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) {
        status = await Permission.storage.request();
      }

      if (status.isPermanentlyDenied) {
        if (context.mounted) {
          _showPermissionDialog(
            context,
            'Izin Akses Galeri Diperlukan',
            'Aplikasi membutuhkan izin akses galeri/foto untuk memilih gambar dari memori perangkat. Silakan aktifkan di Pengaturan.',
          );
        }
        return false;
      }
      return true;
    } catch (_) {
      // On platforms where permission_handler is not needed/supported (e.g. desktop), allow proceeding
      return true;
    }
  }

  void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          title,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text(
              'Buka Pengaturan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _safePickFromDevice(BuildContext context) async {
    // Request permission first
    final hasPermission = await _requestGalleryPermission(context);
    if (!hasPermission) return;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        onImageSelected(image.path);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal membuka galeri. Silakan pastikan izin aktif atau gunakan Galeri Aset / Path File.',
            ),
            backgroundColor: AppColors.primaryDark,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showImagePickerSheet(BuildContext context) {
    final customPathController = TextEditingController(
      text: currentImagePath ?? '',
    );

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
            return DefaultTabController(
              length: 2,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(modalCtx).size.height * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih / Upload Gambar',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 20,
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
                      const SizedBox(height: 12),

                      // Tombol Buka Galeri Device (Dengan Permintaan Izin Otomatis)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _safePickFromDevice(modalCtx),
                          icon: const Icon(
                            Icons.photo_library_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            'Buka Galeri / File Device',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TabBar(
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                        tabs: const [
                          Tab(text: 'Galeri Aset Renjana'),
                          Tab(text: 'Path Kustom / File'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // TAB 1: Grid Galeri Aset Renjana
                            GridView.builder(
                              itemCount: defaultAssets.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (ctx, index) {
                                final assetPath = defaultAssets[index];
                                final isSelected =
                                    currentImagePath == assetPath;

                                return GestureDetector(
                                  onTap: () {
                                    onImageSelected(assetPath);
                                    Navigator.pop(modalCtx);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            assetPath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.35),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // TAB 2: Path Kustom
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Masukkan Path File atau Aset Lokal',
                                    style: AppTypography.labelBold(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: customPathController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'assets/images/nama.jpg atau C:\\path\\foto.jpg',
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        final path = customPathController.text
                                            .trim();
                                        if (path.isNotEmpty) {
                                          onImageSelected(path);
                                        }
                                        Navigator.pop(modalCtx);
                                      },
                                      child: Text(
                                        'Gunakan Gambar Ini',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        currentImagePath != null && currentImagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.labelBold(fontSize: 13)),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Text(
                '(Opsional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Preview & Upload Card (1 Tombol Utama)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasImage ? AppColors.border : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              // Thumbnail Box
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: hasImage
                      ? AppImageView(
                          imagePath: currentImagePath,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Detail & 1 Single Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasImage
                          ? currentImagePath!.split(RegExp(r'[/\\]')).last
                          : 'Belum ada gambar dipilih',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: hasImage
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => _showImagePickerSheet(context),
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            hasImage ? 'Ganti Gambar' : 'Pilih Gambar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (hasImage && !isRequired) ...[
                          const SizedBox(width: 10),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => onImageSelected(null),
                            child: Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
