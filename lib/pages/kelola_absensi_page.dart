import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Class KelolaAbsensiPage digunakan oleh Admin untuk meninjau dan mengubah data absensi harian.
// Berbeda dengan dashboard petugas, halaman ini memungkinkan admin memilih tanggal kapanpun (masa lalu/depan).
class KelolaAbsensiPage extends StatefulWidget {
  const KelolaAbsensiPage({super.key});

  @override
  State<KelolaAbsensiPage> createState() => _KelolaAbsensiPageState();
}

class _KelolaAbsensiPageState extends State<KelolaAbsensiPage> {
  DateTime _selectedDate = DateTime.now(); // Tanggal yang sedang dilihat
  String? _selectedKelas; // Kelas yang dipilih untuk difilter
  List _listKelas = []; // Daftar kelas untuk dropdown
  List _listSiswa = []; // Daftar siswa beserta status absennya
  bool _loading = false; // Status pemuatan data dari server
  final String baseUrl = "http://192.168.1.5/apk_wb/apk_wb/api"; // Alamat dasar API

  @override
  void initState() {
    super.initState();
    _fetchKelas(); // Ambil daftar kelas saat halaman dimuat
  }

  // Mengambil daftar kelas dari database agar Admin bisa memilih kelas
  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_kelas.php"));
      if (response.statusCode == 200) {
        setState(() {
          _listKelas = json.decode(response.body);
          if (_listKelas.isNotEmpty) {
            // Set default kelas ke kelas pertama yang ditemukan
            _selectedKelas = _listKelas[0]['nama_kelas'].toString();
            _fetchSiswaAbsensi(); // Langsung ambil data absen untuk kelas tersebut
          }
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Kelas: $e");
    }
  }

  // Mengambil data absensi siswa berdasarkan filter KELAS dan TANGGAL
  Future<void> _fetchSiswaAbsensi() async {
    if (_selectedKelas == null) return;
    setState(() => _loading = true);
    try {
      // Mengirimkan parameter kelas dan tanggal ke API
      final url = "$baseUrl/get_absensi_harian.php?kelas=${Uri.encodeComponent(_selectedKelas!)}&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _listSiswa = json.decode(response.body);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Absensi: $e");
      setState(() => _loading = false);
    }
  }

