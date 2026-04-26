<?php
/**
 * API UNTUK MENGAMBIL DATA REKAPITULASI ABSENSI (ANALITIK)
 * Digunakan oleh modul laporan di aplikasi Flutter untuk menampilkan statistik dan detail kehadiran.
 */

// Menonaktifkan laporan error sistem agar tidak merusak struktur JSON
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Menghubungkan ke konfigurasi database
include 'config.php';

/**
 * MENANGKAP PARAMETER FILTER:
 * - bulan & tahun: Untuk laporan bulanan.
 * - tanggal: Untuk laporan harian spesifik.
 * - kelas: Untuk memfilter data berdasarkan kelas tertentu.
 */
$bulan   = isset($_GET['bulan']) ? (int)$_GET['bulan'] : (int)date('m');
$tahun   = isset($_GET['tahun']) ? (int)$_GET['tahun'] : (int)date('Y');
$tanggal = isset($_GET['tanggal']) ? mysqli_real_escape_string($conn, $_GET['tanggal']) : null;
$kelas   = isset($_GET['kelas']) ? mysqli_real_escape_string($conn, $_GET['kelas']) : 'Semua Kelas';

// Logika Filter Waktu: Membedakan antara pencarian harian atau bulanan
if ($tanggal && $tanggal != 'null') {
    $whereWaktu      = "a.tanggal = '$tanggal'";
    $whereWaktuSiswa = "AND a.tanggal = '$tanggal'";
} else {
    $whereWaktu      = "MONTH(a.tanggal) = $bulan AND YEAR(a.tanggal) = $tahun";
    $whereWaktuSiswa = "AND MONTH(a.tanggal) = $bulan AND YEAR(a.tanggal) = $tahun";
}

// Logika Filter Kelas: Sekarang menggunakan k.nama_kelas karena tabel siswa menyimpan kelas_id
$whereKelas = ($kelas == 'Semua Kelas' || $kelas == '') ? "" : " AND k.nama_kelas = '$kelas'";

/**
 * BAGIAN 1: PENGAMBILAN RINGKASAN (SUMMARY)
 */
$sqlSummary = "SELECT
    (SELECT COUNT(*) FROM siswa s LEFT JOIN kelas k ON s.kelas_id = k.id WHERE 1=1 $whereKelas) as total_siswa,
    (SELECT COUNT(*) FROM absensi a JOIN siswa s ON a.siswa_id = s.nis LEFT JOIN kelas k ON s.kelas_id = k.id WHERE $whereWaktu AND a.status = 'Hadir' $whereKelas) as total_hadir,
    (SELECT COUNT(*) FROM absensi a JOIN siswa s ON a.siswa_id = s.nis LEFT JOIN kelas k ON s.kelas_id = k.id WHERE $whereWaktu AND a.status = 'Sakit' $whereKelas) as total_sakit,
    (SELECT COUNT(*) FROM absensi a JOIN siswa s ON a.siswa_id = s.nis LEFT JOIN kelas k ON s.kelas_id = k.id WHERE $whereWaktu AND a.status = 'Izin' $whereKelas) as total_izin,
    (SELECT COUNT(*) FROM absensi a JOIN siswa s ON a.siswa_id = s.nis LEFT JOIN kelas k ON s.kelas_id = k.id WHERE $whereWaktu AND a.status = 'Alpha' $whereKelas) as total_alpha";

$resSummary = mysqli_query($conn, $sqlSummary);
$summary    = mysqli_fetch_assoc($resSummary);

/**
 * BAGIAN 2: PENGAMBILAN DETAIL PER SISWA
 */
$sqlDetails = "SELECT
    s.nis,
    s.nama_siswa,
    k.nama_kelas as kelas,
    SUM(CASE WHEN a.status = 'Hadir' THEN 1 ELSE 0 END) as hadir,
    SUM(CASE WHEN a.status = 'Sakit' THEN 1 ELSE 0 END) as sakit,
    SUM(CASE WHEN a.status = 'Izin' THEN 1 ELSE 0 END) as izin,
    SUM(CASE WHEN a.status = 'Alpha' THEN 1 ELSE 0 END) as alpha,
    COUNT(a.id_absensi) as total_hari
FROM siswa s
LEFT JOIN kelas k ON s.kelas_id = k.id
LEFT JOIN absensi a ON s.nis = a.siswa_id $whereWaktuSiswa
WHERE 1=1 $whereKelas
GROUP BY s.nis, s.nama_siswa, k.nama_kelas
ORDER BY k.nama_kelas ASC, s.nama_siswa ASC";

$resDetails = mysqli_query($conn, $sqlDetails);
$details    = [];

if ($resDetails) {
    while ($row = mysqli_fetch_assoc($resDetails)) {
        /**
         * PENGHITUNGAN PERSENTASE:
         * Menghitung tingkat kehadiran siswa berdasarkan total hari absen yang tercatat.
         */
        $total = (int)$row['total_hari'];
        $h     = (int)$row['hadir'];
        $row['persentase'] = ($total > 0) ? round(($h / $total) * 100, 1) : 0;
        $details[] = $row;
    }
}

// Mengirimkan hasil akhir (Summary & Details) ke Flutter dalam satu paket JSON
echo json_encode([
    "status"  => "success",
    "summary" => $summary,
    "details" => $details
]);

/**
 * PENJELASAN FUNGSI FILE GET_REKAP_ABSENSI.PHP:
 * 1. Menyediakan data analitik yang mendalam untuk keperluan pelaporan sekolah.
 * 2. Mendukung filter yang fleksibel (Harian/Bulanan/Per Kelas).
 * 3. Mengintegrasikan logika penghitungan otomatis di sisi server (Backend Calculation).
 * 4. Memastikan akurasi data dengan sinkronisasi antara tabel siswa dan tabel absensi.
 * 5. Menghasilkan output JSON terstruktur yang siap dikonversi menjadi grafik atau tabel di Flutter.
 */
?>
