<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

$nis = $_POST['nis'] ?? '';

if ($nis != "") {
    $query = "DELETE FROM siswa WHERE nis = '$nis'";
    if (mysqli_query($conn, $query)) {
        echo json_encode(["status" => "success", "message" => "Data siswa berhasil dihapus"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal menghapus data"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "NIS tidak ditemukan"]);
}
?>
