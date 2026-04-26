import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  final TextEditingController _namaController = TextEditingController();
  String? _selectedKelas;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _listKelas = [];
  bool _isLoading = false;
  Map<String, dynamic>? _searchResult;
  String _message = "Silakan masukkan nama siswa dan pilih kelas.";

  final String baseUrl = "http://192.168.1.5/apk_wb/apk_wb/api";

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_kelas.php"));
      if (response.statusCode == 200) {
        setState(() => _listKelas = json.decode(response.body));
      }
    } catch (e) {
      debugPrint("Error Fetch Kelas: $e");
    }
  }

  Future<void> _searchAbsensi() async {
    if (_namaController.text.length < 3 || _selectedKelas == null) {
      setState(() => _message = "Masukkan minimal 3 huruf nama dan pilih kelas!");
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResult = null;
      _message = "Mencari data..."; // Reset pesan saat mencari
    });

    try {
      final response = await http.get(Uri.parse(
          "$baseUrl/cari_absensi.php?nama=${_namaController.text}&kelas=$_selectedKelas&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data['status'] == 'success') {
            _searchResult = data['data'];
          } else {
            _message = data['message'];
          }
        });
      } else {
        setState(() => _message = "Error Server: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _message = "Terjadi kesalahan koneksi ke server.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _backToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Biarkan sistem menangani pop normal untuk Orang Tua
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF00D1B2), Color(0xFF009688)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/smp5logo.png', width: 70),
                    const SizedBox(height: 15),
                    const Text("Cek Kehadiran Siswa", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: "Nama Lengkap Siswa",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Pilih Kelas"),
                                value: _selectedKelas,
                                isExpanded: true,
                                items: _listKelas.map((e) => DropdownMenuItem(value: e['nama_kelas'].toString(), child: Text(e['nama_kelas'].toString()))).toList(),
                                onChanged: (v) => setState(() => _selectedKelas = v),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () async {
                            DateTime? p = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2024), lastDate: DateTime.now());
                            if (p != null) setState(() => _selectedDate = p);
                          },
                          icon: const Icon(Icons.calendar_month, color: Color(0xFF009688), size: 35),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _searchAbsensi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D1B2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("CARI DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 30),

                    if (_isLoading) const CircularProgressIndicator(color: Color(0xFF00D1B2))
                    else if (_searchResult != null) _buildCardResult()
                    else Text(_message, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for floating button
            ],
          ),
        ),
        floatingActionButton: InkWell(
          onTap: _backToHome,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text("HOME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildCardResult() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(_searchResult?['nama_siswa'] ?? "Nama Tidak Diketahui", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 10),
            _rowInfo("Tanggal", DateFormat('dd MMM yyyy').format(_selectedDate)),
            _rowInfo("Status", _searchResult?['status'] ?? "Belum Absen"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(_searchResult?['status']),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text((_searchResult?['status'] ?? "BELUM ABSEN").toUpperCase(), 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]));

  Color _getStatusColor(String? s) {
    if (s == 'Hadir') return Colors.green;
    if (s == 'Sakit') return Colors.blue;
    if (s == 'Izin') return Colors.orange;
    if (s == 'Alpha') return Colors.red;
    return Colors.grey;
  }
}
