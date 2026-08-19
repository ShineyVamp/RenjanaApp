import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'widgets/banner_melestarikan.dart';
import 'widgets/budaya_highlight_card.dart';
import 'widgets/koleksi_budaya_list.dart';
import 'widgets/pilihan_destinasi_list.dart';
import 'widgets/sejarah_highlight_card.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, this.userName = 'Agus'});

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
            title: Row(
              children: [
                Image.asset('assets/images/Rlogos.png', width: 32, height: 32),
                const SizedBox(width: 8),
                Text(
                  'RENJANA',
                  style: AppTypography.brandTitle(),
                ),
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
                      'Selamat pagi, $userName',
                      style: AppTypography.headingMedium(),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.primary),
                    const SizedBox(height: 32),

                    // Section 01: Sejarah Hari Ini
                    const SejarahHighlightCard(),
                    const SizedBox(height: 48),

                    // Section 02: Budaya Hari Ini
                    const BudayaHighlightCard(),
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
