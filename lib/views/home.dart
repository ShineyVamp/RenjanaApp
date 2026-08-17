import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollDestinasi = ScrollController();
  final ScrollController _scrollBudaya = ScrollController();
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700),
      child: Scaffold(
        backgroundColor: Color(0xffF4F0E7),
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              surfaceTintColor: Color(0xffF4F0E7),
              backgroundColor: Color(0xffF4F0E7),
              floating: true,
              title: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final transparansi =
                          IconTheme.of(context).opacity ??
                          DefaultTextStyle.of(context).style.color?.a ??
                          1.0;

                      return Opacity(
                        opacity: transparansi,
                        child: Image.asset(
                          "assets/images/Rlogos.png",
                          width: 35,
                        ),
                      );
                    },
                  ),
                  Text(
                    "RENJANA",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 28),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Row(
                    spacing: 10,
                    children: [Icon(Icons.bookmark_border)],
                  ),
                ),
              ],
              shape: Border(bottom: BorderSide(color: Color(0xffC9362B))),
            ),
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TEKS TANGGAL DAN USER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          DateFormat(
                            "EEEE, dd MMMM yyyy",
                            'id_ID',
                          ).format(DateTime.now()),
                          style: GoogleFonts.plusJakartaSans(fontSize: 18),
                        ),
                        Text(
                          "Selamat pagi, Agus",
                          style: GoogleFonts.dmSerifDisplay(fontSize: 30),
                        ),
                        SizedBox(height: 10),
                        Divider(color: Color(0xffC9362B)),
                        SizedBox(height: 30),
                        Column(
                          children: [
                            // SEJARAH HARI INI
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: -15,
                                  top: -40,
                                  child: Text(
                                    "01",
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 90,
                                      color: Color(0x50C9362B),
                                    ),
                                  ),
                                ),
                                // LAYOUT SEJARAH HARI INI
                                Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Container(
                                      color: Color(0xffC9362B),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          "Sejarah Hari Ini",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 23,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // STACK GAMBAR DAN ID
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Transform.rotate(
                                                angle: -1 * (math.pi / 180),
                                                child: Container(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        blurRadius: 5,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      strokeAlign: BorderSide
                                                          .strokeAlignOutside,
                                                      width: 5,
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    alignment: Alignment.center,
                                                    'assets/images/1308history.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -10,
                                          right: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xffC9362B),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                  ),
                                              child: Text(
                                                "HIS-150845-A",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // DESKRIPSI SEJARAH HARI INI
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Text(
                                    "Runtuhnya Tirani",
                                    style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 40,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Divider(color: Color(0xffC9362B)),
                                  ),
                                  Text(
                                    "15 Agustus 1945: Saat kekosongan kekuasaan dunia membuka jalan keberanian bagi para pendiri bangsa untuk memproklamasikan kemerdekaan sejati.",
                                    style: GoogleFonts.plusJakartaSans(),
                                    textAlign: TextAlign.justify,
                                  ),
                                  SizedBox(height: 20),
                                  // TOMBOL MASUKI KISAH
                                  GestureDetector(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(0xffC9362B),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(
                                          "Masuki Kisah",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        // BUDAYA HARI INI
                        Row(
                          mainAxisAlignment: .end,
                          children: [
                            SizedBox(width: 10),
                            Container(
                              color: Color(0xffC9362B),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Text(
                                  "Budaya Hari Ini",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        // LAYOUTING BUDAYA
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: -90,
                              left: -15,
                              child: Text(
                                "02",
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 90,
                                  color: Color(0x50C9362B),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 10,
                                              spreadRadius: -7,
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/images/kerisB.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffC9362B),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          "BUD-SNJT-1",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Q-RIS",
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 30,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Lebih dari sekadar senjata, keris adalah mahakarya seni tempa, perwujudan doa, dan simbol identitas kultural yang mendalam. Pola pamornya mengisahkan filsafat alam semesta.",
                                      style: GoogleFonts.plusJakartaSans(),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Row(
                                        mainAxisAlignment: .end,
                                        children: [
                                          Text(
                                            "Pelajari lebih lanjut",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              color: Color(0xffC9362B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // KOLEKSI BUDAYA
                  Column(
                    children: [
                      Text(
                        "03",
                        style: GoogleFonts.dmSerifDisplay(
                          height: 1,
                          fontSize: 90,
                          color: Color(0x50C9362B),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Koleksi Budaya",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: Divider(color: Color(0xffC9362B)),
                      ),
                      SizedBox(height: 20),
                      // ISIAN KOLEKSI BUDAYA
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStatePropertyAll(
                              const Color(0xffC9362B),
                            ),
                          ),
                          child: Scrollbar(
                            interactive: true,
                            controller: _scrollBudaya,
                            thumbVisibility: true,
                            trackVisibility: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            thickness: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Builder(
                                builder: (context) {
                                  const double itemWidth = 372;
                                  final double screenWidth = MediaQuery.of(
                                    context,
                                  ).size.width;
                                  final double sidePadding =
                                      (screenWidth - itemWidth) / 2;
                                  return SingleChildScrollView(
                                    controller: _scrollBudaya,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          screenWidth <= 700 && sidePadding > 0
                                          ? sidePadding - 20
                                          : 0,
                                    ),
                                    child: Row(
                                      children: List.generate(5, (index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index < 4 ? 20 : 0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0x50C9362B),
                                              ),
                                            ),
                                            width: itemWidth,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 10,
                                                    ),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/images/kerisB.jpg',
                                                    width: 400,
                                                    color: Colors.grey,
                                                    colorBlendMode:
                                                        BlendMode.saturation,
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        gradient: LinearGradient(
                                                          begin:
                                                              AlignmentGeometry
                                                                  .topCenter,
                                                          end: AlignmentGeometry
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withAlpha(20),
                                                            Colors.black
                                                                .withAlpha(30),
                                                            Colors.black
                                                                .withAlpha(400),
                                                            Colors.black
                                                                .withAlpha(725),
                                                          ],
                                                          stops: [
                                                            0,
                                                            0.45,
                                                            0.55,
                                                            0.85,
                                                            1,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 30,
                                                          vertical: 30,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          .start,
                                                      children: [
                                                        Text(
                                                          "Pusaka",
                                                          style:
                                                              GoogleFonts.dmSerifDisplay(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                                height: 0,
                                                              ),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Row(
                                                          mainAxisSize: .min,
                                                          children: [
                                                            Text(
                                                              "Jelajahi lebih lanjut",
                                                              style: GoogleFonts.plusJakartaSans(
                                                                fontSize: 16,
                                                                color: Color(
                                                                  0xffC9362B,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Transform.translate(
                                                              offset: Offset(
                                                                0,
                                                                1.2,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                color: Color(
                                                                  0xffC9362B,
                                                                ),
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // PILIHAN DESTINASI
                  Column(
                    children: [
                      Text(
                        "04",
                        style: GoogleFonts.dmSerifDisplay(
                          height: 1,
                          fontSize: 90,
                          color: Color(0x50C9362B),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "Pilihan Destinasi",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: Divider(color: Color(0xffC9362B)),
                      ),
                      SizedBox(height: 20),
                      // ISIAN PILIHAN DESTINASI
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStatePropertyAll(
                              const Color(0xffC9362B),
                            ),
                          ),
                          child: Scrollbar(
                            interactive: true,
                            controller: _scrollDestinasi,
                            thumbVisibility: true,
                            trackVisibility: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            thickness: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40),
                              child: Builder(
                                builder: (context) {
                                  const double itemWidth = 372;
                                  final double screenWidth = MediaQuery.of(
                                    context,
                                  ).size.width;
                                  final double sidePadding =
                                      (screenWidth - itemWidth) / 2;
                                  return SingleChildScrollView(
                                    controller: _scrollDestinasi,
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          screenWidth <= 700 && sidePadding > 0
                                          ? sidePadding - 20
                                          : 0,
                                    ),
                                    child: Row(
                                      children: List.generate(5, (index) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index < 4 ? 20 : 0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0x50C9362B),
                                              ),
                                            ),
                                            width: itemWidth,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 10,
                                                    ),
                                                  ),
                                                  child: AspectRatio(
                                                    aspectRatio: 4 / 3,
                                                    child: Image.asset(
                                                      'assets/images/borobudurB.jpg',
                                                      width: 400,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned.fill(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    child: DecoratedBox(
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        gradient: LinearGradient(
                                                          begin:
                                                              AlignmentGeometry
                                                                  .topCenter,
                                                          end: AlignmentGeometry
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withAlpha(20),
                                                            Colors.black
                                                                .withAlpha(30),
                                                            Colors.black
                                                                .withAlpha(400),
                                                            Colors.black
                                                                .withAlpha(725),
                                                          ],
                                                          stops: [
                                                            0,
                                                            0.45,
                                                            0.55,
                                                            0.85,
                                                            1,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 30,
                                                          vertical: 30,
                                                        ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          .start,
                                                      children: [
                                                        Text(
                                                          "Candi Borobudur",
                                                          style:
                                                              GoogleFonts.dmSerifDisplay(
                                                                fontSize: 30,
                                                                color: Colors
                                                                    .white,
                                                                height: -1,
                                                              ),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Text(
                                                          "Jawa Tengah",
                                                          style:
                                                              GoogleFonts.plusJakartaSans(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        Row(
                                                          mainAxisSize: .min,
                                                          children: [
                                                            Text(
                                                              "Jelajahi lebih lanjut",
                                                              style: GoogleFonts.plusJakartaSans(
                                                                fontSize: 16,
                                                                color: Color(
                                                                  0xffC9362B,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            Transform.translate(
                                                              offset: Offset(
                                                                0,
                                                                1.2,
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                color: Color(
                                                                  0xffC9362B,
                                                                ),
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Color(0x50C9362B)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              Icon(
                                Icons.history_edu_rounded,
                                color: Color(0xffC9362B),
                                size: 40,
                              ),
                              Text(
                                "Turut Melestarikan Sejarah",
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Bantu kami melestarikan arsip dan narasi budaya yang belum tercatat. setiap kontribusi bermakna.",
                                style: GoogleFonts.plusJakartaSans(),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xffC9362B),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(
                                      "Mulai Melestarikan",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
