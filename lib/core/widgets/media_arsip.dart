import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import 'app_image.dart';

// Helper untuk mengekstrak Video ID dari berbagai format URL YouTube
String? ekstrakYoutubeId(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final bersih = url.trim();

  // Pola 1: youtu.be/ID
  final regexPendek = RegExp(r'youtu\.be\/([a-zA-Z0-9_\-]+)');
  final matchPendek = regexPendek.firstMatch(bersih);
  if (matchPendek != null && matchPendek.groupCount >= 1) {
    return matchPendek.group(1);
  }

  // Pola 2: youtube.com/watch?v=ID atau youtube.com/embed/ID atau /shorts/ID
  final regexPanjang = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=|shorts\/))([a-zA-Z0-9_\-]+)',
  );
  final matchPanjang = regexPanjang.firstMatch(bersih);
  if (matchPanjang != null && matchPanjang.groupCount >= 1) {
    return matchPanjang.group(1);
  }

  // Bila input adalah ID langsung (panjang ~11 karakter tanpa garis miring)
  if (!bersih.contains('/') && bersih.length == 11) {
    return bersih;
  }

  return null;
}

// Widget tampilan media arsip (mendukung Foto, Video Berkas, dan Video YouTube).
// Gambar cover/thumbnail selalu tampil di latar belakang dengan indikator pemutaran
// saat arsip memiliki video atau tautan YouTube.
class MediaArsipView extends StatefulWidget {
  final String gambarUtama;
  final String jenisMedia; // 'gambar' | 'video' | 'youtube'
  final String? mediaUrl;
  final String judul;
  final double aspectRatio;
  final BoxFit fit;

  const MediaArsipView({
    super.key,
    required this.gambarUtama,
    this.jenisMedia = 'gambar',
    this.mediaUrl,
    this.judul = '',
    this.aspectRatio = 1.0,
    this.fit = BoxFit.cover,
  });

  @override
  State<MediaArsipView> createState() => _MediaArsipViewState();
}

class _MediaArsipViewState extends State<MediaArsipView> {
  bool get _hasVideo =>
      (widget.jenisMedia == 'video' || widget.jenisMedia == 'youtube') &&
      widget.mediaUrl != null &&
      widget.mediaUrl!.trim().isNotEmpty;

  Future<void> _putarMedia() async {
    final url = widget.mediaUrl?.trim();
    if (url == null || url.isEmpty) return;

    if (widget.jenisMedia == 'youtube') {
      final id = ekstrakYoutubeId(url);
      final targetUrl = id != null
          ? 'https://www.youtube.com/watch?v=$id'
          : (url.startsWith('http') ? url : 'https://$url');

      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan YouTube'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else if (widget.jenisMedia == 'video') {
      final uri = Uri.tryParse(url);
      if (uri != null && (url.startsWith('http://') || url.startsWith('https://'))) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Memutar video: ${widget.judul}'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gambar utama / cover thumbnail
          Positioned.fill(
            child: AppImageView(
              imagePath: widget.gambarUtama,
              fit: widget.fit,
            ),
          ),

          // Lapisan tombol putar dan penanda jenis media
          if (_hasVideo) ...[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(70),
                ),
              ),
            ),
            GestureDetector(
              onTap: _putarMedia,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(220),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.jenisMedia == 'youtube'
                          ? Icons.play_circle_fill_rounded
                          : Icons.videocam_rounded,
                      size: 14,
                      color: widget.jenisMedia == 'youtube'
                          ? Colors.redAccent
                          : AppColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.jenisMedia == 'youtube'
                          ? 'Tonton di YouTube'
                          : 'Putar Video Arsip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
