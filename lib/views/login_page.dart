import 'package:control_style/control_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:renjana/database/db_helper.dart';
import 'package:renjana/extensions/navigation.dart';
import 'package:renjana/views/appPage/home.dart';
import 'package:renjana/views/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool lihatPass = true;

  void login() async {
    final email = emailC.text.trim();
    final password = passC.text.trim();

    final pengguna = await DbHelper().loginUser(email, password);

    if (!mounted) return;

    if (pengguna != null) {
      context.pushAndRemoveAll(Home());
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Data Tidak Ditemukan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF4F0E7),
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/Rlogos.png", width: 30),
            Text("RENJANA", style: GoogleFonts.dmSerifDisplay(fontSize: 28)),
          ],
        ),
      ),
      backgroundColor: Color(0xffF4F0E7),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Text(
                  "Selamat\ndatang\nkembali",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 48,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Divider(thickness: 2, color: Color(0xffC9362B)),
                ),
                SizedBox(height: 40),
                Text(
                  " Email",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                MasukkanPengguna(
                  bintang: false,
                  namaC: emailC,
                  teksHint: 'Masukkan Email Anda',
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return "Email tidak boleh kosong";
                    } else if (!p0.contains('@')) {
                      return "Email tidak valid";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  " Password",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
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
                  bintang: lihatPass,
                  namaC: passC,
                  teksHint: 'Masukkan Password Anda',
                  validator: (p1) {
                    if (p1 == null || p1.isEmpty) {
                      return "Password tidak boleh kosong";
                    } else if (p1.length < 8) {
                      return "Password kurang dari 8 karakter";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: buttonLoginRegister(
                        context,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {}
                          login();
                        },
                        teks: "Login",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum Punya Akun? ",
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(RegisterPage());
                      },
                      child: Text(
                        "Buat Akun",
                        style: GoogleFonts.plusJakartaSans(
                          color: Color(0xffC9362B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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

  ElevatedButton buttonLoginRegister(
    BuildContext context, {
    required void Function()? onPressed,
    required String teks,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(400, 55),
        elevation: 1,
        shape: DecoratedOutlinedBorder(
          // shadow: [
          //   // BoxShadow(spreadRadius: 1, color: Color.fromRGBO(55, 93, 251, 1)),
          //   BoxShadow(
          //     blurRadius: 2,
          //     offset: Offset(0, 1),
          //     // color: Color.fromRGBO(37, 62, 167, 0.48),
          //   ),
          // ],
          child: RoundedRectangleBorder(
            // side: BorderSide(
            //   // color: Color.fromRGBO(255, 255, 255, 0.1),
            //   width: 1,
            //   strokeAlign: BorderSide.strokeAlignInside,
            // ),
            borderRadius: BorderRadiusGeometry.circular(15),
          ),
        ),
        backgroundColor: Color(0xffC9362B),
        // shadowColor: Colors.black,
      ),
      onPressed: onPressed,
      // () {
      //   // PreferenceHandler.setLogin(true);
      //   // context.push(Tugas8flutter());
      // },
      child: Text(
        teks,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MasukkanPengguna extends StatelessWidget {
  const MasukkanPengguna({
    super.key,
    required this.namaC,
    required this.validator,
    required this.teksHint,
    required this.bintang,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
  });

  final void Function(String)? onChanged;
  final TextEditingController namaC;
  final String? Function(String?)? validator;
  final String teksHint;
  final bool bintang;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      obscureText: bintang,
      validator: validator,
      controller: namaC,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        hintText: teksHint,
        hintStyle: TextStyle(color: Colors.black38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.black12),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
