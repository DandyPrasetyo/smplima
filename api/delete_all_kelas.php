<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

// Menghapus semua data kelas.
// Karena ada Foreign Key di tabel siswa, pastikan ON DELETE CASCADE aktif atau hapus siswa dulu.
$query = "DELETE FROM kelas";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success", "message" => "Semua kelas berhasil dihapus."]);
} else {
    echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
}
?>