import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  // Memastikan sistem Flutter sudah siap sebelum menjalankan perintah lainnya
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal Bahasa Indonesia untuk PDF & UI
  await initializeDateFormatting('id_ID', null);

  // Mengunci orientasi layar agar tetap tegak (Portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Mengatur baris status (status bar) agar menjadi transparan
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Menjalankan aplikasi utama
  runApp(const MyApp());
}

// PENJELASAN FUNGSI FILE MAIN.DART:
// 1. Titik awal (Entry Point) eksekusi aplikasi saat pertama kali dijalankan.
// 2. Menginisialisasi binding Flutter agar fitur sistem bisa digunakan.
// 3. Mengatur konfigurasi perangkat keras seperti rotasi layar (Hanya Portrait).
// 4. Mengatur tampilan sistem UI seperti warna status bar.
// 5. Memanggil fungsi runApp() untuk memulai tampilan antarmuka aplikasi.
