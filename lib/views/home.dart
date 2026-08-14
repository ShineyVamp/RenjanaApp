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
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700),
      child: Scaffold(
        backgroundColor: Color(0xffF4F0E7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            children: [
              Image.asset("assets/images/Rlogos.png", width: 35),
              Text("RENJANA", style: GoogleFonts.dmSerifDisplay(fontSize: 28)),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                spacing: 10,
                children: [
                  Icon(Icons.bookmark_border),
                  Icon(Icons.search, color: Color(0xffC9362B)),
                ],
              ),
            ),
          ],
          shape: Border(bottom: BorderSide(color: Color(0xffC9362B))),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 15),
                Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 250,
                          color: Color(0xffC9362B),
                          child: Text(
                            "Sejarah Hari Ini",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: SizedBox(
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Transform.rotate(
                                angle: -1 * (math.pi / 180),
                                child: Stack(
                                  children: [
                                    Container(
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
                                          color: Color(0xff32302E),
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          width: 5,
                                        ),
                                      ),
                                      child: Image.asset(
                                        alignment: Alignment.center,
                                        'assets/images/1308history.png',
                                        fit: BoxFit.cover,
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
                    SizedBox(height: 20),
                    Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
