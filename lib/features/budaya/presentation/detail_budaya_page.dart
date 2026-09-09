import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/budaya_kategori.dart';
import '../../../core/constants/wilayah_nusantara.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/asal_daerah_block.dart';
import '../../../core/widgets/blok_kontributor.dart';
import '../../../core/widgets/detail_list_block.dart';
import '../../../core/widgets/detail_section_block.dart';
import '../../../core/widgets/detail_spec_block.dart';
import '../../../core/widgets/detail_top_bar.dart';
import '../../../core/widgets/media_arsip.dart';
import '../../../core/widgets/tombol_koreksi.dart';
import 'package:renjana/features/kontribusi/data/models/blok_konten_model.dart';
import 'package:renjana/features/kontribusi/data/models/usulan_model.dart';
import 'package:renjana/features/bookmark/data/repositories/bookmark_repository.dart';
import 'package:renjana/features/kontribusi/presentation/form_usulan_page.dart';
import 'package:renjana/features/wilayah/presentation/detail_provinsi_page.dart';
import 'package:renjana/core/utils/share_helper.dart';
import 'package:renjana/core/utils/map_launcher.dart';
import '../../capaian/services/pencatat_bacaan.dart';
import 'package:renjana/features/sejarah/presentation/widgets/timeline_item_widget.dart';
import 'package:renjana/features/budaya/data/models/budaya_model.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';

class DetailBudayaPage extends StatefulWidget {
  final BudayaModel budaya;

  const DetailBudayaPage({super.key, required this.budaya});

  @override
  State<DetailBudayaPage> createState() => _DetailBudayaPageState();
}

class _DetailBudayaPageState extends State<DetailBudayaPage> {
  final BudayaRepository _budayaRepository = BudayaRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  final PencatatBacaan _pencatat = PencatatBacaan();
  bool _isBookmarked = false;
  final ScrollController _scrollRelated = ScrollController();
  List<BudayaModel> _otherBudayaList = [];

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _loadOtherBudaya();
    _pencatat.mulai('budaya', widget.budaya.kodeTag);
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
    _pencatat.batalkan();
    _scrollRelated.dispose();
    super.dispose();
  }


  // Destinasi bisa dikunjungi langsung, jadi diberi pintasan ke aplikasi peta.
  Widget _buildTombolPeta(BudayaModel data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () => bukaLokasiDiPeta(
            context,
            namaTempat: data.judul,
            provinsi: data.provinsi,
          ),
          icon: const Icon(
            Icons.map_outlined,
            size: 18,
            color: AppColors.primary,
          ),
          label: Text(
            'Buka lokasi di aplikasi peta',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _usulkanKoreksi(BudayaModel data) async {
    await context.push(FormUsulanPage(usulanAwal: Usulan.koreksiBudaya(data)));
  }

  Future<void> _bagikan(BudayaModel data) => bagikanArsip(
    context,
    judul: data.judul,
    jenis: data.kategoriLabel,
    keterangan: data.tagline.isNotEmpty ? data.tagline : data.deskripsi,
    kodeTag: data.kodeTag,
    provinsi: data.provinsi,
  );

  void _bukaProvinsi(String? namaProvinsi) {
    final provinsi = provinsiDariNama(namaProvinsi);
    if (provinsi == null) return;
    context.push(DetailProvinsiPage(provinsi: provinsi));
  }

  List<Widget> _buildSectionKategori(BudayaModel data) {
    final daftarField = fieldKategori(data.jenis);
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

  List<Widget> _buildBlokDinamis(BudayaModel data) {
    final raw = data.detailKategori['blokKonten'];
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final imageWidth = constraints.maxWidth;
                  final imageHeight = imageWidth;
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
                                aspectRatio: 1,
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

                      // konten halaman
                      Column(
                        children: [
                          SizedBox(height: imageHeight - overlap),
                          // Header: kategori, judul, garis divider, dan tagline
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
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
                                const SizedBox(height: 4),
                                Text(
                                  data.judul,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 1.5,
                                  width: 36,
                                  color: AppColors.primaryDark,
                                ),
                                if (data.tagline.isNotEmpty) ...[
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
                              ],
                            ),
                          ),

                          // Deskripsi
                          DetailSectionBlock(
                            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                            title: 'Deskripsi',
                            content: data.deskripsi,
                          ),

                  ..._buildSectionKategori(data),

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

                  // seksi konten dinamis
                  ..._buildBlokDinamis(data),

                  // section asal daerah
                  AsalDaerahBlock(
                    namaProvinsi: data.provinsi,
                    onLihatProvinsi: () => _bukaProvinsi(data.provinsi),
                  ),

                  // section kontributor
                  BlokKontributor(nama: data.kontributor),

                  // section lokasi, hanya untuk item yang juga tempat wisata
                  if (data.isDestinasi) _buildTombolPeta(data),

                  const SizedBox(height: 14),

                  // section usulan koreksi
                  TombolKoreksi(onTap: () => _usulkanKoreksi(data)),

                  const SizedBox(height: 24),

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

              // 3. Tombol navigasi atas (Back, Home, Bookmark, Share)
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
          );
        },
      ),
    ),
  ),
),
),
);
}
}
