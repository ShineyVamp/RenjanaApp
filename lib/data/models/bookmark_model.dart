import '../../core/constants/wilayah_nusantara.dart';
import 'budaya_model.dart';
import 'sejarah_model.dart';

class BookmarkItemModel {
  final int? id;

  // 'sejarah' | 'budaya' | 'pulau' | 'provinsi'
  final String itemType;

  final String kodeTag;
  final String createdAt;
  final SejarahModel? sejarah;
  final BudayaModel? budaya;
  final GugusPulau? pulau;
  final Provinsi? wilayah;

  BookmarkItemModel({
    this.id,
    required this.itemType,
    required this.kodeTag,
    required this.createdAt,
    this.sejarah,
    this.budaya,
    this.pulau,
    this.wilayah,
  });

  // Kunci bookmark untuk wilayah diberi awalan sendiri supaya tidak
  // bertabrakan dengan ID tag arsip yang berbentuk HIS-… atau BUD-….
  static const String awalanPulau = 'PLU-';
  static const String awalanProvinsi = 'PRV-';

  static String kunciPulau(String id) => '$awalanPulau$id';
  static String kunciProvinsi(String nama) => '$awalanProvinsi$nama';

  bool get isWilayah => itemType == 'pulau' || itemType == 'provinsi';

  String get title {
    switch (itemType) {
      case 'sejarah':
        return sejarah?.judul ?? '';
      case 'budaya':
        return budaya?.judul ?? '';
      case 'pulau':
        return pulau?.nama ?? '';
      case 'provinsi':
        return wilayah?.nama ?? '';
      default:
        return '';
    }
  }

  String get subtitle {
    switch (itemType) {
      case 'sejarah':
        return sejarah?.subtitle ?? '';
      case 'budaya':
        return budaya?.kategoriLabel ?? '';
      case 'pulau':
        return '${pulau?.provinsi.length ?? 0} provinsi';
      case 'provinsi':
        return wilayah?.julukan.isNotEmpty == true
            ? wilayah!.julukan
            : (wilayah?.ibukota ?? '');
      default:
        return '';
    }
  }

  String get description {
    switch (itemType) {
      case 'sejarah':
        return sejarah?.ringkasan ?? '';
      case 'budaya':
        return budaya?.tagline.isNotEmpty == true
            ? budaya!.tagline
            : (budaya?.deskripsi ?? '');
      case 'pulau':
        return pulau?.deskripsi ?? '';
      case 'provinsi':
        return wilayah?.deskripsi ?? '';
      default:
        return '';
    }
  }

  String get imagePath {
    switch (itemType) {
      case 'sejarah':
        return sejarah?.gambarUtama ?? 'assets/images/170845history.png';
      case 'budaya':
        return budaya?.gambarUtama ?? 'assets/images/borobudurB.jpg';
      case 'pulau':
        return pulau?.gambar ?? 'assets/images/onboardin1.jpg';
      case 'provinsi':
        return wilayah == null
            ? 'assets/images/onboardin1.jpg'
            : gambarProvinsi(wilayah!);
      default:
        return 'assets/images/onboardin1.jpg';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemType': itemType,
      'kodeTag': kodeTag,
      'createdAt': createdAt,
    };
  }

  factory BookmarkItemModel.fromMap(
    Map<String, dynamic> map, {
    SejarahModel? sejarah,
    BudayaModel? budaya,
    GugusPulau? pulau,
    Provinsi? wilayah,
  }) {
    return BookmarkItemModel(
      id: map['id'] as int?,
      itemType: map['itemType'] as String? ?? 'sejarah',
      kodeTag: map['kodeTag'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      sejarah: sejarah,
      budaya: budaya,
      pulau: pulau,
      wilayah: wilayah,
    );
  }
}
