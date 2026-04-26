import 'package:flutter/material.dart';
import 'package:apk_wb/pages/kelola_absensi_page.dart';
import 'package:apk_wb/pages/kelola_kelas_page.dart';
import 'package:apk_wb/pages/kelola_siswa_page.dart';
import 'package:apk_wb/pages/rekap_absensi_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardPage extends StatefulWidget {
  final String namaGuru;
  const AdminDashboardPage({super.key, required this.namaGuru});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
      final response = await http.get(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/get_dashboard_stats.php"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalKelas = int.parse(data['total_kelas'].toString());
          totalSiswa = int.parse(data['total_siswa'].toString());
          totalAbsensi = int.parse(data['total_absensi'].toString());
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _loading = false);
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
              Navigator.of(context).popUntil((route) => route.isFirst);
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
          // Navigator.of(context).popUntil di dialog sudah menangani ini
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/imagesmp5.jpeg'), fit: BoxFit.cover)),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
                Positioned(
                  top: 50, left: 20,
                  child: Row(
                    children: [
                      Image.asset('assets/images/smp5logo.png', width: 50),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SMP NEGERI 5", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
                          Text("LUMAJANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Expanded(child: _buildStatCard(totalKelas.toString(), "Kelas", Icons.library_books)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(totalSiswa.toString(), "Siswa", Icons.person)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard(totalAbsensi.toString(), "Absensi Hari Ini", Icons.calendar_month)),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _buildMenuButton(context, "Kelola Kelas", Icons.menu_book, const KelolaKelasPage()),
                    _buildMenuButton(context, "Kelola Siswa", Icons.person_search, const KelolaSiswaPage()),
                    _buildMenuButton(context, "Kelola Absensi", Icons.edit_calendar, const KelolaAbsensiPage()),
                    _buildMenuButton(context, "Rekap Absensi", Icons.folder_shared, const RekapAbsensiPage()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // Space for floating button
          ],
        ),
        floatingActionButton: InkWell(
          onTap: _showLogoutDialog,
          child: Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF80DEEA), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 22, color: Colors.black87), FittedBox(fit: BoxFit.scaleDown, child: Text(_loading ? "..." : value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), FittedBox(fit: BoxFit.scaleDown, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))]),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget? destination) {
    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination)).then((_) => _fetchStats());
        }
      },
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF4DD0E1), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 40, color: Colors.black87), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
      ),
    );
  }
}
