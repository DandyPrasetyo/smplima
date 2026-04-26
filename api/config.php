<?php
// Izinkan semua domain (penting untuk Flutter Web)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "data_baru";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Koneksi DB Gagal"]);
    exit();
}
?>
