import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RelatedItemsSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final ScrollController scrollController;

  const RelatedItemsSection({
    super.key,
    required this.title,
    required this.items,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1815),
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1.5, width: 48, color: const Color(0xFFA9312E)),
          const SizedBox(height: 16),
          ScrollbarTheme(
            data: const ScrollbarThemeData(
              thumbColor: WidgetStatePropertyAll(Color(0xFFA9312E)),
              trackColor: WidgetStatePropertyAll(Color(0x30D8CFBF)),
            ),
            child: Scrollbar(
              controller: scrollController,
              interactive: true,
              thumbVisibility: true,
              trackVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              thickness: 4,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < items.length - 1 ? 14 : 0,
                          ),
                          child: SizedBox(
                            width: 155,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      color: const Color(0xFFCFC8B8),
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
                                  item['inv'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: const Color(0xFFA9312E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['title'] ?? '',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1C1815),
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
