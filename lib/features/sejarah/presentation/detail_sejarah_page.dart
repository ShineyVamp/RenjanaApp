import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/katalog_kategori.dart';
import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/asal_daerah_block.dart';
import '../../../core/widgets/blok_kontributor.dart';
import '../../../core/widgets/detail_list_block.dart';
import '../../../core/widgets/detail_section_block.dart';
import '../../../core/widgets/detail_spec_block.dart';
import '../../../core/widgets/detail_top_bar.dart';
import '../../../core/widgets/indikator_baca_arsip.dart';
import '../../../core/widgets/media_arsip.dart';
import '../../../core/widgets/tombol_diskusikan.dart';
import '../../../core/widgets/tombol_koreksi.dart';
import 'package:renjana/features/komunitas/presentation/form_diskusi_page.dart';
import 'package:renjana/features/kontribusi/data/models/blok_konten_model.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';
import 'package:renjana/features/bookmark/data/repositories/bookmark_repository.dart';
import 'package:renjana/features/kontribusi/presentation/form_usulan_page.dart';
import 'package:renjana/features/wilayah/presentation/detail_provinsi_page.dart';
import 'package:renjana/core/utils/share_helper.dart';
import '../../capaian/services/pencatat_bacaan.dart';
import '../../capaian/data/repositories/arsip_dibaca_repository.dart';
import '../../capaian/data/repositories/riwayat_repository.dart';
import '../data/models/sejarah_model.dart';
import '../data/repositories/sejarah_repository.dart';
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
  final ArsipDibacaRepository _arsipDibacaRepository = ArsipDibacaRepository();
  final RiwayatRepository _riwayatRepository = RiwayatRepository();
  final PencatatBacaan _pencatat = PencatatBacaan();
  bool _isBookmarked = false;
  final ScrollController _scrollRelated = ScrollController();
  List<SejarahModel> _otherSejarahList = [];
  final ValueNotifier<int> _detikNotifier = ValueNotifier<int>(PencatatBacaan.totalDetik);
  final ValueNotifier<bool> _bacaSelesaiNotifier = ValueNotifier<bool>(false);

  late final List<Widget> _sectionPeristiwaWidgets;
  late final List<Widget> _blokDinamisWidgets;

  static final Map<String, List<SejarahModel>> _cacheRelatedSejarah = {};

  // section siklus hidup
  @override
  void initState() {
    super.initState();
    _riwayatRepository.catatDibuka('sejarah', widget.sejarah.kodeTag);
    _sectionPeristiwaWidgets = _buildSectionPeristiwa(widget.sejarah);
    _blokDinamisWidgets = _buildBlokDinamis(widget.sejarah);
    final cached = _cacheRelatedSejarah[widget.sejarah.kodeTag];
    if (cached != null && cached.isNotEmpty) {
      _otherSejarahList = cached;
    }
    _checkBookmarkStatus();
    _checkStatusBacaan();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (cached == null || cached.isEmpty)) _loadOtherSejarah();
    });
  }

  // section status bacaan
  Future<void> _checkStatusBacaan() async {
    final sudah = await _arsipDibacaRepository.sudahDibaca(
      'sejarah',
      widget.sejarah.kodeTag,
    );
    if (!mounted) return;
    if (sudah) {
      _bacaSelesaiNotifier.value = true;
    } else {
      _pencatat.mulai(
        'sejarah',
        widget.sejarah.kodeTag,
        onTick: (sisa) {
          _detikNotifier.value = sisa;
        },
        onSelesai: () {
          _bacaSelesaiNotifier.value = true;
        },
      );
    }
  }

  @override
  void dispose() {
    _pencatat.batalkan();
    _detikNotifier.dispose();
    _bacaSelesaiNotifier.dispose();
    _scrollRelated.dispose();
    super.dispose();
  }

  // section bookmark
  Future<void> _checkBookmarkStatus() async {
    final data = widget.sejarah;
    final bookmarked = await _bookmarkRepository.isBookmarked(data.kodeTag);
    if (!mounted) return;
    setState(() {
      _isBookmarked = bookmarked;
    });
  }

  // section arsip lainnya
  Future<void> _loadOtherSejarah() async {
    final list = await _sejarahRepository.getRandomSejarahList(
      count: 5,
      exclude: widget.sejarah,
    );
    _cacheRelatedSejarah[widget.sejarah.kodeTag] = list;
    if (!mounted) return;
    setState(() {
      _otherSejarahList = list;
    });
  }

  Future<void> _bukaDiskusi(SejarahModel data) async {
    await context.push(FormDiskusiPage(refArsipAwal: data.kodeTag));
  }

  Future<void> _usulkanKoreksi(SejarahModel data) async {
    await context.push(FormUsulanPage(usulanAwal: Usulan.koreksiSejarah(data)));
  }

  Future<void> _bagikan(SejarahModel data) => bagikanArsip(
    context,
    judul: data.judul,
    jenis: 'Sejarah',
    keterangan: data.ringkasan,
    kodeTag: data.kodeTag,
    provinsi: data.provinsi,
  );

  void _bukaProvinsi(String? namaProvinsi) {
    final provinsi = provinsiDariNama(namaProvinsi);
    if (provinsi == null) return;
    context.push(DetailProvinsiPage(provinsi: provinsi));
  }

  // section bidang spesifik peristiwa
  List<Widget> _buildSectionPeristiwa(SejarahModel data) {
    if (data.jenisPeristiwa == null || data.jenisPeristiwa!.isEmpty) {
      return const [];
    }
    final daftarField = fieldPeristiwa(data.jenisPeristiwa!);
    if (daftarField.isEmpty) return const [];

    final ringkas = <SpecItem>[];
    final panjang = <Widget>[];

    for (final field in daftarField) {
      if (!data.adaDetail(field.kunci)) continue;

      switch (field.tipe) {
        case TipeField.teks:
          ringkas.add(SpecItem(field.label, data.teksDetail(field.kunci)));
        case TipeField.teksPanjang:
          panjang.add(
            DetailSectionBlock(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              title: field.label,
              content: data.teksDetail(field.kunci),
            ),
          );
        case TipeField.daftar:
          panjang.add(
            DetailListBlock(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              title: field.label,
              items: data.daftarDetail(field.kunci),
            ),
          );
      }
    }

    return [
      if (ringkas.isNotEmpty) DetailSpecBlock(items: ringkas),
      ...panjang,
    ];
  }

  List<Widget> _buildBlokDinamis(SejarahModel data) {
    final raw = data.detailPeristiwa['blokKonten'];
    final blokList = BlokKontenModel.listFromDynamic(raw);
    if (blokList.isEmpty) return const [];

    final widgets = <Widget>[];
    for (final b in blokList) {
      switch (b.tipe) {
        case TipeBlokKonten.teksPanjang:
          widgets.add(
            DetailSectionBlock(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              title: b.judul,
              content: b.teks,
            ),
          );
        case TipeBlokKonten.daftar:
          widgets.add(
            DetailListBlock(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              title: b.judul,
              items: b.daftar,
            ),
          );
        case TipeBlokKonten.timeline:
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailSectionBlock(
                    padding: EdgeInsets.zero,
                    title: b.judul,
                    content: '',
                  ),
                  const SizedBox(height: 12),
                  ...b.timeline.asMap().entries.map((e) {
                    return TimelineItemWidget(
                      date: e.value.date,
                      title: e.value.title,
                      description: e.value.desc,
                      imagePath: e.value.hasImage ? e.value.imgPath : null,
                      isLast: e.key == b.timeline.length - 1,
                    );
                  }),
                ],
              ),
            ),
          );
        case TipeBlokKonten.spesifikasi:
          widgets.add(
            DetailSpecBlock(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              items: b.spesifikasi,
            ),
          );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.sejarah;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageWidth = constraints.maxWidth;
                    final imageHeight = imageWidth / 1.1;
                    const overlap = 95.0;

                    return Stack(
                      children: [
                        SizedBox(
                          height: imageHeight,
                          width: imageWidth,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: MediaArsipView(
                                  gambarUtama: data.gambarUtama,
                                  jenisMedia: data.jenisMedia,
                                  mediaUrl: data.mediaUrl,
                                  judul: data.judul,
                                  aspectRatio: 1.1,
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
                                      stops: [0.25, 1],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: imageHeight - overlap),
                            Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (data.subtitle.isNotEmpty)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    data.subtitle,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                data.judul,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                  height: 1.15,
                                ),
                              ),
                              if ((data.periode != null &&
                                      data.periode!.isNotEmpty) ||
                                  (data.jenisPeristiwa != null &&
                                      data.jenisPeristiwa!.isNotEmpty)) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    if (data.periode != null &&
                                        data.periode!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryDark
                                              .withAlpha(25),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.borderPrimary,
                                          ),
                                        ),
                                        child: Text(
                                          data.namaPeriodeLabel,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    if (data.jenisPeristiwa != null &&
                                        data.jenisPeristiwa!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          data.namaPeristiwaLabel,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        DetailSectionBlock(
                          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                          title: 'Ringkasan',
                          content: data.ringkasan,
                        ),

                        // section field jenis peristiwa
                        ..._sectionPeristiwaWidgets,

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
                                ...List.generate(data.alurPeristiwa.length, (
                                  index,
                                ) {
                                  final item = data.alurPeristiwa[index];
                                  final bool isLast =
                                      index == data.alurPeristiwa.length - 1;

                                  return TimelineItemWidget(
                                    date: item.date,
                                    title: item.title,
                                    description: item.desc,
                                    imagePath: item.hasImage
                                        ? item.imgPath
                                        : null,
                                    isLast: isLast,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],

                        // section konten dinamis
                        ..._blokDinamisWidgets,

                        // section asal daerah
                        AsalDaerahBlock(
                          namaProvinsi: data.provinsi,
                          onLihatProvinsi: () => _bukaProvinsi(data.provinsi),
                        ),

                        // section kontributor
                        BlokKontributor(nama: data.kontributor),

                        const SizedBox(height: 10),

                        // section diskusikan di komunitas
                        TombolDiskusikan(onTap: () => _bukaDiskusi(data)),

                        const SizedBox(height: 10),

                        // section usulan koreksi
                        TombolKoreksi(onTap: () => _usulkanKoreksi(data)),

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
                                  scrollbarOrientation:
                                      ScrollbarOrientation.bottom,
                                  thickness: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SingleChildScrollView(
                                      controller: _scrollRelated,
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                            _otherSejarahList.length,
                                            (index) {
                                              final other =
                                                  _otherSejarahList[index];
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  right:
                                                      index <
                                                          _otherSejarahList
                                                                  .length -
                                                              1
                                                      ? 14
                                                      : 0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    context.push(
                                                      DetailSejarahPage(
                                                        sejarah: other,
                                                      ),
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    width: 155,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                                imagePath: other
                                                                    .gambarUtama,
                                                                fit: BoxFit
                                                                    .cover,
                                                                cacheWidth: 320,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          other.kodeTag,
                                                          style:
                                                              AppTypography.tag(
                                                                color: AppColors
                                                                    .primaryDark,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          other.judul,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              AppTypography.editorialSubheading(
                                                                color: AppColors
                                                                    .textPrimary,
                                                              ).copyWith(
                                                                fontSize: 13.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
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
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: DetailTopBar(
                        isBookmarked: _isBookmarked,
                        onShare: () => _bagikan(data),
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
                );
              },
            ),
          ),
        ),
        // section floating indikator bacaan
        ValueListenableBuilder<bool>(
          valueListenable: _bacaSelesaiNotifier,
          builder: (context, selesai, _) {
            if (selesai) return const SizedBox.shrink();
            return Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _detikNotifier,
                      builder: (context, detik, _) {
                        return IndikatorBacaArsip(
                          detikTersisa: detik,
                          sudahSelesai: false,
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
  ),
);
  }
}
