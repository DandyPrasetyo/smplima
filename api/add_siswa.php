<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

$nis   = $_POST['nis'] ?? '';
$nama  = $_POST['nama'] ?? '';
$kelas_id = $_POST['kelas_id'] ?? '';
$jk    = $_POST['jk'] ?? ''; // 'L' atau 'P'

if ($nis != "" && $nama != "" && $kelas_id != "" && $jk != "") {
    // Cek apakah NIS sudah ada
    $check = mysqli_query($conn, "SELECT * FROM siswa WHERE nis = '$nis'");
    if (mysqli_num_rows($check) > 0) {
        echo json_encode(["status" => "error", "message" => "NIS sudah terdaftar"]);
    } else {
        $query = "INSERT INTO siswa (nis, nama_siswa, kelas_id, jenis_kelamin) VALUES ('$nis', '$nama', '$kelas_id', '$jk')";
        if (mysqli_query($conn, $query)) {
            echo json_encode(["status" => "success", "message" => "Siswa berhasil ditambahkan"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menambahkan siswa"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Harap isi semua kolom"]);
}
?>
