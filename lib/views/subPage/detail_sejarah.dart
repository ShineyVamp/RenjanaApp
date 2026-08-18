import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/extensions/navigation.dart';

class DetailSejarah extends StatefulWidget {
  const DetailSejarah({super.key});

  @override
  State<DetailSejarah> createState() => _DetailSejarahState();
}

class _DetailSejarahState extends State<DetailSejarah> {
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
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: const Color(0xFF3A3530),
                                    child: const Center(
                                      child: Icon(
                                        Icons.radio,
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
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -90,
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '17.08.45',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFA9312E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Detik Proklamasi',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1C1815),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // RINGKASAN
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 45, 22, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ringkasan',
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
                                  'Proklamasi Kemerdekaan Indonesia, yang dibacakan pada 17 Agustus '
                                  '1945, menandai deklarasi resmi kedaulatan Republik Indonesia. '
                                  'Disusun secara tergesa-gesa di kediaman Laksamana Tadashi Maeda '
                                  'di Jakarta, dokumen singkat ini diketik oleh Sayuti Melik dan '
                                  'ditandatangani oleh Soekarno dan Mohammad Hatta. Tindakan ini '
                                  'memicu Revolusi Nasional Indonesia melawan kembalinya penjajahan '
                                  'Belanda.',
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

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // garis
                              if (!isLast)
                                Positioned(
                                  top: 8,
                                  bottom:
                                      -10, // catatan : bottom 0 biar container di passin sama ukuran akhir stack walaupun height diisi
                                  left: 3,
                                  child: Container(
                                    width: 1.5,
                                    color: const Color(0xFFD8CFBF),
                                  ),
                                ),

                              // penanda
                              Positioned(
                                top: 4,
                                left: 0,
                                child: Container(
                                  width: 7.5,
                                  height: 7.5,
                                  color: const Color(0xFFA9312E),
                                ),
                              ),

                              // komponen
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 22,
                                  bottom: 30,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['date'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: const Color(0xFFA9312E),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['title'] as String,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1C1815),
                                        height: 1.18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['desc'] as String,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        height: 1.55,
                                        color: const Color(0xFF4A443F),
                                      ),
                                    ),
                                    if (item['hasImage'] == true) ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: AspectRatio(
                                          aspectRatio: 16 / 10,
                                          child: Container(
                                            color: const Color(0xFFCFC8B8),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: 32,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  // kotak quiz
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

                  // sejarah lainnya
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
                                  padding: EdgeInsetsGeometry.only(bottom: 40),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      _relatedHistory.length,
                                      (index) {
                                        final item = _relatedHistory[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right:
                                                index <
                                                    _relatedHistory.length - 1
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
