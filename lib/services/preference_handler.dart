import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';

class PreferenceHandler {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyIsLogin = "isLogin";
  static const _keyUserData = "userData";
  static const _keyIsAdmin = "isAdmin";
  static const _keyUserName = "userName";
  static const _keyUserEmail = "userEmail";

  static Future<void> setLogin(bool isLogin) async {
    await _prefs.setBool(_keyIsLogin, isLogin);
  }

  static Future<void> saveUser(UserSQLModel user) async {
    await _prefs.setBool(_keyIsLogin, true);
    // Password tidak ikut disimpan di SharedPreferences.
    await _prefs.setString(_keyUserData, user.sanitized().toJson());

    await _prefs.setBool(_keyIsAdmin, user.isAdminAccount);
    await _prefs.setString(_keyUserName, user.nama);
    await _prefs.setString(_keyUserEmail, user.email);
  }

  static bool get isLogin {
    return _prefs.getBool(_keyIsLogin) ?? false;
  }

  static bool get isAdmin {
    return _prefs.getBool(_keyIsAdmin) ?? false;
  }

  static String get userName {
    final name = _prefs.getString(_keyUserName);
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    return isAdmin ? 'admin1' : 'Agus';
  }

  static String get userEmail {
    return _prefs.getString(_keyUserEmail) ?? '';
  }

  static UserSQLModel? get user {
    final raw = _prefs.getString(_keyUserData);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return UserSQLModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  /// Menghapus kunci sesi saja, bukan seluruh isi SharedPreferences,
  /// supaya preferensi non-auth (mis. pengaturan aplikasi) tetap bertahan.
  static Future<void> logOut() async {
    await _prefs.remove(_keyIsLogin);
    await _prefs.remove(_keyUserData);
    await _prefs.remove(_keyIsAdmin);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
  }
}
