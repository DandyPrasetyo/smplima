<?php
/**
 * API UNTUK MENGAMBIL DAFTAR SISWA BERDASARKAN KELAS
 * Digunakan oleh Petugas/Admin saat memilih kelas tertentu untuk memulai absensi.
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Menghubungkan ke konfigurasi database
include 'config.php';

/**
 * MENANGKAP PARAMETER KELAS:
 * Mengambil nama kelas dari URL (metode GET).
 * Contoh pemanggilan: get_siswa_by_kelas.php?kelas=7A
 */
$kelas_nama = isset($_GET['kelas']) ? trim($_GET['kelas']) : '';

// Jika parameter kelas tidak diberikan, kirim array kosong dan hentikan proses
if ($kelas_nama == '') {
    echo json_encode([]);
    exit;
}

/**
 * QUERY PENGAMBILAN DATA:
 * Mengambil NIS dan Nama Siswa yang terdaftar di kelas yang dipilih.
 * Menggunakan JOIN karena sekarang filter berdasarkan nama_kelas tapi relasi pakai kelas_id.
 */
$sql = "SELECT s.nis, s.nama_siswa
        FROM siswa s
        JOIN kelas k ON s.kelas_id = k.id
        WHERE k.nama_kelas = '$kelas_nama'
        ORDER BY s.nama_siswa ASC";
$result = mysqli_query($conn, $sql);

$siswa = [];

// Mengecek apakah query berhasil dan ada datanya
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        // Memasukkan setiap baris data siswa ke dalam array
        $siswa[] = $row;
    }
}

/**
 * Mengembalikan data dalam format JSON.
 * Jika tidak ada siswa di kelas tersebut, akan mengembalikan array kosong [].
 */
echo json_encode($siswa);

/**
 * PENJELASAN FUNGSI FILE GET_SISWA_BY_KELAS.PHP:
 * 1. Berperan sebagai filter data siswa agar petugas hanya melihat siswa di kelas yang sedang diurus.
 * 2. Menggunakan fungsi trim() untuk memastikan tidak ada spasi liar yang merusak pencarian data.
 * 3. Memberikan respon cepat berupa daftar identitas minimal (NIS dan Nama) untuk efisiensi bandwidth.
 * 4. Mendukung alur kerja absensi harian yang efisien dan terarah.
 */
?>
