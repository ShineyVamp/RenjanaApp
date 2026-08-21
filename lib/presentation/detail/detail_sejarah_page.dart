import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_image.dart';
import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/detail_top_bar.dart';
import '../../data/models/sejarah_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../data/repositories/sejarah_repository.dart';
import 'widgets/timeline_item_widget.dart';

class DetailSejarahPage extends StatefulWidget {
  final SejarahModel sejarah;

  const DetailSejarahPage({super.key, required this.sejarah});

  @override
  State<DetailSejarahPage> createState() => _DetailSejarahPageState();
}

class _DetailSejarahPageState extends State<DetailSejarahPage> {
  final SejarahRepository _sejarahRepository = SejarahRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  bool _isBookmarked = false;
  final ScrollController _scrollRelated = ScrollController();
  List<SejarahModel> _otherSejarahList = [];

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _loadOtherSejarah();
  }

  Future<void> _checkBookmarkStatus() async {
    final data = widget.sejarah;
    final bookmarked = await _bookmarkRepository.isBookmarked(data.kodeTag);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
    });
  }

  Future<void> _loadOtherSejarah() async {
    final list = await _sejarahRepository.getRandomSejarahList(
      count: 5,
      exclude: widget.sejarah,
    );
    if (!mounted) return;
    setState(() {
      _otherSejarahList = list;
    });
  }

  @override
  void dispose() {
    _scrollRelated.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sejarah;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // gambar utama
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.1,
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
                                  .toggleBookmark('sejarah', data.kodeTag);
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
                                  duration: const Duration(milliseconds: 1200),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -100,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    data.subtitle,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 54,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  data.judul,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ringkasan
                        DetailSectionBlock(
                          padding: const EdgeInsets.fromLTRB(22, 50, 22, 20),
                          title: 'Ringkasan',
                          content: data.ringkasan,
                        ),
                      ],
                    ),
                  ],
                ),

                // section alur peristiwa
                if (data.alurPeristiwa.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alur Peristiwa',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 100,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(data.alurPeristiwa.length, (index) {
                          final item = data.alurPeristiwa[index];
                          final bool isLast =
                              index == data.alurPeristiwa.length - 1;

                          return TimelineItemWidget(
                            date: item.date,
                            title: item.title,
                            description: item.desc,
                            imagePath: item.hasImage ? item.imgPath : null,
                            isLast: isLast,
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // section sejarah lainnya
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sejarah Lainnya',
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                    _otherSejarahList.length,
                                    (index) {
                                      final other = _otherSejarahList[index];
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              index <
                                                  _otherSejarahList.length - 1
                                              ? 14
                                              : 0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            context.push(
                                              DetailSejarahPage(sejarah: other),
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
                                                      BorderRadius.circular(6),
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
    );
  }
}
