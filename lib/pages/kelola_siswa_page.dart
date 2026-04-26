import 'dart:typed_data';
import 'package:flutter/material.dart' hide Border;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart' show Border, BorderSide;

class KelolaSiswaPage extends StatefulWidget {
  const KelolaSiswaPage({super.key});

  @override
  State<KelolaSiswaPage> createState() => _KelolaSiswaPageState();
}

class _KelolaSiswaPageState extends State<KelolaSiswaPage> {
  List _listSiswa = [];
  List _listKelas = [];
  bool _loading = true;
  String _fileName = "Belum ada file dipilih";
  Uint8List? _excelBytes; 
  File? _selectedFile;

  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  String? _selectedJK;
  String? _selectedKelasId;

  @override
  void initState() {
    super.initState();
    _fetchSiswa();
    _fetchKelas();
  }

  Future<void> _fetchSiswa() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/get_siswa_v2.php"));
      if (response.statusCode == 200) {
        setState(() {
          _listSiswa = json.decode(response.body);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/get_kelas.php"));
      if (response.statusCode == 200) {
        setState(() => _listKelas = json.decode(response.body));
      }
    } catch (e) {}
  }

  Future<void> _importExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );
    
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _excelBytes = result.files.single.bytes;
        _selectedFile = result.files.single.path != null ? File(result.files.single.path!) : null;
      });
      _uploadFile();
    }
  }

  Future<void> _uploadFile() async {
    if (_excelBytes == null && _selectedFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2))),
    );

    try {
      Uint8List bytes;
      if (_excelBytes != null) {
        bytes = _excelBytes!;
      } else {
        bytes = _selectedFile!.readAsBytesSync();
      }

      var excel = Excel.decodeBytes(bytes);
      List<Map<String, dynamic>> dataSiswa = [];

      for (var table in excel.tables.keys) {
        var tableData = excel.tables[table];
        if (tableData == null) continue;

        int colNis = -1, colNama = -1, colJK = -1, colKelas = -1;

        for (int i = 0; i < tableData.rows.length && i < 15; i++) {
          var row = tableData.rows[i];
          for (int c = 0; c < row.length; c++) {
            String v = row[c]?.value?.toString().toUpperCase() ?? "";
            if (v.contains("INDUK") || v == "NIS") colNis = c;
            if (v.contains("NAMA") && !v.contains("AYAH") && !v.contains("IBU")) colNama = c;
            if (v.contains("JK") || v == "L/P" || v.contains("KELAMIN")) colJK = c;
            if (v.contains("KELAS") || v == "KLS") colKelas = c;
          }
          if (colNis != -1 && colNama != -1) break;
        }

        for (int i = 0; i < tableData.rows.length; i++) {
          var row = tableData.rows[i];
          String getVal(int idx) {
            if (idx < 0 || idx >= row.length || row[idx] == null) return "";
            String s = row[idx]!.value?.toString().trim() ?? "";
            return s.endsWith(".0") ? s.substring(0, s.length - 2) : s;
          }

          String nis = colNis != -1 ? getVal(colNis) : "";
          String nama = colNama != -1 ? getVal(colNama) : "";
          String jkRaw = colJK != -1 ? getVal(colJK).toUpperCase() : "";
          String kelas = colKelas != -1 ? getVal(colKelas).toUpperCase() : "";

          if (nis.isEmpty || nama.isEmpty || nis.contains("NIS") || nama.contains("NAMA")) continue;

          dataSiswa.add({
            "nis": nis,
            "nama": nama,
            "jk": (jkRaw.startsWith("L") || jkRaw.contains("PRIA")) ? "L" : "P",
            "kelas": kelas,
          });
        }
      }

      final response = await http.post(
        Uri.parse("http://192.168.1.5/apk_wb/apk_wb/api/import_siswa.php"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(dataSiswa),
      );

      if (mounted) Navigator.pop(context);
      _fetchSiswa();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Import Selesai!"), backgroundColor: Colors.green));

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    }
  }

  // --- Widget Build Tetap Sama ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F9),
      body: Column(
        children: [
          Stack(
            children: [
              Container(height: 160, width: double.infinity, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/imagesmp5.jpeg'), fit: BoxFit.cover))),
              Container(height: 160, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)]))),
              Positioned(top: 40, left: 10, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28))),
              Positioned(top: 50, left: 60, child: Row(children: [Image.asset('assets/images/smp5logo.png', width: 50), const SizedBox(width: 15), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("SMP NEGERI 5", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text("LUMAJANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))])])),
            ],
          ),
          Container(
            width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00F5D4), Color(0xFF00D1B2)]), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Row(children: [Icon(Icons.person, color: Colors.white), SizedBox(width: 10), Text("Kelola Siswa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]), InkWell(onTap: () {}, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Row(children: [Icon(Icons.delete_sweep, color: Colors.white, size: 18), SizedBox(width: 5), Text("Reset", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])))]),
          ),
          _buildImportSection(),
          _buildManualForm(),
          _buildTableHeader(),
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2)))
              : ListView.builder(
                  itemCount: _listSiswa.length,
                  itemBuilder: (context, i) {
                    var s = _listSiswa[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(flex: 2, child: Text(s['nis']?.toString() ?? "")),
                        Expanded(flex: 3, child: Text(s['nama_siswa']?.toString() ?? "", style: const TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Center(child: Text(s['jenis_kelamin']?.toString() ?? ""))),
                        Expanded(flex: 1, child: Center(child: Text(s['nama_kelas']?.toString() ?? ""))),
                        Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Icon(Icons.edit, color: Colors.orange), const SizedBox(width: 10), InkWell(onTap: () {}, child: const Icon(Icons.delete, color: Colors.red))])),
                      ]),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.pop(context), label: const Text("KEMBALI"), icon: const Icon(Icons.arrow_back)),
    );
  }

  Widget _buildImportSection() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.file_present, color: Color(0xFF00D1B2)), const SizedBox(width: 10), Expanded(child: Text(_fileName, style: const TextStyle(fontSize: 11, color: Colors.grey))), ElevatedButton(onPressed: _importExcel, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1B2)), child: const Text("Import Excel", style: TextStyle(color: Colors.white)))]));
  }

  Widget _buildManualForm() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [Row(children: [Expanded(child: TextField(controller: _nisController, decoration: const InputDecoration(labelText: "NIS"))), const SizedBox(width: 10), Expanded(child: TextField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama")))]), const SizedBox(height: 10), Row(children: [Expanded(child: DropdownButton<String>(hint: const Text("JK"), value: _selectedJK, items: ['Laki - Laki', 'Perempuan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedJK = v))), const SizedBox(width: 10), Expanded(child: DropdownButton<String>(hint: const Text("Kelas"), value: _selectedKelasId, items: _listKelas.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['nama_kelas'].toString()))).toList(), onChanged: (v) => setState(() => _selectedKelasId = v))), ElevatedButton(onPressed: () {}, child: const Icon(Icons.add))])]));
  }

  Widget _buildTableHeader() {
    return Container(margin: const EdgeInsets.only(top: 10, left: 15, right: 15), padding: const EdgeInsets.symmetric(vertical: 12), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(15))), child: const Row(children: [Expanded(flex: 2, child: Center(child: Text("NIS"))), Expanded(flex: 3, child: Text("NAMA")), Expanded(flex: 1, child: Center(child: Text("L/P"))), Expanded(flex: 1, child: Center(child: Text("KLS"))), Expanded(flex: 2, child: Center(child: Text("AKSI")))]));
  }
}
