import '../../features/bookmark/data/repositories/bookmark_repository.dart';
import '../../features/capaian/data/repositories/arsip_dibaca_repository.dart';
import '../../features/capaian/data/repositories/lencana_repository.dart';
import '../../features/capaian/data/repositories/riwayat_repository.dart';
import '../../features/capaian/data/repositories/runtun_repository.dart';
import '../../features/capaian/presentation/profile_page.dart';
import '../../features/jelajah/data/repositories/jelajah_repository.dart';
import '../../features/komunitas/data/repositories/komunitas_repository.dart';
import '../../features/kontribusi/data/repositories/usulan_repository.dart';
import '../../features/wilayah/data/repositories/progres_wilayah_repository.dart';

class SessionCleanupService {
  static void bersihkanSemuaCachePengguna() {
    try {
      RiwayatRepository.bersihkanCache();
    } catch (_) {}

    try {
      LencanaRepository.bersihkanCache();
    } catch (_) {}

    try {
      ArsipDibacaRepository.bersihkanCache();
    } catch (_) {}

    try {
      RuntunRepository.bersihkanCache();
    } catch (_) {}

    try {
      BookmarkRepository.bersihkanCache();
    } catch (_) {}

    try {
      ProgresWilayahRepository.bersihkanCache();
    } catch (_) {}

    try {
      KomunitasRepository.bersihkanCache();
    } catch (_) {}

    try {
      UsulanRepository.bersihkanCache();
    } catch (_) {}

    try {
      ProfilePage.bersihkanCache();
    } catch (_) {}

    try {
      JelajahRepository.bersihkanCache();
    } catch (_) {}
  }
}
