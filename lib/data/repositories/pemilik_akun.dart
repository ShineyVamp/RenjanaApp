import '../../services/preference_handler.dart';

// Kunci pemilik untuk seluruh data per akun di database.
//
// Dulu memakai email, sehingga mengganti email akan memutus bookmark, riwayat,
// lencana, hasil kuis, dan progres wilayah dari pemiliknya. Sekarang memakai id
// baris pada tabel `user`, yang tidak pernah berubah.
//
// Nilai 0 berarti tidak ada sesi; repository memperlakukannya sebagai kosong.
int get idAkunAktif {
  try {
    return PreferenceHandler.userId;
  } catch (_) {
    return 0;
  }
}
