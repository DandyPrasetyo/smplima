<?php
/**
 * API UNTUK MENGUPDATE DATA SISWA
 * Digunakan oleh aplikasi Flutter pada halaman Kelola Siswa.
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");

// Menghubungkan ke konfigurasi database
include 'config.php';

// Menangani request 'OPTIONS' untuk CORS (Cross-Origin Resource Sharing)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Mengambil data yang dikirimkan oleh aplikasi melalui metode POST
// Jika 'old_nis' tidak ada, kita asumsikan 'nis' adalah identitas utamanya
$nis     = $_POST['nis'] ?? '';
$old_nis = $_POST['old_nis'] ?? $nis; // Jika tidak kirim old_nis, gunakan nis saat ini
$nama    = $_POST['nama'] ?? '';
$kelas   = $_POST['kelas'] ?? '';
$jk      = $_POST['jk'] ?? '';

// Validasi: Memastikan data minimal (NIS, Nama, Kelas) sudah terisi
if ($nis != "" && $nama != "" && $kelas != "") {

    // Query SQL untuk memperbarui data siswa berdasarkan NIS lama
    // Hal ini memungkinkan jika suatu saat Admin ingin mengubah nomor NIS siswa
    $query = "UPDATE siswa SET
              nis = '$nis',
              nama_siswa = '$nama',
              kelas = '$kelas',
              jenis_kelamin = '$jk'
              WHERE nis = '$old_nis'";

    // Menjalankan query ke database
    if (mysqli_query($conn, $query)) {
        // Jika berhasil, kirim respon sukses
        echo json_encode([
            "status" => "success",
            "message" => "Data siswa $nama berhasil diperbarui"
        ]);
    } else {
        // Jika gagal (misal: NIS baru sudah dipakai siswa lain)
        echo json_encode([
            "status" => "error",
            "message" => "Gagal mengupdate data: " . mysqli_error($conn)
        ]);
    }
} else {
    // Jika ada parameter yang kosong
    echo json_encode([
        "status" => "error",
        "message" => "Data tidak lengkap (NIS, Nama, dan Kelas wajib diisi)"
    ]);
}

/**
 * PENJELASAN LOGIKA:
 * 1. Skrip ini menerima input NIS, Nama, Kelas, dan Jenis Kelamin.
 * 2. Menggunakan 'old_nis' di bagian WHERE untuk memastikan kita mengubah baris data yang tepat.
 * 3. Jika aplikasi hanya mengirim 'nis', skrip ini tetap jalan karena ada logika fallback ($old_nis = $_POST['old_nis'] ?? $nis).
 * 4. Respon dalam bentuk JSON agar mudah dibaca oleh Flutter menggunakan json.decode().
 */
?>
