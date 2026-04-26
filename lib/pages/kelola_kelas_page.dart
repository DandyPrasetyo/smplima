import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KelolaKelasPage extends StatefulWidget {
  const KelolaKelasPage({super.key});

  @override
  State<KelolaKelasPage> createState() => _KelolaKelasPageState();
}

class _KelolaKelasPageState extends State<KelolaKelasPage> {
  List _listKelas = [];
  bool _loading = true;
  final TextEditingController _kelasController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/get_kelas.php"));
      if (response.statusCode == 200) {
        setState(() {
          _listKelas = json.decode(response.body);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Error Fetch: $e");
    }
  }

  Future<void> _tambahKelas() async {
    if (_kelasController.text.isEmpty) return;
    
    try {
      final response = await http.post(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/add_kelas.php"), body: {"nama_kelas": _kelasController.text.toUpperCase()});
      if (json.decode(response.body)['status'] == 'success') {
        _kelasController.clear();
        _fetchKelas();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kelas Ditambahkan")));
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  Future<void> _hapusKelas(String id, String namaKelas) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kelas?"),
        content: Text("Data kelas $namaKelas akan dihapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
    if (!confirm) return;
    try {
      await http.post(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/delete_kelas.php"), body: {"id": id});
      _fetchKelas();
    } catch (e) { debugPrint(e.toString()); }
  }

  void _showEditDialog(String id, String oldNama) {
    TextEditingController editController = TextEditingController(text: oldNama);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Nama Kelas"),
        content: TextField(controller: editController, textCapitalization: TextCapitalization.characters),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.isEmpty) return;
              await http.post(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/update_kelas.php"), body: {"id": id, "new_nama_kelas": editController.text});
              Navigator.pop(context);
              _fetchKelas();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusSemuaKelas() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Semua Kelas?"),
        content: const Text("Peringatan: Semua data kelas dan data siswa yang terhubung akan dihapus permanen!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus Semua", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
    if (!confirm) return;
    try {
      final response = await http.post(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/delete_all_kelas.php"));
      if (json.decode(response.body)['status'] == 'success') {
        _fetchKelas();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua Kelas Telah Dihapus"), backgroundColor: Colors.red));
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F9),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(height: 160, width: double.infinity, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/imagesmp5.jpeg'), fit: BoxFit.cover))),
                    Container(height: 160, color: Colors.black.withOpacity(0.4)),
                    Positioned(top: 40, left: 10, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28))),
                    Positioned(
                      top: 50, left: 60,
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

                // Judul Bar Modern (Gradient Cyan) dengan Tombol Reset
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF00D1B2)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFF00D1B2).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))]
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: Colors.white),
                      const SizedBox(width: 10),
                      const Text("Kelola Kelas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _hapusSemuaKelas,
                        icon: const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                        label: const Text("Reset", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                      )
                    ],
                  ),
                ),

                // Form Input Modern
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kelasController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: "Nama Kelas (contoh : 7A)",
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _tambahKelas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D1B2), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: const Color(0xFF00D1B2).withOpacity(0.5)
                        ),
                        child: const Text("+ Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Tabel Data Kelas Modern
                Expanded(
                  child: _loading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        itemCount: _listKelas.length,
                        itemBuilder: (context, i) {
                          var item = _listKelas[i];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))]
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: const Color(0xFFF0F9F9), child: Text("${i+1}", style: const TextStyle(color: Color(0xFF00D1B2), fontWeight: FontWeight.bold))),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nama_kelas'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("${item['jumlah_siswa']} Siswa Terdaftar", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 22), onPressed: () => _showEditDialog(item['id'].toString(), item['nama_kelas'])),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22), onPressed: () => _hapusKelas(item['id'].toString(), item['nama_kelas'])),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 140,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text("KEMBALI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
