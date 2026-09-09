import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

// widget teks dengan sorotan mention
class TeksDenganMention extends StatelessWidget {
  final String teks;
  final TextStyle? style;
  final TextStyle? mentionStyle;
  final List<String> kandidatNama;

  const TeksDenganMention({
    super.key,
    required this.teks,
    this.style,
    this.mentionStyle,
    this.kandidatNama = const [],
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ??
        GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          height: 1.45,
          color: AppColors.textPrimary,
        );

    final defaultMentionStyle = mentionStyle ??
        GoogleFonts.plusJakartaSans(
          fontSize: defaultStyle.fontSize,
          height: defaultStyle.height,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        );

    // bangun pola regex dari daftar kandidat nama dan pola umum
    final polaNama = <String>[];
    for (final nama in kandidatNama) {
      final n = nama.trim();
      if (n.isNotEmpty) {
        polaNama.add(RegExp.escape(n));
      }
    }

    String pattern;
    if (polaNama.isNotEmpty) {
      polaNama.sort((a, b) => b.length.compareTo(a.length));
      pattern = '(@(?:${polaNama.join('|')}|[a-zA-Z0-9_.-]+))';
    } else {
      pattern = r'(@[a-zA-Z0-9_.-]+)';
    }

    final regex = RegExp(pattern);
    final matches = regex.allMatches(teks);

    if (matches.isEmpty) {
      return Text(teks, style: defaultStyle);
    }

    final spans = <InlineSpan>[];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: teks.substring(start, match.start),
            style: defaultStyle,
          ),
        );
      }

      final mentionText = match.group(0)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
                width: 0.6,
              ),
            ),
            child: Text(
              mentionText,
              style: defaultMentionStyle,
            ),
          ),
        ),
      );

      start = match.end;
    }

    if (start < teks.length) {
      spans.add(
        TextSpan(
          text: teks.substring(start),
          style: defaultStyle,
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }
}
