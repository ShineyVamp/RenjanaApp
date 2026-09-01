import 'dart:convert';
import 'sejarah_model.dart';
import '../../core/widgets/detail_spec_block.dart';

enum TipeBlokKonten {
  teksPanjang, // Paragraf / Deskripsi bebas
  daftar, // Daftar bernomor / list berurutan
  timeline, // Urutan waktu / alur peristiwa
  spesifikasi, // Data singkat / tabel spesifikasi (label & nilai)
}

extension RupaTipeBlokKonten on TipeBlokKonten {
  String get label {
    switch (this) {
      case TipeBlokKonten.teksPanjang:
        return 'Deskripsi / Paragraf';
      case TipeBlokKonten.daftar:
        return 'Daftar / Urutan Bernomor';
      case TipeBlokKonten.timeline:
        return 'Urutan Waktu (Timeline)';
      case TipeBlokKonten.spesifikasi:
        return 'Data Singkat / Spesifikasi';
    }
  }

  String get deskripsi {
    switch (this) {
      case TipeBlokKonten.teksPanjang:
        return 'Teks panjang atau penjelasan mendalam dalam format paragraf.';
      case TipeBlokKonten.daftar:
        return 'Daftar poin bernomor urut seperti langkah, bahan, tata cara, atau aturan.';
      case TipeBlokKonten.timeline:
        return 'Rangkaian kronologi peristiwa berdasarkan waktu, tanggal, dan deskripsi.';
      case TipeBlokKonten.spesifikasi:
        return 'Kumpulan informasi ringkas berupa pasangan label dan nilai.';
    }
  }
}

class BlokKontenModel {
  String id;
  TipeBlokKonten tipe;
  String judul;
  dynamic data; // String, List<String>, List<TimelineItemModel>, List<SpecItem>

  BlokKontenModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.data,
  });

  // Helper getters
  String get teks => data is String ? data as String : '';
  
  List<String> get daftar {
    if (data is List) {
      return (data as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (data is String && (data as String).trim().isNotEmpty) {
      return [(data as String).trim()];
    }
    return const [];
  }

  List<TimelineItemModel> get timeline {
    if (data is List<TimelineItemModel>) return data as List<TimelineItemModel>;
    if (data is List) {
      final list = <TimelineItemModel>[];
      for (final item in data as List) {
        if (item is TimelineItemModel) {
          list.add(item);
        } else if (item is Map<String, dynamic>) {
          list.add(TimelineItemModel.fromMap(item));
        } else if (item is Map) {
          list.add(TimelineItemModel.fromMap(Map<String, dynamic>.from(item)));
        }
      }
      return list;
    }
    return const [];
  }

  List<SpecItem> get spesifikasi {
    if (data is List<SpecItem>) return data as List<SpecItem>;
    if (data is List) {
      final list = <SpecItem>[];
      for (final item in data as List) {
        if (item is SpecItem) {
          list.add(item);
        } else if (item is Map) {
          final label = item['label']?.toString() ?? '';
          final nilai = item['nilai']?.toString() ?? '';
          if (label.isNotEmpty || nilai.isNotEmpty) {
            list.add(SpecItem(label, nilai));
          }
        }
      }
      return list;
    }
    return const [];
  }

  Map<String, dynamic> toMap() {
    dynamic rawData;
    switch (tipe) {
      case TipeBlokKonten.teksPanjang:
        rawData = teks;
        break;
      case TipeBlokKonten.daftar:
        rawData = daftar;
        break;
      case TipeBlokKonten.timeline:
        rawData = timeline.map((t) => t.toMap()).toList();
        break;
      case TipeBlokKonten.spesifikasi:
        rawData = spesifikasi.map((s) => {'label': s.label, 'nilai': s.nilai}).toList();
        break;
    }

    return {
      'id': id,
      'tipe': tipe.name,
      'judul': judul,
      'data': rawData,
    };
  }

  factory BlokKontenModel.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString();
    final tipeName = map['tipe']?.toString() ?? TipeBlokKonten.teksPanjang.name;
    final tipe = TipeBlokKonten.values.firstWhere(
      (t) => t.name == tipeName,
      orElse: () => TipeBlokKonten.teksPanjang,
    );
    final judul = map['judul']?.toString() ?? '';
    final rawData = map['data'];

    dynamic parsedData;
    switch (tipe) {
      case TipeBlokKonten.teksPanjang:
        parsedData = rawData?.toString() ?? '';
        break;
      case TipeBlokKonten.daftar:
        if (rawData is List) {
          parsedData = rawData.map((e) => e.toString()).toList();
        } else if (rawData is String && rawData.isNotEmpty) {
          parsedData = rawData.split('\n').where((s) => s.trim().isNotEmpty).toList();
        } else {
          parsedData = <String>[];
        }
        break;
      case TipeBlokKonten.timeline:
        if (rawData is List) {
          parsedData = rawData.map((item) {
            if (item is TimelineItemModel) return item;
            if (item is Map) return TimelineItemModel.fromMap(Map<String, dynamic>.from(item));
            return TimelineItemModel(date: '', title: item.toString(), desc: '');
          }).toList();
        } else {
          parsedData = <TimelineItemModel>[];
        }
        break;
      case TipeBlokKonten.spesifikasi:
        if (rawData is List) {
          parsedData = rawData.map((item) {
            if (item is SpecItem) return item;
            if (item is Map) {
              return SpecItem(
                item['label']?.toString() ?? '',
                item['nilai']?.toString() ?? '',
              );
            }
            return SpecItem('Info', item.toString());
          }).toList();
        } else {
          parsedData = <SpecItem>[];
        }
        break;
    }

    return BlokKontenModel(
      id: id,
      tipe: tipe,
      judul: judul,
      data: parsedData,
    );
  }

  static List<BlokKontenModel> listFromDynamic(dynamic mentah) {
    if (mentah == null) return [];
    if (mentah is List) {
      return mentah.map((item) {
        if (item is BlokKontenModel) return item;
        if (item is Map) return BlokKontenModel.fromMap(Map<String, dynamic>.from(item));
        return BlokKontenModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          tipe: TipeBlokKonten.teksPanjang,
          judul: 'Deskripsi',
          data: item.toString(),
        );
      }).toList();
    }
    if (mentah is String && mentah.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(mentah.trim());
        return listFromDynamic(decoded);
      } catch (_) {}
    }
    return [];
  }

  static List<Map<String, dynamic>> listToMapList(List<BlokKontenModel> list) {
    return list.map((b) => b.toMap()).toList();
  }

  static String listToJson(List<BlokKontenModel> list) {
    return jsonEncode(listToMapList(list));
  }
}