  // Fungsi untuk memperbarui status absensi siswa secara langsung (Real-time Update)
  Future<void> _updateAbsensi(String nis, String status) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_absensi.php"),
        body: {
          "siswa_id": nis,
          "tanggal": DateFormat('yyyy-MM-dd').format(_selectedDate),
          "status": status,
        },
      );
      if (response.statusCode == 200) {
        _fetchSiswaAbsensi(); // Refresh data setelah berhasil update
        // Menampilkan notifikasi kecil (SnackBar) dengan warna sesuai status
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: _getColor(status), 
          content: Text("Status NIS $nis diubah ke $status"), 
          duration: const Duration(milliseconds: 700)
        ));
      }
    } catch (e) {
      debugPrint("Error Update: $e");
    }
  }

  // Memberikan warna identitas untuk setiap status absensi
  Color _getColor(String? s) {
    if (s == 'Hadir') return Colors.green;
    if (s == 'Sakit') return Colors.blue;
    if (s == 'Izin') return Colors.orange;
    if (s == 'Alpha') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F9),
      appBar: AppBar(
        title: const Text("Kelola Absensi Harian", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00D1B2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- HEADER FILTER (CYAN) ---
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFF00D1B2),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Filter Tanggal
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tanggal", style: TextStyle(color: Colors.white70, fontSize: 10)),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () async {
                                DateTime? p = await showDatePicker(
                                  context: context, 
                                  initialDate: _selectedDate, 
                                  firstDate: DateTime(2020), 
                                  lastDate: DateTime.now().add(const Duration(days: 365))
                                );
                                if (p != null) { setState(() { _selectedDate = p; _fetchSiswaAbsensi(); }); }
                              },
                              child: Row(children: [
                                const Icon(Icons.calendar_today, color: Colors.white, size: 14), 
                                const SizedBox(width: 5), 
                                Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Filter Kelas
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Kelas", style: TextStyle(color: Colors.white70, fontSize: 10)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKelas, isExpanded: true,
                                dropdownColor: const Color(0xFF00D1B2),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                items: _listKelas.map((e) => DropdownMenuItem(value: e['nama_kelas'].toString(), child: Text(e['nama_kelas'].toString(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                                onChanged: (v) { setState(() { _selectedKelas = v; _fetchSiswaAbsensi(); }); },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _navBtn(Icons.arrow_back_ios, "Kemarin", () => setState(() { _selectedDate = _selectedDate.subtract(const Duration(days: 1)); _fetchSiswaAbsensi(); })),
                    const SizedBox(width: 8),
                    _navBtn(Icons.today, "Hari Ini", () => setState(() { _selectedDate = DateTime.now(); _fetchSiswaAbsensi(); })),
                    const SizedBox(width: 8),
                    _navBtn(Icons.arrow_forward_ios, "Besok", () => setState(() { _selectedDate = _selectedDate.add(const Duration(days: 1)); _fetchSiswaAbsensi(); }), isRight: true),
                  ],
                )
              ],
            ),
          ),

          // --- HEADER TABEL ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Row(
              children: [
                _th("No", 1), _th("Nama Siswa", 4, align: TextAlign.left),
                _th("Status", 2), _th("Edit", 3),
              ],
            ),
          ),

          // --- DAFTAR SISWA ---
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _listSiswa.length,
                  itemBuilder: (context, i) {
                    var s = _listSiswa[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text("${i + 1}", style: const TextStyle(color: Colors.grey, fontSize: 12))),
                            Expanded(flex: 4, child: Text(s['nama_siswa'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Expanded(flex: 2, child: Center(child: Text(s['status_hari_ini'] ?? "-", style: TextStyle(color: _getColor(s['status_hari_ini']), fontWeight: FontWeight.bold, fontSize: 12)))),
                            Expanded(flex: 3, child: Container(
                              height: 35,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: (s['status_hari_ini'] == "" || s['status_hari_ini'] == null) ? null : s['status_hari_ini'],
                                  hint: const Text("Pilih", style: TextStyle(fontSize: 11)), isExpanded: true,
                                  items: ['Hadir', 'Sakit', 'Izin', 'Alpha'].map((st) => DropdownMenuItem(value: st, child: Text(st, style: TextStyle(fontSize: 12, color: _getColor(st), fontWeight: FontWeight.bold)))).toList(),
                                  onChanged: (v) => _updateAbsensi(s['nis'].toString(), v!),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),

          // --- BAR BIRU KEMBALI ---
          Container(
            width: double.infinity,
            height: 70,
            color: Colors.blue.shade700,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  Text("KEMBALI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk tombol navigasi tanggal
  Widget _navBtn(IconData i, String l, VoidCallback t, {bool isRight = false}) => InkWell(
    onTap: t,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: Colors.white30), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        if(!isRight) Icon(i, color: Colors.white, size: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 11))),
        if(isRight) Icon(i, color: Colors.white, size: 12),
      ]),
    ),
  );

  // Widget Helper untuk Header Tabel (Table Header)
  Widget _th(String t, int f, {TextAlign align = TextAlign.center}) => Expanded(flex: f, child: Text(t, textAlign: align, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)));
}

// PENJELASAN FUNGSI FILE KELOLA_ABSENSI_PAGE.DART:
// 1. Modul khusus Admin untuk memantau dan mengoreksi data absensi harian siswa.
// 2. Mendukung filter dua arah: berdasarkan Tanggal (bebas memilih tanggal mana saja) dan berdasarkan Kelas.
// 3. Memiliki fitur navigasi cepat (Kemarin, Hari Ini, Besok) untuk mempermudah perpindahan data antar hari.
// 4. Perubahan status absensi dilakukan secara "Instant Update", di mana Admin cukup memilih status di dropdown dan data langsung tersimpan ke database.
// 5. Memberikan feedback visual berupa warna teks yang berbeda untuk setiap status (Hijau=Hadir, Merah=Alpha, dsb).
// 6. Terhubung dengan API get_absensi_harian.php untuk membaca data dan update_absensi.php untuk menyimpan perubahan.
