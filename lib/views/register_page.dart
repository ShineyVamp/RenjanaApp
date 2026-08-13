import 'package:control_style/control_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/database/db_helper.dart';
import 'package:renjana/extensions/navigation.dart';
import 'package:renjana/models/user_model.dart';
import 'package:renjana/views/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController namaC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController noHpC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final TextEditingController konpassC = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool lihatPass = true;
  bool passB = false;
  bool passP = false;
  bool passCon = false;

  void register() async {
    final nama = namaC.text.trim();
    final email = emailC.text.trim();
    final noHp = noHpC.text.trim();
    final pass = passC.text.trim();

    final pengguna = UserSQLModel(
      nama: nama,
      email: email,
      noHp: noHp,
      password: pass,
    );

    bool success = await DbHelper().userRegister(pengguna);

    if (!mounted) return;

    if (success) {
      context.push(LoginPage());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register Berhasil Silahkan Login")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email Sudah Terdaftar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xffF4F0E7),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/Rlogos.png", width: 30),
            SizedBox(width: 10),
            Text("RENJANA", style: GoogleFonts.dmSerifDisplay(fontSize: 25)),
          ],
        ),
        backgroundColor: Color(0xffF4F0E7),
        leading: GestureDetector(
          onTap: () {
            context.pushAndRemoveAll(LoginPage());
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      backgroundColor: Color(0xffF4F0E7),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Register",
                    style: GoogleFonts.dmSerifDisplay(fontSize: 32),
                  ),
                  // SizedBox(height: 10),
                  SizedBox(
                    width: 100,
                    child: Divider(thickness: 2, color: Color(0xffC9362B)),
                  ),
                  Text(
                    "Lengkapi data dibawah ini \nuntuk mulai penjelajahan nusantara anda.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        " Nama",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      MasukkanPengguna(
                        namaC: namaC,
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Nama Wajib Diisi";
                          }
                          return null;
                        },
                        teksHint: 'Masukkan Nama Anda',
                        bintang: false,
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Email",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      MasukkanPengguna(
                        namaC: emailC,
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Email Wajib Diisi";
                          } else if (!p0.contains('@')) {
                            return "Email Tidak Valid";
                          }
                          return null;
                        },
                        teksHint: 'Masukkan Nama Anda',
                        bintang: false,
                      ),
                      SizedBox(height: 10),
                      Text(
                        " No Hp.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      MasukkanPengguna(
                        namaC: noHpC,
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Nomor Wajib Diisi";
                          } else if (int.tryParse(p0) == null) {
                            return "Nomor Wajib Angka";
                          }
                          return null;
                        },
                        teksHint: 'Masukkan Nomor Anda',
                        bintang: false,
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Password",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      MasukkanPengguna(
                        onChanged: (p0) {
                          setState(() {});
                          passP = p0.length >= 8;
                          passB = p0.isNotEmpty;
                          passCon =
                              p0.contains(RegExp(r'[A-Z]')) &&
                              p0.contains(RegExp(r'[a-z]')) &&
                              p0.contains(RegExp(r'[a-z]'));
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {});
                            lihatPass = !lihatPass;
                          },
                          child: Icon(
                            lihatPass ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        namaC: passC,
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Password Wajib Diisi";
                          } else if (p0.length < 8) {
                            return "Password Minimal 8 Karakter";
                          }
                          return null;
                        },
                        teksHint: 'Masukkan Password Anda',
                        bintang: lihatPass,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 85,
                            child: VerticalDivider(
                              thickness: 2,
                              color: Color(0xffC9362B),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ketentuan Kata Sandi :',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              ketentuanKataSandi(" Minimal 8 Karakter", passP),
                              SizedBox(height: 2),
                              ketentuanKataSandi(
                                passB
                                    ? " Mantap udah ada password"
                                    : " Mana Password nya le",
                                passB,
                              ),
                              SizedBox(height: 2),
                              ketentuanKataSandi(
                                " Harus Ada Huruf Besar, Kecil, dan Angka",
                                passCon,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        " Konfirmasi Password",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      MasukkanPengguna(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {});
                            lihatPass = !lihatPass;
                          },
                          child: Icon(
                            lihatPass ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        namaC: konpassC,
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Harap isi password anda kembali disini";
                          } else if (!p0.contains(passC.text)) {
                            return "Password Tidak Sama";
                          }
                          return null;
                        },
                        teksHint: 'Konfirmasi Password Anda',
                        bintang: lihatPass,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(400, 55),
                                elevation: 1,
                                shape: DecoratedOutlinedBorder(
                                  child: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(15),
                                  ),
                                ),
                                backgroundColor: Color(0xffC9362B),
                              ),
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  register();
                                }
                              },
                              child: Text(
                                'Register',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row ketentuanKataSandi(String teks, bool kon) {
    return Row(
      children: [
        Icon(
          kon ? Icons.check_circle_sharp : Icons.remove_circle,
          size: 15,
          color: kon ? Colors.green : Colors.red,
        ),
        Text(teks, style: GoogleFonts.plusJakartaSans()),
      ],
    );
  }
}
