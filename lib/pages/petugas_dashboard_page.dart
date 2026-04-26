import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Class PetugasDashboardPage adalah halaman utama bagi petugas untuk melakukan input absensi harian
class PetugasDashboardPage extends StatefulWidget {
  final String namaPetugas; // Nama petugas yang sedang login
  const PetugasDashboardPage({super.key, required this.namaPetugas});

  @override
  State<PetugasDashboardPage> createState() => _PetugasDashboardPageState();
}

class _PetugasDashboardPageState extends State<PetugasDashboardPage> {
  String? _selectedKelas; // Menyimpan kelas yang dipilih petugas
  List _listKelas = []; // Menampung daftar semua kelas dari database
  List _listSiswa = []; // Menampung daftar siswa berdasarkan kelas yang dipilih
  Map<String, String> _statusAbsensi = {}; // Menyimpan status absensi sementara (NIS: Status)
  bool _loading = false; // Status pemuatan data
  final String _today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()); // Format tanggal hari ini

  // Alamat dasar server API (Sesuaikan dengan IP Laptop Anda)
  final String baseUrl = "http://192.168.1.5/apk_wb/apk_wb/api";

  @override
  void initState() {
    super.initState();
    // Otomatis mengambil data siswa berdasarkan nama petugas (Identitas Kelas)
    _selectedKelas = widget.namaPetugas;
    _fetchSiswa(_selectedKelas!);
  }

  // Fungsi untuk mengambil daftar kelas dari server
  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_kelas.php"));
      if (response.statusCode == 200) {
        setState(() {
          _listKelas = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error Ambil Kelas: $e");
    }
  }

  // Fungsi untuk mengambil daftar siswa berdasarkan kelas dan status absensi hari ini
  Future<void> _fetchSiswa(String kelas) async {
    setState(() {
      _loading = true;
      _listSiswa = [];
      _statusAbsensi = {};
    });
    try {
      // Menghubungi API get_absensi_harian untuk mendapatkan data siswa dan status absen terakhir hari ini
      final url = "$baseUrl/get_absensi_harian.php?kelas=${Uri.encodeComponent(kelas)}&tanggal=${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _listSiswa = data;
          // Memasukkan status yang sudah ada (jika sudah diabsen sebelumnya) ke dalam map sementara
          for (var item in data) {
            if (item['status_hari_ini'] != null && item['status_hari_ini'] != "") {
              _statusAbsensi[item['nis'].toString()] = item['status_hari_ini'];
            }
          }
          _loading = false;
        });
      }
    } catch (e) {
      _showError("Koneksi Gagal: Periksa Laragon Anda");
      setState(() => _loading = false);
    }
  }

  // Menampilkan pesan kesalahan (SnackBar merah)
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // Fungsi untuk mengirim data absensi yang telah diisi ke database
  Future<void> _simpanAbsensi() async {
    if (_statusAbsensi.isEmpty) {
      _showError("Belum ada status yang dipilih!");
      return;
    }

    setState(() => _loading = true);
    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int count = 0;

    // Mengirim data satu per satu ke server
    for (var entry in _statusAbsensi.entries) {
      try {
        final response = await http.post(
          Uri.parse("$baseUrl/update_absensi.php"),
          body: {
            "siswa_id": entry.key,
            "tanggal": tanggal,
            "status": entry.value
          },
        );
        if (response.statusCode == 200) count++;
      } catch (e) {
        debugPrint("Error simpan NIS ${entry.key}: $e");
      }
    }

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.green, content: Text("Berhasil menyimpan $count data! Data sudah terkirim ke Admin.")),
    );
    // Memperbarui tampilan list siswa setelah penyimpanan selesai
    _fetchSiswa(_selectedKelas!); 
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
          // Navigator logic inside dialog
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // --- HEADER APLIKASI ---
            Stack(
              children: [
                Container(height: 160, color: const Color(0xFF1565C0)), // Warna latar biru header
                Positioned(
                  top: 45, left: 15,
                  child: Row(children: [
                    Image.asset('assets/images/smp5logo.png', width: 45, errorBuilder: (c, e, s) => const Icon(Icons.school, color: Colors.white, size: 45)),
                    const SizedBox(width: 10),
                    const Text("SMP NEGERI 5\nLUMAJANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                ),
              ],
            ),

            // Tampilan Tanggal Hari Ini
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF4FC3F7), borderRadius: BorderRadius.circular(5)),
              child: Text(_today, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),

            // Informasi Filter dan Total Siswa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  const Icon(Icons.person_pin, color: Colors.blue, size: 20),
                  const SizedBox(width: 5),
                  const Text("Identitas Kelas Petugas", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Total Siswa", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
                          child: Text(_listSiswa.length.toString().padLeft(2, '0'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            // --- INFO KELAS OTOMATIS (MENGGANTIKAN DROPDOWN) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      "Absensi untuk Kelas: ",
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                    Text(
                      _selectedKelas ?? "-",
                      style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Spacer(),
                    // Tombol Refresh jika dibutuhkan
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: Colors.blue),
                      onPressed: () => _fetchSiswa(_selectedKelas!),
                    )
                  ],
                ),
              ),
            ),

            // Tabel Judul
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF4DB6AC), borderRadius: BorderRadius.circular(8)),
              child: const Row(children: [
                Icon(Icons.calendar_month, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text("Kelola Harian", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
            ),

            // Header Tabel (No, Nama, NIS, Status)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade500]),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))
              ),
              child: const Row(
                children: [
                  Expanded(flex: 1, child: Text("# No", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 3, child: Text("👤 Nama Siswa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 3, child: Text("🆔 NIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
                  Expanded(flex: 2, child: Text("Status", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11))),
                ],
              ),
            ),

            // --- DAFTAR SISWA (LIST VIEW) ---
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : _listSiswa.isEmpty 
                  ? const Center(child: Text("Pilih kelas untuk memulai absensi"))
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100), // Space for floating button
                      itemCount: _listSiswa.length,
                      itemBuilder: (context, i) {
                        var s = _listSiswa[i];
                        String nis = s['nis'].toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                          child: Row(
                            children: [
                              Expanded(flex: 1, child: Text((i+1).toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                              Expanded(flex: 3, child: Text(s['nama_siswa'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(nis, style: const TextStyle(fontSize: 11))),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(5)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      hint: const Text("Pilih", style: TextStyle(fontSize: 10)),
                                      value: _statusAbsensi[nis],
                                      items: ["Hadir", "Sakit", "Izin", "Alpha"].map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 10)))).toList(),
                                      onChanged: (v) => setState(() => _statusAbsensi[nis] = v!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Tombol Aksi (Kirim / Simpan)
            if (_listSiswa.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 85),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _simpanAbsensi,
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text("Kirim ke Admin", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _simpanAbsensi,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20)),
                      child: const Text("Simpan Data", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
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
}

// PENJELASAN FUNGSI FILE PETUGAS_DASHBOARD_PAGE.DART:
// 1. Berfungsi sebagai modul utama bagi petugas/guru untuk mengisi absen harian siswa di kelas.
// 2. Mengambil daftar kelas dari database untuk ditampilkan pada menu pilihan.
// 3. Mengambil data siswa dan status absensi harian secara otomatis jika sudah pernah diisi.
// 4. Memungkinkan pemilihan status kehadiran (Hadir, Sakit, Izin, Alpha) melalui menu dropdown per siswa.
// 5. Mengirimkan dan memperbarui data absensi ke database melalui API update_absensi.php secara massal.
// 6. Memberikan feedback visual berupa total jumlah siswa dan notifikasi berhasil simpan.
