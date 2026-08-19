import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/detail_section_block.dart';
import '../../core/widgets/detail_top_bar.dart';
import '../../core/widgets/quiz_card_widget.dart';
import '../../core/widgets/related_items_section.dart';

class DetailBudayaPage extends StatefulWidget {
  const DetailBudayaPage({super.key});

  @override
  State<DetailBudayaPage> createState() => _DetailBudayaPageState();
}

class _DetailBudayaPageState extends State<DetailBudayaPage> {
  bool _isBookmarked = false;

  final List<Map<String, String>> _relatedCulture = const [
    {'inv': 'INV. 1945-R-01', 'title': 'Parang'},
    {'inv': 'INV. 1945-B-01', 'title': 'Celurit'},
    {'inv': 'INV. 1945-K-01', 'title': 'Kujang'},
    {'inv': 'INV. 1945-M-01', 'title': 'Mandau'},
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
                  // header utama
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // gambar dan icon button
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.asset(
                              'assets/images/kerisB.jpg',
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

                      // judul dan iya
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
                                  'SENJATA TRADISIONAL',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFA9312E),
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'KERIS',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1C1815),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  height: 1.5,
                                  width: 36,
                                  color: const Color(0xFFA9312E),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Sebilah logam yang menyimpan\nwibawa, dan garis leluhur pemiliknya.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                    color: const Color(0xFF2A2420),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // deskripsi
                          const DetailSectionBlock(
                            padding: EdgeInsets.fromLTRB(22, 60, 22, 24),
                            title: 'Deskripsi',
                            content:
                                'Keris bukan sekadar senjata tikam, melainkan pusaka yang menyatukan seni '
                                'tempa, kepercayaan, dan status sosial. Dibuat oleh seorang empu melalui proses '
                                'tempa berulang, bilah keris menampilkan pamor—pola logam yang muncul dari '
                                'perpaduan besi dan meteorit. Setiap luk (lekuk) dan pamor dipercaya '
                                'membawa makna serta tuah tersendiri bagi pemiliknya.',
                          ),
                        ],
                      ),
                    ],
                  ),

                  // makna spiritual
                  const DetailSectionBlock(
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 24),
                    title: 'Makna Spiritual',
                    content:
                        'Bagi masyarakat Nusantara, keris diyakini menyimpan kekuatan spiritual yang '
                        'disebut tuah. Sebilah keris pusaka sering dianggap memiliki "penghuni" atau roh '
                        'penjaga yang mesti dirawat lewat ritual jamasan (pembersihan pusaka) setiap '
                        'tahun. Keris bukan hanya diwariskan sebagai benda, tetapi sebagai '
                        'penghubung antara pemiliknya dengan leluhur.',
                  ),

                  // kontegs budaya
                  const DetailSectionBlock(
                    padding: EdgeInsets.fromLTRB(22, 0, 22, 28),
                    title: 'Konteks Budaya',
                    content:
                        'Dalam kehidupan tradisional Jawa, keris menyertai berbagai peristiwa penting: '
                        'dikenakan pengantin pria saat pernikahan, diselipkan di pinggang bangsawan sebagai penanda '
                        'kedudukan, hingga diwariskan turun-temurun sebagai pusaka keluarga.\n\n'
                        'Proses pembuatannya bisa memakan waktu berbulan-bulan, melibatkan puasa dan ritual dari sang empu, '
                        'menjadikan keris bukan sekadar objek tempaan, melainkan karya yang lahir dari laku spiritual.',
                  ),

                  // kotak kuisz
                  const QuizCardWidget(),

                  // budaya terkait
                  RelatedItemsSection(
                    title: 'Budaya Terkait',
                    items: _relatedCulture,
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
