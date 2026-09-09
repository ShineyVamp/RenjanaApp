import 'preference_handler.dart';

// Nilai 0 berarti tidak ada sesi; repository memperlakukannya sebagai kosong.
int get idAkunAktif {
  try {
    return PreferenceHandler.userId;
  } catch (_) {
    return 0;
  }
}
