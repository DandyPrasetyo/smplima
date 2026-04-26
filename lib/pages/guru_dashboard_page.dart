import 'package:flutter/material.dart';
import 'package:apk_wb/pages/rekap_absensi_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GuruDashboardPage extends StatefulWidget {
  final String namaGuru;
  const GuruDashboardPage({super.key, required this.namaGuru});

  @override
  State<GuruDashboardPage> createState() => _GuruDashboardPageState();
}

class _GuruDashboardPageState extends State<GuruDashboardPage> {
  int totalKelas = 0;
  int totalSiswa = 0;
  int totalAbsensi = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      // FOKUS CHROME: Menggunakan localhost agar koneksi ke Laragon stabil
      final response = await http.get(Uri.parse("http://localhost/apk_wb/apk_wb/api/get_dashboard_stats.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            totalKelas = int.parse(data['total_kelas']?.toString() ?? "0");
            totalSiswa = int.parse(data['total_siswa']?.toString() ?? "0");
            totalAbsensi = int.parse(data['total_absensi']?.toString() ?? "0");
            _loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Fetching Stats: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah kamu yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            }, 
            child: const Text("Ya, Logout", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showLogoutDialog();
        if (shouldPop && context.mounted) {
           Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9F9),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/imagesmp5.jpeg'), fit: BoxFit.cover),
                    ),
                  ),
                  Container(height: 220, color: Colors.black.withOpacity(0.5)),
                  Positioned(
                    top: 60, left: 20, right: 20,
                    child: Row(
                      children: [
                        Image.asset('assets/images/smp5logo.png', width: 50),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("SMP NEGERI 5", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text("Selamat Datang, ${widget.namaGuru}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard(totalKelas.toString(), "Kelas", Icons.home_work, Colors.blue)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard(totalSiswa.toString(), "Siswa", Icons.people, Colors.orange)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStatCard(totalAbsensi.toString(), "Absen", Icons.fact_check, Colors.green)),
                    ],
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Menu Utama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
              ),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: const EdgeInsets.all(15),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                children: [
                  _buildMenuButton(context, "Kelola Absensi", Icons.edit_calendar, const RekapAbsensiPage(), const Color(0xFF00D1B2)),
                  _buildMenuButton(context, "Rekap Data", Icons.insert_chart, const RekapAbsensiPage(), Colors.indigo),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final shouldPop = await _showLogoutDialog();
            if (shouldPop && mounted) {
               Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
          backgroundColor: Colors.redAccent,
          label: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(_loading ? "..." : value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget page, Color color) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
