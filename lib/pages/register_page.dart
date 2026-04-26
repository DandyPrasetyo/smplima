import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apk_wb/styles/app_styles.dart';
import 'package:apk_wb/widgets/custom_field.dart';

// Class RegisterPage digunakan untuk mendaftarkan akun baru (Admin/Guru atau Petugas)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false; // Status untuk melihat/sembunyikan password
  bool _isLoading = false; // Status saat proses pendaftaran berlangsung
  
  // Pilihan awal peran pengguna (Role)
  String _selectedUserType = "ADMIN";
  
  // Pengendali teks untuk mengambil input dari form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); 
  final TextEditingController _passController = TextEditingController();

  // Fungsi untuk mengirim data pendaftaran ke server
  Future<void> _register() async {
    // Validasi: Pastikan semua kolom sudah terisi
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // FOKUS CHROME: Gunakan localhost agar koneksi stabil
      String baseUrl = "http://localhost/apk_wb/apk_wb/api";
      var url = Uri.parse("$baseUrl/register.php");
      
      var response = await http.post(url, body: {
        "nama": _nameController.text,
        "username": _usernameController.text,
        "password": _passController.text,
        "role": _selectedUserType.toLowerCase(),
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == "success") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pendaftaran Berhasil! Silakan Login")),
            );
            Navigator.pop(context); // Kembali ke halaman Login setelah sukses
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "Gagal Mendaftar")),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal terhubung ke server (Cek Laragon Anda)")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header dengan Logo Sekolah
            Container(
              width: double.infinity,
              decoration: AppDecorations.headerDecoration,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  const Text("Daftar Akun Baru", style: AppTextStyles.headerTitle),
                  const SizedBox(height: 10),
                  Image.asset('assets/images/smp5logo.png', width: 60, height: 60),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Nama Lengkap
                    CustomField(
                      label: "Nama Lengkap",
                      icon: Icons.person,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 15),
                    // Input Username atau NIP
                    CustomField(
                      label: "Username / NIP",
                      icon: Icons.badge,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 15),
                    
                    // Pilihan Role (Daftar Sebagai Admin atau Petugas)
                    const Text("Daftar Sebagai", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUserType,
                          isExpanded: true,
                          items: ["ADMIN", "GURU", "PETUGAS"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedUserType = val!);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Input Password dengan fitur sembunyikan/tampilkan
                    CustomField(
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      obscure: !_isPasswordVisible,
                      controller: _passController,
                      onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tombol untuk memproses pendaftaran
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("DAFTAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Navigasi kembali ke halaman Login jika sudah punya akun
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Sudah punya akun? Login di sini"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Tombol melayang untuk kembali ke halaman utama (Home)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.white,
        child: const Icon(Icons.home, color: AppColors.primary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// PENJELASAN FUNGSI FILE REGISTER_PAGE.DART:
// 1. Menyediakan formulir pendaftaran akun bagi Admin, Guru, atau Petugas Absensi.
// 2. Mengirimkan data (Nama, Username, Password, Role) ke database melalui API register.php.
// 3. Memiliki fitur pemilihan peran (Role) menggunakan Dropdown agar hak akses pengguna sesuai.
// 4. Menerapkan validasi input sederhana untuk mencegah pendaftaran dengan data kosong.
// 5. Terintegrasi dengan navigasi Flutter (Navigator) untuk alur perpindahan antar halaman yang mulus.
