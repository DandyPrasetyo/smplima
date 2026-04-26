<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include 'config.php';

$query = mysqli_query($conn, "SELECT nis, nama_siswa, kelas FROM siswa ORDER BY kelas, nama_siswa ASC");
$siswa = [];

while ($row = mysqli_fetch_assoc($query)) {
    $siswa[] = [
        "id" => $row['nis'], // nis digunakan sebagai ID unik
        "nama" => $row['nama_siswa'],
        "kelas" => $row['kelas']
    ];
}

echo json_encode([
    "status" => count($siswa) > 0 ? "success" : "error",
    "data" => $siswa,
    "message" => count($siswa) > 0 ? "" : "Data siswa kosong"
]);
?>
