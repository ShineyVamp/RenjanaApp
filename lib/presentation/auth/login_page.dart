import 'package:flutter/material.dart';
import 'package:renjana/services/preference_handler.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/extensions/navigation.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../data/repositories/user_repository.dart';
import '../main/main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _userRepository.loginUser(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      await PreferenceHandler.saveUser(user);
      if (!mounted) return;
      context.pushAndRemoveAll(MainPage(currentUser: user));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau password tidak ditemukan'),
          backgroundColor: AppColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Selamat\ndatang\nkembali',
                  style: AppTypography.headingLarge(),
                ),
                const SizedBox(height: 8),
                Container(width: 100, height: 2, color: AppColors.primary),
                const SizedBox(height: 36),

                // input email
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Masukkan Email Anda',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // input password
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan Password Anda',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // tombol masuk
                AppButton(
                  text: _isLoading ? 'Memuat...' : 'Login',
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 24),

                // tautan ke halaman daftar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum Punya Akun? ',
                      style: AppTypography.bodyMedium(),
                    ),
                    GestureDetector(
                      onTap: () => context.push(const RegisterPage()),
                      child: Text(
                        'Buat Akun',
                        style: AppTypography.labelBold(
                          color: AppColors.primary,
                        ),
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
