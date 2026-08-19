import 'sejarah_model.dart';

class BudayaModel {
  final int? id;
  final String kodeTag; // Format: BUD-SNJT-1
  final String jenis; // SNJT (Senjata), TRN (Tarian), ADT (Adat/Arsitektur), dll.
  final int urutan; // 1, 2, dst.
  final String judul; // cth: 'Q-RIS', 'BOROBUDUR'
  final String kategoriLabel; // cth: 'SENJATA TRADISIONAL'
  final String tagline; // cth: 'Sebilah logam yang menyimpan wibawa...'
  final String deskripsi; // Wajib (untuk card home & deskripsi detail)
  final String gambarUtama; // Wajib (untuk card home & header detail)
  final String? maknaSpiritual; // Sub-bagian: Makna Spiritual
  final String? gambarMaknaSpiritual; // Gambar tambahan sub makna spiritual (opsional)
  final String? konteksBudaya; // Sub-bagian: Konteks Budaya & Sejarah
  final String? gambarKonteksBudaya; // Gambar tambahan sub konteks budaya (opsional)
  final List<RelatedItemModel> relatedItems;

  const BudayaModel({
    this.id,
    required this.kodeTag,
    required this.jenis,
    required this.urutan,
    required this.judul,
    required this.kategoriLabel,
    required this.tagline,
    required this.deskripsi,
    required this.gambarUtama,
    this.maknaSpiritual,
    this.gambarMaknaSpiritual,
    this.konteksBudaya,
    this.gambarKonteksBudaya,
    this.relatedItems = const [],
  });
}
