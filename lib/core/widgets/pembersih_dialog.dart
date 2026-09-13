import 'package:flutter/material.dart';

// section pembungkus pembersih dialog
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

// section pembuangan controller
void buangController(List<TextEditingController> controller) {
  for (final c in controller) {
    c.dispose();
  }
}
