import 'dart:io';
import 'package:dio/dio.dart';
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
}
