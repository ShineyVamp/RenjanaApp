import 'package:flutter/material.dart';
import 'package:renjana/core/extensions/navigation.dart';
import 'package:renjana/presentation/auth/login_page.dart';
import 'package:renjana/services/preference_handler.dart';

class Logout18 extends StatefulWidget {
  const Logout18({super.key});

  @override
  State<Logout18> createState() => _Logout18State();
}

class _Logout18State extends State<Logout18> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            PreferenceHandler.logOut();
            context.pushAndRemoveAll(LoginPage());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Berhasil Logout"),
                duration: Duration(milliseconds: 1200),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.logout), Text("LOGOUT SEKARANG")],
          ),
        ),
      ),
    );
  }
}
