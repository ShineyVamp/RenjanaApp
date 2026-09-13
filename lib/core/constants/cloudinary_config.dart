import 'cloudinary_keys.dart';

class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = CloudinaryKeys.cloudName;
  static const String uploadPreset = CloudinaryKeys.uploadPreset;
  static const String defaultFolder = CloudinaryKeys.defaultFolder;

  static String get uploadUrl => CloudinaryKeys.baseUrl;
  static String get destroyUrl => CloudinaryKeys.destroyUrl;

  static String get apiKey => CloudinaryKeys.apiKey;
  static String get apiSecret => CloudinaryKeys.apiSecret;

  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset.isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';

  // section validasi kemampuan hapus
  static bool get canDestroy =>
      isConfigured &&
      apiKey.trim().isNotEmpty &&
      apiSecret.trim().isNotEmpty;
}
