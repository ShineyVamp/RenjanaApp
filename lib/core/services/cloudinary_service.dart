import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../constants/cloudinary_config.dart';

// hasil upload
class CloudinaryUploadResult {
  final bool isSuccess;
  final String? secureUrl;
  final String? publicId;
  final String? errorMessage;

  const CloudinaryUploadResult.success({
    required this.secureUrl,
    this.publicId,
  })  : isSuccess = true,
        errorMessage = null;

  const CloudinaryUploadResult.failure(this.errorMessage)
      : isSuccess = false,
        secureUrl = null,
        publicId = null;
}

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // inisialisasi
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // optimasi url pengiriman
  String _optimalkanUrl(String url) {
    if (url.contains('/image/upload/') && !url.contains('/f_auto,q_auto/')) {
      return url.replaceFirst('/image/upload/', '/image/upload/f_auto,q_auto/');
    }
    return url;
  }

  // unggah path berkas
  Future<String?> uploadFilePath(String? path, {String? subFolder}) async {
    if (path == null || path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) {
      return await uploadAsset(path, subFolder: subFolder);
    }
    final file = File(path);
    if (!file.existsSync()) return path;
    final res = await uploadImage(file, subFolder: subFolder);
    return res.isSuccess && res.secureUrl != null ? res.secureUrl! : path;
  }

  // unggah berkas asset
  Future<String> uploadAsset(String assetPath, {String? subFolder}) async {
    if (!assetPath.startsWith('assets/')) return assetPath;
    try {
      List<int>? bytes;
      try {
        final byteData = await rootBundle.load(assetPath);
        bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
      } catch (_) {
        final file = File(assetPath);
        if (file.existsSync()) {
          bytes = await file.readAsBytes();
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        final fileName = assetPath.split('/').last;
        final res = await uploadBytes(bytes, fileName, subFolder: subFolder);
        if (res.isSuccess && res.secureUrl != null) {
          return res.secureUrl!;
        }
      }
    } catch (_) {}
    return assetPath;
  }

  // unggah byte data
  Future<CloudinaryUploadResult> uploadBytes(
    List<int> bytes,
    String fileName, {
    String? subFolder,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      return const CloudinaryUploadResult.failure(
        'Cloudinary belum dikonfigurasi.',
      );
    }

    try {
      final targetFolder = subFolder != null
          ? '${CloudinaryConfig.defaultFolder}/$subFolder'
          : CloudinaryConfig.defaultFolder;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': targetFolder,
      });

      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawUrl = response.data['secure_url'] as String?;
        final publicId = response.data['public_id'] as String?;
        if (rawUrl != null && rawUrl.isNotEmpty) {
          final secureUrl = _optimalkanUrl(rawUrl);
          return CloudinaryUploadResult.success(
            secureUrl: secureUrl,
            publicId: publicId,
          );
        }
      }
      return const CloudinaryUploadResult.failure(
        'Respon tidak valid dari Cloudinary.',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['error']?['message'] ??
          e.message ??
          'Gagal mengunggah gambar.';
      return CloudinaryUploadResult.failure(message.toString());
    } catch (e) {
      return CloudinaryUploadResult.failure(e.toString());
    }
  }

  // unggah gambar
  Future<CloudinaryUploadResult> uploadImage(
    File file, {
    String? subFolder,
  }) async {
    if (!CloudinaryConfig.isConfigured) {
      return const CloudinaryUploadResult.failure(
        'Cloudinary belum dikonfigurasi.',
      );
    }

    if (!file.existsSync()) {
      return const CloudinaryUploadResult.failure(
        'Berkas gambar tidak ditemukan di perangkat.',
      );
    }

    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final targetFolder = subFolder != null
          ? '${CloudinaryConfig.defaultFolder}/$subFolder'
          : CloudinaryConfig.defaultFolder;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'folder': targetFolder,
      });

      final response = await _dio.post(
        CloudinaryConfig.uploadUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawUrl = response.data['secure_url'] as String?;
        final publicId = response.data['public_id'] as String?;

        if (rawUrl != null && rawUrl.isNotEmpty) {
          final secureUrl = _optimalkanUrl(rawUrl);
          return CloudinaryUploadResult.success(
            secureUrl: secureUrl,
            publicId: publicId,
          );
        }
      }

      return CloudinaryUploadResult.failure(
        'Respon tidak valid dari Cloudinary.',
      );
    } on DioException catch (e) {
      final message = e.response?.data?['error']?['message'] ??
          e.message ??
          'Gagal mengunggah gambar ke Cloudinary.';
      return CloudinaryUploadResult.failure(message.toString());
    } catch (e) {
      return CloudinaryUploadResult.failure(e.toString());
    }
  }

  // section ekstraksi public id
  static String? extractPublicId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    if (!url.contains('cloudinary.com') || !url.contains('/upload/')) return null;

    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex >= segments.length - 1) return null;

      final relevantSegments = <String>[];
      for (var i = uploadIndex + 1; i < segments.length; i++) {
        final seg = segments[i];
        if (RegExp(r'^v\d+$').hasMatch(seg)) continue;
        if (seg.contains(',') || seg.contains('_auto')) continue;
        relevantSegments.add(seg);
      }

      if (relevantSegments.isEmpty) return null;

      final last = relevantSegments.last;
      final dotIndex = last.lastIndexOf('.');
      if (dotIndex != -1) {
        relevantSegments[relevantSegments.length - 1] = last.substring(0, dotIndex);
      }

      return relevantSegments.join('/');
    } catch (_) {
      return null;
    }
  }

  // section algoritma sha1 murni
  String _sha1Hex(String input) {
    final bytes = utf8.encode(input);
    final bitLength = bytes.length * 8;
    final paddedLength = ((bytes.length + 8) ~/ 64 + 1) * 64;
    final padded = Uint8List(paddedLength);
    padded.setRange(0, bytes.length, bytes);
    padded[bytes.length] = 0x80;
    for (var i = 0; i < 8; i++) {
      padded[paddedLength - 1 - i] = (bitLength >> (i * 8)) & 0xFF;
    }

    var h0 = 0x67452301;
    var h1 = 0xEFCDAB89;
    var h2 = 0x98BADCFE;
    var h3 = 0x10325476;
    var h4 = 0xC3D2E1F0;

    final w = Uint32List(80);
    final byteData = ByteData.sublistView(padded);

    for (var chunk = 0; chunk < paddedLength; chunk += 64) {
      for (var t = 0; t < 16; t++) {
        w[t] = byteData.getUint32(chunk + t * 4, Endian.big);
      }
      for (var t = 16; t < 80; t++) {
        final val = w[t - 3] ^ w[t - 8] ^ w[t - 14] ^ w[t - 16];
        w[t] = ((val << 1) | (val >>> 31)) & 0xFFFFFFFF;
      }

      var a = h0;
      var b = h1;
      var c = h2;
      var d = h3;
      var e = h4;

      for (var t = 0; t < 80; t++) {
        int f;
        int k;
        if (t < 20) {
          f = (b & c) | ((~b) & d);
          k = 0x5A827999;
        } else if (t < 40) {
          f = b ^ c ^ d;
          k = 0x6ED9EBA1;
        } else if (t < 60) {
          f = (b & c) | (b & d) | (c & d);
          k = 0x8F1BBCDC;
        } else {
          f = b ^ c ^ d;
          k = 0xCA62C1D6;
        }

        final temp = (((a << 5) | (a >>> 27)) + f + e + k + w[t]) & 0xFFFFFFFF;
        e = d;
        d = c;
        c = ((b << 30) | (b >>> 2)) & 0xFFFFFFFF;
        b = a;
        a = temp;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
    }

    return [h0, h1, h2, h3, h4]
        .map((val) => val.toRadixString(16).padLeft(8, '0'))
        .join();
  }

  // section hapus gambar dari cloudinary
  Future<bool> deleteImageByUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) return false;
    final publicId = extractPublicId(imageUrl);
    if (publicId == null || publicId.isEmpty) return false;

    if (!CloudinaryConfig.canDestroy) {
      debugPrint('[Cloudinary] Penghapusan gambar "$publicId" dilewati karena apiKey/apiSecret belum dikonfigurasi.');
      return false;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final toSign = 'public_id=$publicId&timestamp=$timestamp${CloudinaryConfig.apiSecret}';
      final signature = _sha1Hex(toSign);

      final formData = FormData.fromMap({
        'public_id': publicId,
        'api_key': CloudinaryConfig.apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      final response = await _dio.post(
        CloudinaryConfig.destroyUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        final resResult = response.data?['result'];
        if (resResult == 'ok') {
          debugPrint('[Cloudinary] Berhasil menghapus gambar: $publicId');
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('[Cloudinary] Gagal menghapus gambar $publicId: $e');
      return false;
    }
  }

  // section hapus banyak gambar
  Future<void> deleteImagesByUrls(List<String?> imageUrls) async {
    final urls = imageUrls
        .whereType<String>()
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty && u.contains('cloudinary.com'))
        .toSet()
        .toList();

    for (final url in urls) {
      await deleteImageByUrl(url);
    }
  }
}
