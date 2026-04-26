import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class RekapAbsensiPage extends StatefulWidget {
  const RekapAbsensiPage({super.key});

  @override
  State<RekapAbsensiPage> createState() => _RekapAbsensiPageState();
}

class _RekapAbsensiPageState extends State<RekapAbsensiPage> {
  String _selectedBulan = DateFormat('MM').format(DateTime.now());
  String _selectedTahun = DateTime.now().year.toString();
  DateTime? _selectedTanggal; 
  String _selectedKelas = "Semua Kelas";

  Map _summary = {"total_siswa": 0, "total_hadir": 0, "total_sakit": 0, "total_izin": 0, "total_alpha": 0};
  Map<String, List> _allGroupedRekap = {}; 
  Map<String, List> _filteredGroupedRekap = {}; 
  bool _loading = false;
  final TextEditingController _searchController = TextEditingController();

  final String baseUrl = "http://192.168.1.5/apk_wb/apk_wb/api";
  final List<String> _tahunList = ["2024", "2025", "2026", "2027"];
  
  final List<String> _kelasList = [
    "Semua Kelas", "7A", "7B", "7C", "7D", "7E", "7F", "7G", 
    "8A", "8B", "8C", "8D", "8E", "8F", "8G", 
    "9A", "9B", "9C", "9D", "9E", "9F", "9G"
  ];
  
