import 'package:flutter/material.dart';

// Pembungkus isi dialog yang menjalankan [onTutup] saat dialog lepas dari
// widget tree, yaitu setelah animasi menutup selesai. Dipakai untuk membuang
// TextEditingController milik dialog.
class PembersihDialog extends StatefulWidget {
  final Widget child;
  final VoidCallback onTutup;

  const PembersihDialog({
    super.key,
    required this.child,
    required this.onTutup,
  });

  @override
  State<PembersihDialog> createState() => _PembersihDialogState();
}

class _PembersihDialogState extends State<PembersihDialog> {
  @override
  void dispose() {
    widget.onTutup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// Membuang sekumpulan controller sekaligus, dipasang di [onTutup].
void buangController(List<TextEditingController> controller) {
  for (final c in controller) {
    c.dispose();
  }
}
