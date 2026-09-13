import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/presentation/widgets/dialog_lupa_password.dart';

// bottom sheet ganti kata sandi
class BottomSheetGantiPassword extends StatefulWidget {
  final String? emailPengguna;

  const BottomSheetGantiPassword({super.key, this.emailPengguna});

  static Future<bool?> show(BuildContext context, {String? emailPengguna}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetGantiPassword(emailPengguna: emailPengguna),
    );
  }

  @override
  State<BottomSheetGantiPassword> createState() =>
      _BottomSheetGantiPasswordState();
}

class _BottomSheetGantiPasswordState extends State<BottomSheetGantiPassword> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _lamaController = TextEditingController();
  final TextEditingController _baruController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();

  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false;
  String? _pesanGalat;

  @override
  void dispose() {
    _lamaController.dispose();
    _baruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _pesanGalat = null;
    });

    final res = await _userRepository.gantiPassword(
      passwordLama: _lamaController.text,
      passwordBaru: _baruController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.sukses) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.pesan),
          duration: const Duration(milliseconds: 2000),
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // penanda tarik
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.borderPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // judul
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ganti Password',
                          style: AppTypography.headingSmall(),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Masukkan password lama untuk verifikasi',
                          style: AppTypography.caption(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // password lama
              AppTextField(
                controller: _lamaController,
                labelText: 'Password Lama',
                hintText: 'Masukkan password Anda saat ini',
                obscureText: _obscureLama,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureLama ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureLama = !_obscureLama),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Password lama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 6),

              // opsi lupa password lama
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    DialogLupaPassword.show(
                      context,
                      emailAwal: widget.emailPengguna,
                    );
                  },
                  child: Text(
                    'Lupa password lama?',
                    style: AppTypography.labelBold(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // password baru
              AppTextField(
                controller: _baruController,
                labelText: 'Password Baru',
                hintText: 'Minimal 8 karakter',
                obscureText: _obscureBaru,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureBaru ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscureBaru = !_obscureBaru),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Password baru tidak boleh kosong';
                  }
                  if (val.length < 8) {
                    return 'Password minimal 8 karakter';
                  }
                  if (_lamaController.text.isNotEmpty &&
                      val.trim() == _lamaController.text.trim()) {
                    return 'Password baru harus berbeda dari password lama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // konfirmasi password baru
              AppTextField(
                controller: _konfirmasiController,
                labelText: 'Konfirmasi Password Baru',
                hintText: 'Ulangi password baru Anda',
                obscureText: _obscureKonfirmasi,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKonfirmasi
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(
                    () => _obscureKonfirmasi = !_obscureKonfirmasi,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  }
                  if (val != _baruController.text) {
                    return 'Konfirmasi password tidak cocok';
                  }
                  return null;
                },
              ),

              if (_pesanGalat != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 10),
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

              const SizedBox(height: 26),

              // tombol simpan
              AppButton(
                text: _isLoading ? 'Menyimpan...' : 'Simpan Password Baru',
                borderRadius: 10,
                onPressed: _isLoading ? null : _simpan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
