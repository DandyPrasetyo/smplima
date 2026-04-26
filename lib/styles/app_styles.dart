import 'package:flutter/material.dart';

/// FILE GAYA UTAMA (CSS-nya Flutter)
/// Di sini kita mengatur semua tampilan visual agar seragam di seluruh aplikasi.
/// Jika ingin mengubah warna tema, cukup ubah di sini saja.

class AppColors {
  // --- WARNA TEMA UTAMA (BIRU KEHIJUAN CERAH) ---
  static const Color primary = Color(0xFF00F5D4); // Cyan Cerah sesuai gambar
  static const Color secondary = Color(0xFF00BB9F); // Teal sedikit gelap untuk kontras
  static const Color background = Color(0xFFF5F9F9); // Latar belakang putih kebiruan bersih
  static const Color darkText = Color(0xFF1A1A1A);
  
  // --- WARNA NETRAL ---
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;
  static const Color greyText = Colors.black54;
  static const Color error = Colors.redAccent;
  static const Color success = Color(0xFF00F5D4);
}

class AppDecorations {
  // headerDecoration: Mengatur bentuk bagian atas halaman (Putih dengan sudut melengkung di bawah).
  static BoxDecoration headerDecoration = const BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(30),
      bottomRight: Radius.circular(30),
    ),
  );

  // inputDecoration: Mengatur tampilan kotak input (NIS dan Nama) supaya bersih dan putih.
  static BoxDecoration inputDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors.grey.shade200),
  );

  // cardDecoration: Digunakan untuk membungkus form Login dan Register agar terlihat melayang (Shadow).
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ],
  );

  // filterDecoration: Mengatur kotak dropdown kelas dan pilihan tanggal.
  static BoxDecoration filterDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(8),
  );

  // statCardDecoration: Kotak statistik (Hadir, Sakit, dll) yang dibuat agak transparan agar terlihat modern.
  static BoxDecoration statCardDecoration = BoxDecoration(
    color: AppColors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: AppColors.white.withOpacity(0.2)),
  );

  // resultDecoration: Kotak hasil pencarian siswa yang memiliki efek bayangan (boxShadow).
  static BoxDecoration resultDecoration = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 5),
      )
    ],
  );
}

class AppTextStyles {
  // headerTitle: Gaya tulisan besar untuk judul utama.
  static const TextStyle headerTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // subHeader: Gaya tulisan kecil di bawah judul untuk instruksi.
  static const TextStyle subHeader = TextStyle(
    fontSize: 14,
    color: AppColors.greyText,
  );

  // labelSmall: Label kecil di atas filter (Pilih Kelas/Tanggal).
  static const TextStyle labelSmall = TextStyle(
    color: AppColors.white,
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // buttonText: Gaya tulisan di dalam tombol utama.
  static const TextStyle buttonText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}

// PENJELASAN FUNGSI FILE APP_STYLES.DART:
// 1. Bertindak sebagai "Pusat Desain" atau "CSS" dalam aplikasi.
// 2. Menyimpan semua variabel warna, dekorasi kotak, dan gaya tulisan di satu tempat.
// 3. Memudahkan pengembang untuk mengubah tampilan seluruh aplikasi hanya dengan mengganti satu baris kode di sini.
// 4. Memastikan konsistensi visual (warna dan font yang sama) di setiap halaman aplikasi.
// 5. Mengurangi penulisan kode berulang untuk pengaturan gaya (Shadow, Border, Padding).
