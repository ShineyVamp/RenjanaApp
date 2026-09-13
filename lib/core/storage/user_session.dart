import 'preference_handler.dart';

// id sesi akun aktif
int get idAkunAktif {
  try {
    return PreferenceHandler.userId;
  } catch (_) {
    return 0;
  }
}