  final List<Map<String, String>> _bulanList = [
    {"id": "01", "nama": "Januari"}, {"id": "02", "nama": "Februari"}, {"id": "03", "nama": "Maret"},
    {"id": "04", "nama": "April"}, {"id": "05", "nama": "Mei"}, {"id": "06", "nama": "Juni"},
    {"id": "07", "nama": "Juli"}, {"id": "08", "nama": "Agustus"}, {"id": "09", "nama": "September"},
    {"id": "10", "nama": "Oktober"}, {"id": "11", "nama": "November"}, {"id": "12", "nama": "Desember"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRekap();
  }

  Future<void> _fetchRekap() async {
    setState(() => _loading = true);
    try {
      String url = "$baseUrl/get_rekap_absensi.php?kelas=$_selectedKelas";
      if (_selectedTanggal != null) {
        url += "&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedTanggal!)}";
      } else {
        url += "&bulan=$_selectedBulan&tahun=$_selectedTahun";
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List details = data['details'] ?? [];
        Map<String, List> tempGrouped = {};
        for (var item in details) {
          String kls = (item['kelas'] ?? _selectedKelas).toString();
          if (kls == "Semua Kelas" || kls == "") kls = "Tanpa Kelas";
          if (!tempGrouped.containsKey(kls)) tempGrouped[kls] = [];
          tempGrouped[kls]!.add(item);
        }
        setState(() {
          _summary = data['summary'] ?? {};
          _allGroupedRekap = tempGrouped;
          _filterData(_searchController.text);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _loading = false);
    }
  }

  void _filterData(String query) {
    if (query.isEmpty) {
      setState(() { _filteredGroupedRekap = Map.from(_allGroupedRekap); });
      return;
    }
    Map<String, List> tempFiltered = {};
    _allGroupedRekap.forEach((kelas, siswaList) {
      List filteredSiswa = siswaList.where((siswa) {
        String nama = (siswa['nama_siswa'] ?? "").toString().toLowerCase();
        return nama.contains(query.toLowerCase());
      }).toList();
      if (filteredSiswa.isNotEmpty) tempFiltered[kelas] = filteredSiswa;
    });
    setState(() { _filteredGroupedRekap = tempFiltered; });
  }

  Future<void> _generatePDF({required bool isPrint}) async {
    try {
      final pdf = pw.Document();
      final bulanNama = _bulanList.firstWhere((e) => e['id'] == _selectedBulan, orElse: () => {"nama": "Laporan"})['nama'];
      final String periode = _selectedTanggal != null ? DateFormat('dd MMM yyyy').format(_selectedTanggal!) : "$bulanNama $_selectedTahun";

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          
          // Header Laporan
          widgets.add(pw.Text("REKAP ABSENSI SMPN 5 LUMAJANG", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
          widgets.add(pw.Text("Periode: $periode", style: const pw.TextStyle(fontSize: 14)));
          widgets.add(pw.SizedBox(height: 10));
          widgets.add(pw.Divider());
          widgets.add(pw.SizedBox(height: 10));

          // Looping data per kelas secara flat agar tidak terjadi TooManyPagesException
          _filteredGroupedRekap.forEach((kelas, siswaList) {
            widgets.add(pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Text("KELAS: $kelas", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            ));

            widgets.add(pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headers: ['Nama', 'H', 'S', 'I', 'A', '%'],
              data: siswaList.map((r) => [
                r['nama_siswa'] ?? "-",
                r['hadir'] ?? "0",
                r['sakit'] ?? "0",
                r['izin'] ?? "0",
                r['alpha'] ?? "0",
                "${r['persentase']}%"
              ]).toList(),
              border: pw.TableBorder.all(width: 0.5),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {0: pw.Alignment.centerLeft},
            ));
            
            widgets.add(pw.SizedBox(height: 15));
          });

          // --- BAGIAN TOTAL DAN TANDA TANGAN ---
          widgets.add(pw.SizedBox(height: 20));
          widgets.add(pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sebelah Kiri: Ringkasan
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Ringkasan Total Seluruhnya:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text("Total Hadir : ${_summary['total_hadir']}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("Total Sakit : ${_summary['total_sakit']}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("Total Izin  : ${_summary['total_izin']}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("Total Alpha : ${_summary['total_alpha']}", style: const pw.TextStyle(fontSize: 10)),
                ]
              ),
              // Sebelah Kanan: Tanda Tangan
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Lumajang, ${DateFormat('dd MMMM yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text("Guru Wali Kelas,", style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 50),
                  pw.Container(
                    width: 120, 
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(width: 1))
                    )
                  ),
                  pw.Text("NIP. ...........................", style: const pw.TextStyle(fontSize: 10)),
                ]
              )
            ]
          ));

          return widgets;
        }
      ));

      final bytes = await pdf.save();

      if (isPrint) {
        await Printing.layoutPdf(onLayout: (format) async => bytes);
      } else {
        // --- LOGIKA SIMPAN KE HP ---
        final directory = await getExternalStorageDirectory(); // Mengarah ke folder data aplikasi di storage
        final downloadDir = Directory('/storage/emulated/0/Download'); // Standar folder Download Android
        
        String fileName = "Rekap_Absensi_${periode.replaceAll(' ', '_')}.pdf";
        File file;

        if (await downloadDir.exists()) {
          file = File("${downloadDir.path}/$fileName");
        } else {
          file = File("${directory!.path}/$fileName");
        }

        await file.writeAsBytes(bytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("PDF Berhasil disimpan di: ${file.path}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: "BUKA", textColor: Colors.white, onPressed: () => Printing.sharePdf(bytes: bytes, filename: fileName)),
          ));
        }
      }
    } catch (e) {
      debugPrint("Gagal Simpan PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9F9),
      appBar: AppBar(
        title: const Text("Rekap Absensi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00D1B2), // WARNA BARU CYAN
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(onPressed: _showDownloadOptions, icon: const Icon(Icons.picture_as_pdf, color: Colors.white))],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D1B2), // WARNA BARU CYAN
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController, onChanged: _filterData,
                        decoration: InputDecoration(
                          hintText: "Cari Nama Siswa...", prefixIcon: const Icon(Icons.search, color: Color(0xFF00D1B2)),
                          fillColor: Colors.white, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildFilterBox(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                            value: _selectedKelas, isExpanded: true, dropdownColor: const Color(0xFF00D1B2), icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 13), items: _kelasList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                            onChanged: (v) { setState(() { _selectedKelas = v!; }); _fetchRekap(); },
                          )))),
                          const SizedBox(width: 8),
                          Expanded(child: InkWell(onTap: () async {
                            DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
                            if (picked != null) { setState(() { _selectedTanggal = picked; }); _fetchRekap(); }
                          }, child: _buildFilterBox(child: Row(children: [
                            const Icon(Icons.calendar_month, color: Colors.white, size: 16), const SizedBox(width: 8),
                            Expanded(child: Text(_selectedTanggal == null ? "Semua Tanggal" : DateFormat('dd/MM/yy').format(_selectedTanggal!), style: const TextStyle(color: Colors.white, fontSize: 12))),
                          ])))),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _topStat(_summary['total_siswa'].toString(), "Siswa"),
                          _topStat(_summary['total_hadir'].toString(), "Hadir"),
                          _topStat(_summary['total_sakit'].toString(), "Sakit"),
                          _topStat(_summary['total_izin'].toString(), "Izin"),
                          _topStat(_summary['total_alpha'].toString(), "Alpha"),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D1B2)))
                    : _filteredGroupedRekap.isEmpty 
                      ? const Center(child: Text("Data tidak ditemukan"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(15),
                          itemCount: _filteredGroupedRekap.length,
                          itemBuilder: (context, index) {
                            String kls = _filteredGroupedRekap.keys.elementAt(index);
                            return _buildKelasCard(kls, _filteredGroupedRekap[kls]!);
                          },
                        ),
                ),
              ],
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

  Widget _buildFilterBox({required Widget child}) => Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)), child: Center(child: child));

  Widget _buildKelasCard(String namaKelas, List siswaList) => Card(
    margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFF0F9F9), borderRadius: BorderRadius.vertical(top: Radius.circular(15))), child: Row(children: [Text("Kelas $namaKelas", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D1B2))), const Spacer(), Text("${siswaList.length} Siswa", style: const TextStyle(fontSize: 12, color: Colors.grey))])),
      Padding(padding: const EdgeInsets.all(10), child: Table(children: [
        const TableRow(children: [Text("Nama", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text("H", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)), Text("S", textAlign: TextAlign.center), Text("I", textAlign: TextAlign.center), Text("A", textAlign: TextAlign.center), Text("%", textAlign: TextAlign.center)]),
        ...siswaList.map((s) => TableRow(children: [Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(s['nama_siswa'] ?? "-", style: const TextStyle(fontSize: 11))), Text(s['hadir'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), Text(s['sakit'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), Text(s['izin'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), Text(s['alpha'].toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)), Text("${s['persentase']}%", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue))])).toList()
      ]))
    ])
  );

  Widget _topStat(String v, String l) => Column(children: [Text(v, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(color: Colors.white70, fontSize: 9))]);

  void _showDownloadOptions() {
    showModalBottomSheet(context: context, builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.print, color: Colors.blue), title: const Text("Cetak"), onTap: () { Navigator.pop(context); _generatePDF(isPrint: true); }),
      ListTile(leading: const Icon(Icons.download, color: Colors.green), title: const Text("Download PDF"), onTap: () { Navigator.pop(context); _generatePDF(isPrint: false); }),
    ]));
  }
}
