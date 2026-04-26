import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'parent_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _totalSiswa = "...";
  String _totalPetugas = "...";
  String _totalGuru = "...";
  String _totalAdmin = "...";
  String _totalKelas = "...";

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/get_home_stats.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == "success") {
          setState(() {
            _totalSiswa = data['data']['siswa'].toString();
            _totalPetugas = data['data']['petugas'].toString();
            _totalAdmin = data['data']['admin'].toString();
            _totalKelas = data['data']['kelas'].toString();
            // Jika API belum update, kita tampilkan 0 dulu atau ambil dari data admin jika digabung
            _totalGuru = data['data']['guru']?.toString() ?? "0"; 
          });
        }
      }
    } catch (e) {
      debugPrint("Error Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00F5D4), Color(0xFF01BEA2)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Image.asset('assets/images/smp5logo.png', width: 55),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Selamat Datang,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text("SMPN 5 LUMAJANG", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // STATS CARD DENGAN ICON GURU BARU
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoItem(label: "Siswa", value: _totalSiswa, icon: Icons.people_alt_rounded, color: Colors.blue),
                      _InfoItem(label: "Staff", value: _totalPetugas, icon: Icons.badge_rounded, color: Colors.orange),
                      _InfoItem(label: "Guru", value: _totalGuru, icon: Icons.school_rounded, color: Colors.green), // ICON GURU
                      _InfoItem(label: "Admin", value: _totalAdmin, icon: Icons.security_rounded, color: Colors.red),
                      _InfoItem(label: "Kelas", value: _totalKelas, icon: Icons.room_preferences_rounded, color: Colors.teal),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              Expanded(child: _MenuCard(title: "ADMIN", icon: Icons.admin_panel_settings, color: const Color(0xFF00D1B2), onTap: () => _toLogin(context, "ADMIN"))),
                              const SizedBox(width: 15),
                              Expanded(child: _MenuCard(title: "GURU", icon: Icons.school, color: const Color(0xFF00D1B2), onTap: () => _toLogin(context, "GURU"))),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(child: _MenuCard(title: "SISWA", icon: Icons.person_pin, color: const Color(0xFF00D1B2), onTap: () => _toLogin(context, "SISWA / PETUGAS"))),
                              const SizedBox(width: 15),
                              Expanded(child: _MenuCard(title: "WALI MURID", icon: Icons.family_restroom, color: const Color(0xFF00D1B2), onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentDashboardPage()));
                              })),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toLogin(BuildContext context, String type) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(userType: type)));
  }
}

class _MenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MenuCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              // Efek Bayangan 3D
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.white,
                offset: const Offset(-2, -2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.color.withOpacity(0.05)),
                ),
                child: Icon(widget.icon, size: 40, color: widget.color),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: widget.color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 22),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Color(0xFF2D3436), fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
