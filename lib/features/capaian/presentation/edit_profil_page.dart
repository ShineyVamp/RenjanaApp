import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/extensions/navigation.dart';
import '../../../core/storage/preference_handler.dart';
import '../../../core/utils/image_picker_helper.dart';
import '../../../core/widgets/app_bar_halaman.dart';
import '../../../core/widgets/app_image.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/repositories/user_repository.dart';

// Penyuntingan data diri. Username dan email boleh diganti karena seluruh
// data akun disimpan dengan kunci id, bukan email.
class EditProfilPage extends StatefulWidget {
  final UserSQLModel user;

  const EditProfilPage({super.key, required this.user});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final UserRepository _userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _email;
  late final TextEditingController _noHp;

  String? _foto;
  bool _hapusFoto = false;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.user.nama);
    _email = TextEditingController(text: widget.user.email);
    _noHp = TextEditingController(text: widget.user.noHp);
    _foto = widget.user.fotoProfil;
  }

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _noHp.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final path = await pilihGambarDariGaleri(context);
    if (path == null || !mounted) return;
    setState(() {
      _foto = path;
      _hapusFoto = false;
    });
  }

  void _lepasFoto() {
    setState(() {
      _foto = null;
      _hapusFoto = true;
    });
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);
    final hasil = await _userRepository.perbaruiProfil(
      id: widget.user.id ?? PreferenceHandler.userId,
      nama: _nama.text,
      email: _email.text,
      noHp: _noHp.text,
      fotoProfil: _foto,
      hapusFoto: _hapusFoto,
    );
    if (!mounted) return;
    setState(() => _menyimpan = false);

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (!hasil.sukses) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(hasil.galat ?? 'Gagal menyimpan perubahan.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Sesi ikut diperbarui agar nama dan email baru langsung terpakai.
    await PreferenceHandler.saveUser(hasil.user!);
    if (!mounted) return;

    context.pop(true);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Profil diperbarui'),
        duration: Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarHalaman(judul: 'Edit Profil'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
              children: [
                _buildFoto(),
                const SizedBox(height: 28),

                _buildIsian(
                  label: 'Username',
                  controller: _nama,
                  petunjuk: 'Dipakai sebagai nama tampilan, harus unik',
                  validator: (nilai) {
                    final teks = (nilai ?? '').trim();
                    if (teks.isEmpty) return 'Username tidak boleh kosong';
                    if (teks.length < 3) return 'Minimal 3 karakter';
                    return null;
                  },
                ),
                _buildIsian(
                  label: 'Email',
                  controller: _email,
                  petunjuk: 'Dipakai untuk masuk ke akun',
                  keyboard: TextInputType.emailAddress,
                  validator: (nilai) {
                    final teks = (nilai ?? '').trim();
                    if (teks.isEmpty) return 'Email tidak boleh kosong';
                    if (!teks.contains('@') || !teks.contains('.')) {
                      return 'Format email belum benar';
                    }
                    return null;
                  },
                ),
                _buildIsian(
                  label: 'Nomor HP',
                  controller: _noHp,
                  petunjuk: 'Boleh dikosongkan',
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: _menyimpan ? null : _simpan,
                    child: Text(
                      _menyimpan ? 'Menyimpan…' : 'Simpan Perubahan',
                      style: AppTypography.buttonText().copyWith(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoto() {
    final nama = _nama.text.trim();
    final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();
    final adaFoto = (_foto ?? '').trim().isNotEmpty;

    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: AppColors.primary,
            border: Border.all(color: AppColors.primaryDark, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: adaFoto
              ? AppImageView(imagePath: _foto!, fit: BoxFit.cover)
              : Center(
                  child: Text(
                    inisial,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 48,
                      height: 1,
                      color: AppColors.background,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pilihFoto,
              icon: const Icon(
                Icons.photo_library_outlined,
                size: 17,
                color: AppColors.primary,
              ),
              label: Text(
                adaFoto ? 'Ganti foto' : 'Pilih foto',
                style: AppTypography.labelBold(fontSize: 12.5),
              ),
            ),
            if (adaFoto)
              TextButton.icon(
                onPressed: _lepasFoto,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 17,
                  color: AppColors.error,
                ),
                label: Text(
                  'Hapus',
                  style: AppTypography.labelBold(
                    fontSize: 12.5,
                  ).copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildIsian({
    required String label,
    required TextEditingController controller,
    required String petunjuk,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.eyebrow()),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            validator: validator,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              helperText: petunjuk,
              helperStyle: AppTypography.bodySmall().copyWith(fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
