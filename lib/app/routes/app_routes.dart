import 'package:flutter/material.dart';

// Dipakai halaman yang perlu memuat ulang datanya setiap kali halaman di
// atasnya ditutup, mis. beranda setelah pengguna membaca sebuah arsip.
final RouteObserver<ModalRoute<void>> pengamatRute =
    RouteObserver<ModalRoute<void>>();
