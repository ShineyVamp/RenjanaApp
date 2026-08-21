import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/detail_top_bar.dart';
import '../../data/models/budaya_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/budaya_repository.dart';
import '../../services/riwayat_handler.dart';

class DetailBudayaPage extends StatefulWidget {
  final BudayaModel budaya;

  const DetailBudayaPage({super.key, required this.budaya});

  @override
  State<DetailBudayaPage> createState() => _DetailBudayaPageState();
}

class _DetailBudayaPageState extends State<DetailBudayaPage> {
  final BudayaRepository _budayaRepository = BudayaRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  bool _isBookmarked = false;
  final ScrollController _scrollRelated = ScrollController();
  List<BudayaModel> _otherBudayaList = [];

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _loadOtherBudaya();
    RiwayatHandler.catatDibuka('budaya', widget.budaya.kodeTag);
  }

  Future<void> _checkBookmarkStatus() async {
    final data = widget.budaya;
    final bookmarked = await _bookmarkRepository.isBookmarked(data.kodeTag);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
    });
  }

  Future<void> _loadOtherBudaya() async {
    final list = await _budayaRepository.getRandomBudayaList(
      count: 5,
      exclude: widget.budaya,
    );
    if (!mounted) return;
    setState(() {
      _otherBudayaList = list;
    });
  }

  @override
  void dispose() {
    _scrollRelated.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.budaya;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // header utama
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // gambar utama
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: AppImageView(
                              imagePath: data.gambarUtama,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.backgroundTransparent,
                                    AppColors.background,
                                  ],
                                  stops: [0, 1],
                                ),
                              ),
                            ),
                          ),

                          // tombol back, home, bookmark
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: DetailTopBar(
                              isBookmarked: _isBookmarked,
                              onBookmarkToggle: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final nowBookmarked = await _bookmarkRepository
                                    .toggleBookmark('budaya', data.kodeTag);
                                if (!mounted) return;
                                setState(() {
                                  _isBookmarked = nowBookmarked;
                                });
                                messenger.clearSnackBars();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      nowBookmarked
                                          ? 'Berhasil disimpan ke Bookmark'
                                          : 'Berhasil dihapus dari Bookmark',
                                    ),
                                    duration: const Duration(
                                      milliseconds: 1200,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      // judul & tagline
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -100,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data.kategoriLabel.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data.judul,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  height: 1.5,
                                  width: 36,
                                  color: AppColors.primaryDark,
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    data.tagline,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                      color: AppColors.textDeep,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // deskripsi
                          DetailSectionBlock(
                            padding: const EdgeInsets.fromLTRB(22, 60, 22, 24),
                            title: 'Deskripsi',
                            content: data.deskripsi,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // section makna spiritual
                  if (data.maknaSpiritual != null &&
                      data.maknaSpiritual!.isNotEmpty) ...[
                    DetailSectionBlock(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                      title: 'Makna Spiritual',
                      content: data.maknaSpiritual!,
                    ),
                    if (data.gambarMaknaSpiritual != null &&
                        data.gambarMaknaSpiritual!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: AppImageView(
                              imagePath: data.gambarMaknaSpiritual!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],

                  // section konteks budaya
                  if (data.konteksBudaya != null &&
                      data.konteksBudaya!.isNotEmpty) ...[
                    DetailSectionBlock(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                      title: 'Konteks Budaya',
                      content: data.konteksBudaya!,
                    ),
                    if (data.gambarKonteksBudaya != null &&
                        data.gambarKonteksBudaya!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: AppImageView(
                              imagePath: data.gambarKonteksBudaya!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 20),

                  // section budaya lainnya
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budaya Lainnya',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 48,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(height: 16),
                        ScrollbarTheme(
                          data: const ScrollbarThemeData(
                            thumbColor: WidgetStatePropertyAll(
                              AppColors.primaryDark,
                            ),
                            trackColor: WidgetStatePropertyAll(
                              AppColors.scrollTrack,
                            ),
                          ),
                          child: Scrollbar(
                            controller: _scrollRelated,
                            interactive: true,
                            thumbVisibility: true,
                            trackVisibility: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            thickness: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SingleChildScrollView(
                                controller: _scrollRelated,
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      _otherBudayaList.length,
                                      (index) {
                                        final other = _otherBudayaList[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index <
                                                    _otherBudayaList.length - 1
                                                ? 14
                                                : 0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              context.push(
                                                DetailBudayaPage(budaya: other),
                                              );
                                            },
                                            child: SizedBox(
                                              width: 155,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    child: AspectRatio(
                                                      aspectRatio: 1,
                                                      child: Container(
                                                        color: AppColors
                                                            .surfaceMuted,
                                                        child: AppImageView(
                                                          imagePath:
                                                              other.gambarUtama,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    other.kodeTag,
                                                    style: AppTypography.tag(
                                                      color:
                                                          AppColors.primaryDark,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    other.judul,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        AppTypography.editorialSubheading(
                                                          color: AppColors
                                                              .textPrimary,
                                                        ).copyWith(
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          height: 1.25,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}
