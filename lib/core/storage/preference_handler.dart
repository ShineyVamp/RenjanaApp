import 'package:shared_preferences/shared_preferences.dart';
import 'package:renjana/features/auth/data/models/user_model.dart';

class PreferenceHandler {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const _keyIsLogin = "isLogin";
  static const _keyUserData = "userData";
  static const _keyIsAdmin = "isAdmin";
  static const _keyUserName = "userName";
  static const _keyUserUsername = "userUsername";
  static const _keyUserEmail = "userEmail";
  static const _keyUserId = "userId";

  static Future<void> saveUser(UserSQLModel user) async {
    await _prefs.setBool(_keyIsLogin, true);
    // password tidak ikut disimpan
    await _prefs.setString(_keyUserData, user.sanitized().toJson());

    await _prefs.setBool(_keyIsAdmin, user.isAdminAccount);
    await _prefs.setString(_keyUserName, user.nama);
    await _prefs.setString(_keyUserUsername, user.username);
    await _prefs.setString(_keyUserEmail, user.email);
    await _prefs.setInt(_keyUserId, user.id ?? 0);
  }

  static bool get isLogin {
    return _prefs.getBool(_keyIsLogin) ?? false;
  }

  // cek admin
  static bool get isAdmin {
    return (_prefs.getBool(_keyIsAdmin) ?? false) || (user?.isAdmin ?? false);
  }

  static String get userName {
    final name = _prefs.getString(_keyUserName);
    if (name != null && name.trim().isNotEmpty) {
      return name;
    }
    return isAdmin ? 'admin1' : 'Agus';
  }

  static String get userUsername {
    final u = _prefs.getString(_keyUserUsername);
    if (u != null && u.trim().isNotEmpty) {
      return u;
    }
    if (user != null && user!.username.isNotEmpty) {
      return user!.username;
    }
    return userName.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  static String get userEmail {
    return _prefs.getString(_keyUserEmail) ?? '';
  }

  // Pemilik seluruh data per akun. Dipakai sebagai kunci di database supaya
  // penggantian username maupun email tidak memutus capaian.
  static int get userId {
    final tersimpan = _prefs.getInt(_keyUserId) ?? 0;
    if (tersimpan > 0) return tersimpan;
    return user?.id ?? 0;
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

  // Hanya kunci sesi yang dihapus, preferensi lain tetap bertahan.
  static Future<void> logOut() async {
    await _prefs.remove(_keyIsLogin);
    await _prefs.remove(_keyUserData);
    await _prefs.remove(_keyIsAdmin);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserId);
  }
}
