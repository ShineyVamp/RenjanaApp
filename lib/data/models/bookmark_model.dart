import 'budaya_model.dart';
import 'sejarah_model.dart';

class BookmarkItemModel {
  final int? id;
  final String itemType; // 'sejarah' | 'budaya'
  final String kodeTag;
  final String createdAt;
  final SejarahModel? sejarah;
  final BudayaModel? budaya;

  BookmarkItemModel({
    this.id,
    required this.itemType,
    required this.kodeTag,
    required this.createdAt,
    this.sejarah,
    this.budaya,
  });

  String get title =>
      itemType == 'sejarah' ? (sejarah?.judul ?? '') : (budaya?.judul ?? '');

  String get subtitle => itemType == 'sejarah'
      ? (sejarah?.subtitle ?? '')
      : (budaya?.kategoriLabel ?? '');

  String get description => itemType == 'sejarah'
      ? (sejarah?.ringkasan ?? '')
      : (budaya?.tagline.isNotEmpty == true
          ? budaya!.tagline
          : (budaya?.deskripsi ?? ''));

  String get imagePath => itemType == 'sejarah'
      ? (sejarah?.gambarUtama ?? 'assets/images/170845history.png')
      : (budaya?.gambarUtama ?? 'assets/images/borobudurB.jpg');

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
  }) {
    return BookmarkItemModel(
      id: map['id'] as int?,
      itemType: map['itemType'] as String? ?? 'sejarah',
      kodeTag: map['kodeTag'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      sejarah: sejarah,
      budaya: budaya,
    );
  }
}
