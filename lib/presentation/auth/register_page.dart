import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _hasMinLength = false;
  bool _hasComplexChars = false;
  bool _hasText = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _hasText = value.isNotEmpty;
      _hasMinLength = value.length >= 8;
      _hasComplexChars =
          value.contains(RegExp(r'[A-Z]')) &&
          value.contains(RegExp(r'[a-z]')) &&
          value.contains(RegExp(r'[0-9]'));
    });
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();

    // Username dan email harus belum dipakai akun lain.
    final namaDipakai = await _userRepository.usernameDipakai(nama);
    final emailDipakai = await _userRepository.emailDipakai(email);
    if (!mounted) return;

    if (namaDipakai || emailDipakai) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            namaDipakai
                ? 'Username "$nama" sudah dipakai. Pilih yang lain.'
                : 'Email tersebut sudah terdaftar.',
          ),
          backgroundColor: AppColors.primaryDark,
        ),
      );
      return;
    }

    final user = UserSQLModel(
      nama: nama,
      email: email,
      noHp: _noHpController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final success = await _userRepository.userRegister(user);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pushReplacement(const LoginPage());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau email sudah dipakai akun lain.'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  Widget _buildPasswordRule(String text, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isSatisfied ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: isSatisfied ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTypography.bodySmall(
              color: isSatisfied
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text('Daftar Akun', style: AppTypography.headingMedium()),
                      const SizedBox(height: 6),
                      Container(width: 80, height: 2, color: AppColors.primary),
                      const SizedBox(height: 10),
                      Text(
                        'Lengkapi data di bawah ini\nuntuk mulai menjelajah nusantara.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // input username
                AppTextField(
                  controller: _namaController,
                  labelText: 'Username',
                  hintText: 'Nama tampilan Anda, harus unik',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // input email
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan Email Anda',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!val.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // input no hp
                AppTextField(
                  controller: _noHpController,
                  labelText: 'No. Handphone',
                  hintText: 'Masukkan Nomor Handphone',
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nomor handphone wajib diisi';
                    }
                    if (int.tryParse(val) == null) {
                      return 'Nomor handphone hanya boleh berisi angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // input password
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan Password',
                  obscureText: _obscurePassword,
                  onChanged: _onPasswordChanged,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    if (val.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // indikator syarat password
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ketentuan Kata Sandi:',
                        style: AppTypography.labelBold(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      _buildPasswordRule('Minimal 8 Karakter', _hasMinLength),
                      _buildPasswordRule('Password terisi', _hasText),
                      _buildPasswordRule(
                        'Mengandung Huruf Besar, Kecil, dan Angka',
                        _hasComplexChars,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // input konfirmasi password
                AppTextField(
                  controller: _konfirmasiController,
                  labelText: 'Konfirmasi Password',
                  hintText: 'Ulangi Password Anda',
                  obscureText: _obscureKonfirmasi,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKonfirmasi
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscureKonfirmasi = !_obscureKonfirmasi);
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Konfirmasi password wajib diisi';
                    }
                    if (val != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // tombol daftar
                AppButton(
                  text: _isLoading ? 'Mendaftarkan...' : 'Daftar Sekarang',
                  onPressed: _isLoading ? null : _register,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
