import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/repositories/user_repository.dart';

// dialog pemulihan kata sandi
class DialogLupaPassword extends StatefulWidget {
  final String? emailAwal;

  const DialogLupaPassword({super.key, this.emailAwal});

  static Future<bool?> show(BuildContext context, {String? emailAwal}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => DialogLupaPassword(emailAwal: emailAwal),
    );
  }

  @override
  State<DialogLupaPassword> createState() => _DialogLupaPasswordState();
}

class _DialogLupaPasswordState extends State<DialogLupaPassword> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _pesanGalat;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.emailAwal ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _pesanGalat = null;
    });

    final res = await _userRepository.kirimResetPassword(_controller.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.sukses) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.pesan),
          duration: const Duration(milliseconds: 3500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() {
        _pesanGalat = res.pesan;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lupa Password',
                            style: AppTypography.headingSmall(),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pemulihan Kata Sandi',
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Masukkan email atau username akun Anda. Tautan untuk mengatur ulang kata sandi akan dikirimkan ke email terdaftar.',
                  style: AppTypography.bodySmall(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),

                AppTextField(
                  controller: _controller,
                  labelText: 'Email atau Username',
                  hintText: 'Contoh: nama@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email atau username tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                if (_pesanGalat != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pesanGalat!,
                            style: AppTypography.caption(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: AppTypography.labelBold(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: _isLoading ? 'Mengirim...' : 'Kirim Tautan',
                        borderRadius: 10,
                        onPressed: _isLoading ? null : _kirim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
