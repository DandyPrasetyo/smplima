<?php
/**
 * API UNTUK MENGINPUT ATAU MEMPERBARUI STATUS ABSENSI
 * Digunakan oleh Petugas (harian) maupun Admin (pengubahan riwayat).
 */

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");

// Menghubungkan ke database melalui file konfigurasi
include 'config.php';

// Menangkap data yang dikirim oleh aplikasi Flutter (Metode POST)
// Mendukung parameter 'siswa_id' atau 'nis' untuk fleksibilitas kode
$id_siswa = $_POST['siswa_id'] ?? $_POST['nis'] ?? '';
$tgl      = $_POST['tanggal'] ?? '';
$st       = $_POST['status'] ?? '';

// Validasi: Memastikan ID Siswa, Tanggal, dan Status sudah terisi
if ($id_siswa != "" && $tgl != "" && $st != "") {

    /**
     * LOGIKA 'ON DUPLICATE KEY UPDATE':
     * 1. Mencoba memasukkan data absensi baru (INSERT).
     * 2. Jika ternyata siswa tersebut sudah diabsen pada tanggal yang sama (duplikat),
     *    maka statusnya akan diperbarui (UPDATE) saja tanpa menambah baris baru.
     * 3. Hal ini dimungkinkan karena di database kolom 'siswa_id' dan 'tanggal' dijadikan UNIQUE KEY.
     */
    $query = "INSERT INTO absensi (siswa_id, tanggal, status)
              VALUES ('$id_siswa', '$tgl', '$st')
              ON DUPLICATE KEY UPDATE status = '$st'";

    // Menjalankan query ke database
    if (mysqli_query($conn, $query)) {
        echo json_encode([
            "status" => "success",
            "message" => "Absensi berhasil disimpan untuk Siswa ID: $id_siswa"
        ]);
    } else {
        // Jika terjadi kesalahan pada server (internal error)
        http_response_code(500);
        echo json_encode([
            "status" => "error",
            "message" => "Kesalahan Database: " . mysqli_error($conn)
        ]);
    }
} else {
    // Jika ada parameter yang tidak dikirim oleh aplikasi
    http_response_code(400);
    echo json_encode([
        "status" => "error",
        "message" => "Parameter tidak lengkap (Siswa ID, Tanggal, dan Status wajib ada)"
    ]);
}

/**
 * PENJELASAN FUNGSI API:
 * 1. Menerima input dari Flutter berupa NIS siswa, tanggal absen, dan status (Hadir/Sakit/Izin/Alpha).
 * 2. Menggunakan query cerdas 'ON DUPLICATE KEY UPDATE' untuk efisiensi penyimpanan data.
 * 3. Mengirimkan status kode HTTP 200 jika sukses, 400 jika input kurang, dan 500 jika server bermasalah.
 * 4. Mendukung operasional absensi masal yang dilakukan oleh petugas di lapangan.
 */
?>
