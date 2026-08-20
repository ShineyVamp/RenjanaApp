import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../data/models/budaya_model.dart';
import '../../data/models/sejarah_model.dart';
import '../../data/repositories/budaya_repository.dart';
import '../../data/repositories/sejarah_repository.dart';
import '../bookmark/bookmark_page.dart';
import 'widgets/banner_melestarikan.dart';
import 'widgets/budaya_highlight_card.dart';
import 'widgets/koleksi_budaya_list.dart';
import 'widgets/pilihan_destinasi_list.dart';
import 'widgets/sejarah_highlight_card.dart';

/// Ruang kosong sementara sorotan harian masih dimuat dari database.
class _HighlightPlaceholder extends StatelessWidget {
  const _HighlightPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: const CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  final bool isAdmin;
  final VoidCallback? onOpenDrawer;

  const HomePage({
    super.key,
    this.userName = 'Agus',
    this.isAdmin = false,
    this.onOpenDrawer,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final BudayaRepository _budayaRepository = BudayaRepository();

  SejarahModel? _sejarahHariIni;
  BudayaModel? _budayaHariIni;

  @override
  void initState() {
    super.initState();
    _loadFromRepository();
  }

  Future<void> _loadFromRepository() async {
    final sejarah = await _sejarahRepository.getSejarahHariIni();
    final budaya = await _budayaRepository.getBudayaHariIni();
    if (!mounted) return;
    setState(() {
      _sejarahHariIni = sejarah;
      _budayaHariIni = budaya;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            surfaceTintColor: AppColors.background,
            backgroundColor: AppColors.background,
            floating: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                if (widget.isAdmin) ...[
                  Builder(
                    builder: (ctx) => IconButton(
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed:
                          widget.onOpenDrawer ??
                          () {
                            Scaffold.of(ctx).openDrawer();
                          },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await _loadFromRepository();
                    if (context.mounted) {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.clearSnackBars();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Halaman beranda diperbarui'),
                          duration: Duration(milliseconds: 1200),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/Rlogos.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text('RENJANA', style: AppTypography.brandTitle()),
                    ],
                  ),
                ),
                if (widget.isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      'ADMIN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                tooltip: 'Koleksi Tersimpan',
                onPressed: () {
                  context.push(const BookmarkPage());
                },
              ),
              const SizedBox(width: 4),
            ],
            shape: const Border(
              bottom: BorderSide(color: AppColors.primary, width: 0.8),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        'EEEE, dd MMMM yyyy',
                        'id_ID',
                      ).format(DateTime.now()),
                      style: AppTypography.labelBold(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selamat pagi, ${widget.userName}',
                      style: AppTypography.headingMedium(),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.primary),
                    const SizedBox(height: 32),

                    // Section 01: Sejarah Hari Ini
                    if (_sejarahHariIni != null)
                      SejarahHighlightCard(data: _sejarahHariIni!)
                    else
                      const _HighlightPlaceholder(),
                    const SizedBox(height: 48),

                    // Section 02: Budaya Hari Ini
                    if (_budayaHariIni != null)
                      BudayaHighlightCard(data: _budayaHariIni!)
                    else
                      const _HighlightPlaceholder(),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Section 03: Koleksi Budaya
              const KoleksiBudayaList(),
              const SizedBox(height: 48),

              // Section 04: Pilihan Destinasi
              const PilihanDestinasiList(),
              const SizedBox(height: 36),

              // Contribution Banner
              const BannerMelestarikan(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
