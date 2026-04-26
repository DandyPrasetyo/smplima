<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

$query = "DELETE FROM siswa";

if (mysqli_query($conn, $query)) {
    echo json_encode(["status" => "success", "message" => "Semua data siswa berhasil dihapus"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus data: " . mysqli_error($conn)]);
}
?>
