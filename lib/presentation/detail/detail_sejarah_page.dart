import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/detail_top_bar.dart';
import '../../core/widgets/quiz_card_widget.dart';
import '../../core/widgets/related_items_section.dart';
import 'widgets/timeline_item_widget.dart';

class DetailSejarahPage extends StatefulWidget {
  const DetailSejarahPage({super.key});

  @override
  State<DetailSejarahPage> createState() => _DetailSejarahPageState();
}

class _DetailSejarahPageState extends State<DetailSejarahPage> {
  bool _isBookmarked = false;

  final List<Map<String, dynamic>> _timelineItems = [
    {
      'date': '16 AGUSTUS 1945 · 03:00 WIB',
      'title': 'Peristiwa\nRengasdengklok',
      'desc':
          'Golongan muda menculik Soekarno dan Hatta ke Rengasdengklok. '
          'Tindakan radikal ini bertujuan menjauhkan dwi tunggal dari '
          'pengaruh Jepang dan mendesak percepatan proklamasi. Sebuah '
          'langkah berani yang mengunci komitmen kemerdekaan.',
      'imgPath': 'assets/images/rengasdengklok.jpg',
      'hasImage': true,
    },
    {
      'date': '16 AGUSTUS 1945 · 23:00 WIB',
      'title': 'Perumusan Naskah',
      'desc':
          'Di rumah Laksamana Maeda, tokoh-tokoh bangsa berkumpul. Soekarno, '
          'Hatta, dan Ahmad Soebardjo merumuskan teks proklamasi di ruang '
          'makan. Kalimat "Kami bangsa Indonesia..." lahir dari sintesis '
          'pemikiran para pendiri bangsa di bawah tekanan waktu.',
      'imgPath': null,
      'hasImage': false,
    },
    {
      'date': '17 AGUSTUS 1945 · 10:00 WIB',
      'title': 'Proklamasi',
      'desc':
          'Di Jalan Pegangsaan Timur No. 56, naskah dibacakan. Bendera Merah '
          'Putih jahitan Ibu Fatmawati dikibarkan. Sebuah upacara '
          'sederhana tanpa protokol megah, namun gaungnya meruntuhkan '
          'ratusan tahun kolonialisme.',
      'imgPath': 'assets/images/perumusan.jpg',
      'hasImage': true,
    },
  ];

  final List<Map<String, String>> _relatedHistory = const [
    {'inv': 'INV. 1945-R-01', 'title': 'Radio Pemancar Berita Proklamasi'},
    {'inv': 'INV. 1945-B-01', 'title': 'Bendera Pusaka Jahitan Fatmawati'},
    {'inv': 'INV. 1945-B-01', 'title': 'Bendera Pusaka Jahitan Fatmawati'},
    {'inv': 'INV. 1945-B-01', 'title': 'Bendera Pusaka Jahitan Fatmawati'},
  ];

  final ScrollController _scrollRelated = ScrollController();

  @override
  void dispose() {
    _scrollRelated.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E7),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Image dan ikon dan gradient
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AspectRatio(
                            aspectRatio: 1.1,
                            child: Image.asset(
                              'assets/images/170845history.png',
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
                                    Color(0x00F4F0E7),
                                    Color(0xFFF4F0E7),
                                  ],
                                  stops: [0, 1],
                                ),
                              ),
                            ),
                          ),

                          // Tombol Top Bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: DetailTopBar(
                              isBookmarked: _isBookmarked,
                              onBookmarkToggle: () {
                                setState(() {
                                  _isBookmarked = !_isBookmarked;
                                });
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '17.08.45',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 54,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFA9312E),
                                  ),
                                ),
                                Text(
                                  'Detik Proklamasi',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1C1815),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // RINGKASAN
                          const DetailSectionBlock(
                            padding: EdgeInsets.fromLTRB(22, 50, 22, 24),
                            title: 'Ringkasan',
                            content:
                                'Proklamasi Kemerdekaan Indonesia, yang dibacakan pada 17 Agustus '
                                '1945, menandai deklarasi resmi kedaulatan Republik Indonesia. '
                                'Disusun secara tergesa-gesa di kediaman Laksamana Tadashi Maeda '
                                'di Jakarta, dokumen singkat ini diketik oleh Sayuti Melik dan '
                                'ditandatangani oleh Soekarno dan Mohammad Hatta. Tindakan ini '
                                'memicu Revolusi Nasional Indonesia melawan kembalinya penjajahan '
                                'Belanda.',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Alur Peristiwa
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
                            color: const Color(0xFF1C1815),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 100,
                          color: const Color(0xFFA9312E),
                        ),
                        const SizedBox(height: 20),
                        // dikasih ... biar bisa didalam column (seharusnya gabisa)
                        ...List.generate(_timelineItems.length, (index) {
                          final item = _timelineItems[index];
                          final bool isLast =
                              index == _timelineItems.length - 1;

                          return TimelineItemWidget(
                            date: item['date'] as String,
                            title: item['title'] as String,
                            description: item['desc'] as String,
                            imagePath: item['hasImage'] == true
                                ? item['imgPath'] as String?
                                : null,
                            isLast: isLast,
                          );
                        }),
                      ],
                    ),
                  ),

                  // kotak quiz
                  const QuizCardWidget(),

                  // sejarah lainnya
                  RelatedItemsSection(
                    title: 'Sejarah Lainnya',
                    items: _relatedHistory,
                    scrollController: _scrollRelated,
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
