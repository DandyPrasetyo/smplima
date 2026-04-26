<?php

/**
 * API UNTUK MENGAMBIL DAFTAR KELAS BESERTA STATISTIKNYA
 * Digunakan oleh aplikasi Flutter untuk menampilkan daftar kelas pada modul Kelola Kelas.
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Menghubungkan ke konfigurasi database
include 'config.php';

/**
 * QUERY PENGAMBILAN DATA:
 * 1. Mengambil 'nama_kelas' dari tabel 'kelas'.
 * 2. Menghitung jumlah siswa di setiap kelas tersebut menggunakan COUNT(s.nis).
 * 3. Menggunakan 'LEFT JOIN' agar kelas yang masih kosong (belum ada siswanya) tetap muncul dalam daftar.
 * 4. Mengelompokkan data (GROUP BY) berdasarkan nama kelas.
 */
$query = "SELECT k.nama_kelas, COUNT(s.nis) as jumlah_siswa
          FROM kelas k
          LEFT JOIN siswa s ON k.id = s.kelas_id
          GROUP BY k.id, k.nama_kelas";

$result = mysqli_query($conn, $query);
$data = [];

// Memindahkan hasil query ke dalam array $data
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

/**
 * Mengirimkan data dalam format JSON ke aplikasi Flutter.
 * Output berupa list objek yang berisi nama kelas dan jumlah siswa di dalamnya.
 */
echo json_encode($data);

/**
 * PENJELASAN FUNGSI FILE GET_KELAS.PHP:
 * 1. Berfungsi sebagai sumber data utama untuk halaman manajemen kelas di sisi Admin.
 * 2. Memberikan informasi "Live Count" jumlah siswa per kelas tanpa perlu membuka detail siswa.
 * 3. Menjamin data kelas yang baru dibuat (dan belum ada siswanya) tetap terbaca berkat logika LEFT JOIN.
 * 4. Menyediakan data yang efisien dan siap pakai bagi antarmuka pengguna di Flutter.
 */
?>
