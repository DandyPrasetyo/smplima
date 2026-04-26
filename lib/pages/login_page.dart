import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apk_wb/styles/app_styles.dart';
import 'package:apk_wb/pages/register_page.dart';
import 'package:apk_wb/pages/admin_dashboard_page.dart';
import 'package:apk_wb/pages/petugas_dashboard_page.dart';
import 'package:apk_wb/pages/guru_dashboard_page.dart';
import 'package:apk_wb/widgets/custom_field.dart';

class LoginPage extends StatefulWidget {
  final String userType;
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Variabel untuk animasi
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    
    _controller.forward(); // Mulai animasi saat halaman dibuka
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi Username dan Password")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      // FOKUS CHROME: Gunakan localhost agar koneksi stabil
      String baseUrl = "http://localhost/apk_wb/apk_wb/api";
      var response = await http.post(Uri.parse("$baseUrl/login.php"), body: {
        "username": _usernameController.text,
        "password": _passwordController.text,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == "success") {
          String nama = data['data']['nama_lengkap'] ?? "User";
          if (widget.userType == "ADMIN") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => AdminDashboardPage(namaGuru: nama)));
          } else if (widget.userType == "GURU") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => GuruDashboardPage(namaGuru: nama)));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PetugasDashboardPage(namaPetugas: nama)));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal terhubung ke server."), backgroundColor: Colors.orange));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // TOMBOL HOME MELAYANG SEPERTI DI WALI MURID
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        backgroundColor: Colors.white,
        elevation: 10,
        child: const Icon(Icons.home, color: Color(0xFF00D1B2), size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          // Background Gradient Cyan Cerah
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00F5D4), Color(0xFF00D1B2)],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
            ),
          ),
          
          SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Hero(tag: 'logo', child: Image.asset('assets/images/smp5logo.png', width: 100)),
                    const SizedBox(height: 15),
                    Text("MASUK ${widget.userType}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                    const Text("SISTEM ABSENSI DIGITAL", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                    
                    const SizedBox(height: 40),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00D1B2).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))
                          ],
                        ),
                        child: Column(
                          children: [
                            CustomField(label: "Username / NIP", icon: Icons.person_outline, controller: _usernameController),
                            const SizedBox(height: 20),
                            CustomField(
                              label: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscure: !_isPasswordVisible,
                              controller: _passwordController,
                              onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            const SizedBox(height: 35),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00F5D4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 5,
                                  shadowColor: const Color(0xFF00F5D4).withOpacity(0.5),
                                ),
                                child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("MASUK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                            
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Belum punya akun? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                InkWell(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterPage())),
                                  child: const Text("Daftar Sekarang", style: TextStyle(color: Color(0xFF00D1B2), fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Padding bawah agar tidak tertutup tombol
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
