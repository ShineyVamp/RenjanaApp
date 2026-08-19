import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../data/local/budaya_data.dart';
import '../../data/local/sejarah_data.dart';
import '../../data/models/budaya_model.dart';
import '../../data/models/sejarah_model.dart';
import '../../data/repositories/budaya_repository.dart';
import '../../data/repositories/sejarah_repository.dart';
import 'widgets/banner_melestarikan.dart';
import 'widgets/budaya_highlight_card.dart';
import 'widgets/koleksi_budaya_list.dart';
import 'widgets/pilihan_destinasi_list.dart';
import 'widgets/sejarah_highlight_card.dart';

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
    _sejarahHariIni = getSejarahHariIni();
    _budayaHariIni = getRandomBudaya();
    _loadFromRepository();
  }

  Future<void> _loadFromRepository() async {
    final sejarah = await _sejarahRepository.getSejarahHariIni();
    final budaya = await _budayaRepository.getRandomBudaya();
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
                      onPressed: widget.onOpenDrawer ??
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Halaman beranda diperbarui'),
                          duration: Duration(milliseconds: 1200),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/Rlogos.png', width: 32, height: 32),
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
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.bookmark_border, color: AppColors.primary),
              ),
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
                    SejarahHighlightCard(sejarah: _sejarahHariIni),
                    const SizedBox(height: 48),

                    // Section 02: Budaya Hari Ini
                    BudayaHighlightCard(budaya: _budayaHariIni),
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
