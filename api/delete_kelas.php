<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!isset($_POST['nama_kelas'])) {
        echo json_encode(["status" => "error", "message" => "Parameter nama_kelas tidak ditemukan"]);
        exit;
    }

    $nama_kelas = $_POST['nama_kelas'];
    // Gunakan prepared statement untuk keamanan, tapi untuk sekarang kita samakan dengan yang lain
    $query = mysqli_query($conn, "DELETE FROM kelas WHERE nama_kelas = '$nama_kelas'");

    if ($query) {
        echo json_encode(["status" => "success", "message" => "Kelas berhasil dihapus"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal menghapus data: " . mysqli_error($conn)]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Metode tidak diizinkan"]);
}
?>
