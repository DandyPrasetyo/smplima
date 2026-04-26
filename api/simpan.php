<?php
/**
 * API UNTUK MENYIMPAN DATA ABSENSI MASAL (BULK SAVE)
 * Skrip ini menerima daftar status absensi dalam bentuk array/list.
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Menghubungkan ke file konfigurasi database
include 'config.php';

// Menangani permintaan 'OPTIONS' (Pre-flight request untuk CORS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Menentukan tanggal absensi: Ambil dari input POST, jika tidak ada gunakan tanggal hari ini
$tanggal = isset($_POST['tanggal']) ? $_POST['tanggal'] : date('Y-m-d');

// Mengambil data status absensi (diharapkan dalam bentuk array: [id_siswa => status])
$status_data = isset($_POST['status']) ? $_POST['status'] : [];

// Validasi: Pastikan ada data yang dikirim sebelum memproses database
if (empty($status_data)) {
    echo json_encode([
        "status" => "error",
        "message" => "Gagal menyimpan: Tidak ada data status yang dikirim."
    ]);
    exit;
}

$success = true; // Penanda apakah semua data berhasil disimpan

// Melakukan perulangan (Loop) untuk menyimpan setiap status siswa satu per satu
foreach($status_data as $id => $status){
    // Membersihkan input untuk mencegah SQL Injection (Keamanan)
    $id = mysqli_real_escape_string($conn, $id);
    $status = mysqli_real_escape_string($conn, $status);

    /**
     * LOGIKA 'ON DUPLICATE KEY UPDATE':
     * - Jika data (siswa_id & tanggal) belum ada, maka akan dibuat baris baru (INSERT).
     * - Jika data sudah ada, maka status kehadirannya akan diperbarui (UPDATE).
     */
    $q = "INSERT INTO absensi (siswa_id, tanggal, status)
          VALUES ('$id', '$tanggal', '$status')
          ON DUPLICATE KEY UPDATE status='$status'";

    // Menjalankan query dan mengecek keberhasilannya
    if (!mysqli_query($conn, $q)) {
        $success = false;
    }
}

// Memberikan respon akhir ke aplikasi Flutter
if ($success) {
    echo json_encode([
        "status" => "success",
        "message" => "Seluruh data absensi berhasil disimpan ke database."
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Terjadi kesalahan saat menyimpan beberapa data. Silakan periksa koneksi."
    ]);
}

/**
 * PENJELASAN FUNGSI FILE SIMPAN.PHP:
 * 1. Menerima kiriman data absensi dalam jumlah banyak sekaligus (Bulk Data).
 * 2. Menggunakan perulangan (foreach) untuk memastikan setiap siswa dalam list terproses dengan benar.
 * 3. Menjamin integritas data dengan fitur ON DUPLICATE KEY UPDATE agar tidak ada duplikasi baris pada tanggal yang sama.
 * 4. Sangat berguna untuk sinkronisasi data dari aplikasi ke server setelah petugas selesai melakukan absen satu kelas.
 */
?>
