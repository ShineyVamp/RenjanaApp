import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/extensions/navigation.dart';

class DetailBudaya extends StatefulWidget {
  const DetailBudaya({super.key});

  @override
  State<DetailBudaya> createState() => _DetailBudayaState();
}

class _DetailBudayaState extends State<DetailBudaya> {
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
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: const Color(0xFF3A3530),
                                    child: const Center(
                                      child: Icon(
                                        Icons.shield_outlined,
                                        size: 80,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ),
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
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Material(
                                      color: const Color(0xFFA9312E),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () => context.pop(),
                                        child: const Padding(
                                          padding: EdgeInsets.all(9),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Material(
                                          color: const Color(0xFFA9312E),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {
                                              setState(() {
                                                _isBookmarked = !_isBookmarked;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(9),
                                              child: Icon(
                                                _isBookmarked
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Material(
                                          color: const Color(0xFFA9312E),
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () {},
                                            child: const Padding(
                                              padding: EdgeInsets.all(9),
                                              child: Icon(
                                                Icons.share_outlined,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 60, 22, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deskripsi',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1C1815),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 1.5,
                                  width: 48,
                                  color: const Color(0xFFA9312E),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Keris bukan sekadar senjata tikam, melainkan pusaka yang menyatukan seni '
                                  'tempa, kepercayaan, dan status sosial. Dibuat oleh seorang empu melalui proses '
                                  'tempa berulang, bilah keris menampilkan pamor—pola logam yang muncul dari '
                                  'perpaduan besi dan meteorit. Setiap luk (lekuk) dan pamor dipercaya '
                                  'membawa makna serta tuah tersendiri bagi pemiliknya.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    height: 1.6,
                                    color: const Color(0xFF4A443F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // makna spiritual
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Makna Spiritual',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1C1815),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 48,
                          color: const Color(0xFFA9312E),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bagi masyarakat Nusantara, keris diyakini menyimpan kekuatan spiritual yang '
                          'disebut tuah. Sebilah keris pusaka sering dianggap memiliki "penghuni" atau roh '
                          'penjaga yang mesti dirawat lewat ritual jamasan (pembersihan pusaka) setiap '
                          'tahun. Keris bukan hanya diwariskan sebagai benda, tetapi sebagai '
                          'penghubung antara pemiliknya dengan leluhur.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            height: 1.6,
                            color: const Color(0xFF4A443F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // kontegs budaya
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konteks Budaya',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1C1815),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 48,
                          color: const Color(0xFFA9312E),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dalam kehidupan tradisional Jawa, keris menyertai berbagai peristiwa penting: '
                          'dikenakan pengantin pria saat pernikahan, diselipkan di pinggang bangsawan sebagai penanda '
                          'kedudukan, hingga diwariskan turun-temurun sebagai pusaka keluarga.\n\n'
                          'Proses pembuatannya bisa memakan waktu berbulan-bulan, melibatkan puasa dan ritual dari sang empu, '
                          'menjadikan keris bukan sekadar objek tempaan, melainkan karya yang lahir dari laku spiritual.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            height: 1.6,
                            color: const Color(0xFF4A443F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // kotak kuisz
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFA9312E),
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.quiz_outlined,
                            color: Color(0xFFA9312E),
                            size: 30,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Uji Pemahaman',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1C1815),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9312E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'MULAI KUIS',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // budaya terkait
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budaya Terkait',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1C1815),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 1.5,
                          width: 48,
                          color: const Color(0xFFA9312E),
                        ),
                        const SizedBox(height: 16),
                        ScrollbarTheme(
                          data: const ScrollbarThemeData(
                            thumbColor: WidgetStatePropertyAll(
                              Color(0xFFA9312E),
                            ),
                            trackColor: WidgetStatePropertyAll(
                              Color(0x30D8CFBF),
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
                                  padding: const EdgeInsets.only(bottom: 40),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      _relatedCulture.length,
                                      (index) {
                                        final item = _relatedCulture[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index <
                                                    _relatedCulture.length - 1
                                                ? 14
                                                : 0,
                                          ),
                                          child: SizedBox(
                                            width: 155,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: AspectRatio(
                                                    aspectRatio: 1,
                                                    child: Container(
                                                      color: const Color(
                                                        0xFFCFC8B8,
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.image_outlined,
                                                          size: 28,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  item['inv']!,
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.6,
                                                        color: const Color(
                                                          0xFFA9312E,
                                                        ),
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item['title']!,
                                                  style:
                                                      GoogleFonts.playfairDisplay(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF1C1815,
                                                        ),
                                                        height: 1.25,
                                                      ),
                                                ),
                                              ],
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
