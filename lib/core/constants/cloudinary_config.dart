class CloudinaryConfig {
  CloudinaryConfig._();
  static const String cloudName = 'yykabu7v';
  static const String uploadPreset = 'renjana_preset';
  static const String defaultFolder = 'renjana';
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset.isNotEmpty &&
      uploadPreset != 'YOUR_UPLOAD_PRESET';
}
