<?php
/**
 * API UNTUK MEMPERBARUI NAMA KELAS
 * Digunakan oleh Admin untuk mengubah label kelas (misal: 7A menjadi 7A-Unggulan)
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");

// Menghubungkan ke database
include 'config.php';

// Memastikan request yang masuk menggunakan metode POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Validasi: Memastikan parameter nama lama dan nama baru sudah dikirim
    if (!isset($_POST['old_nama_kelas']) || !isset($_POST['new_nama_kelas'])) {
        echo json_encode(["status" => "error", "message" => "Parameter tidak lengkap"]);
        exit;
    }

    $old_nama_kelas = $_POST['old_nama_kelas'];
    $new_nama_kelas = $_POST['new_nama_kelas'];

    // Validasi: Nama kelas baru tidak boleh kosong
    if (empty($new_nama_kelas)) {
        echo json_encode(["status" => "error", "message" => "Nama kelas baru tidak boleh kosong"]);
        exit;
    }

    // PROSES 1: Update nama kelas di tabel 'kelas'
    $query = mysqli_query($conn, "UPDATE kelas SET nama_kelas = '$new_nama_kelas' WHERE nama_kelas = '$old_nama_kelas'");

    if ($query) {
        // PROSES 2 (Cascading): Jika nama kelas berubah, kita juga harus mengupdate
        // kolom 'kelas' di tabel 'siswa' agar data siswa tidak hilang atau salah kelas.
        mysqli_query($conn, "UPDATE siswa SET kelas = '$new_nama_kelas' WHERE kelas = '$old_nama_kelas'");

        echo json_encode(["status" => "success", "message" => "Kelas berhasil diperbarui"]);
    } else {
        // Jika terjadi kesalahan pada query (misal: nama kelas baru sudah ada)
        echo json_encode(["status" => "error", "message" => "Gagal memperbarui data: " . mysqli_error($conn)]);
    }
} else {
    // Jika diakses selain dengan metode POST
    echo json_encode(["status" => "error", "message" => "Metode tidak diizinkan"]);
}

/**
 * PENJELASAN LOGIKA:
 * 1. Skrip ini menerima dua input utama: Nama Kelas Lama dan Nama Kelas Baru.
 * 2. Update dilakukan pada tabel 'kelas' terlebih dahulu.
 * 3. Terdapat logika Sinkronisasi Otomatis: Karena tabel siswa menggunakan nama kelas sebagai referensi,
 *    maka jika nama kelas diubah, data kelas pada tabel siswa juga wajib diubah (Update Cascade).
 * 4. Respon JSON dikirim kembali ke Flutter untuk memberikan notifikasi visual kepada user.
 */
?>
