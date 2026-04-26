<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

$data = json_decode(file_get_contents("php://input"), true);
if (!$data) { echo json_encode(["status" => "error", "message" => "Data kosong"]); exit; }

$success = 0;
foreach ($data as $row) {
    $nis   = mysqli_real_escape_string($conn, $row['nis']);
    $nama  = mysqli_real_escape_string($conn, $row['nama']);
    $jk    = mysqli_real_escape_string($conn, $row['jk']);
    $kelas = mysqli_real_escape_string($conn, $row['kelas']);

    if(empty($nis) || empty($nama)) continue;

    // SINKRONISASI RELASI: Pastikan kelas ada di tabel 'kelas' agar tidak melanggar Foreign Key
    mysqli_query($conn, "INSERT IGNORE INTO kelas (nama_kelas) VALUES ('$kelas')");

    // Simpan data siswa (Gunakan nama_siswa dan jenis_kelamin sesuai struktur data_baru)
    $sql = "INSERT INTO siswa (nis, nama_siswa, jenis_kelamin, kelas)
            VALUES ('$nis', '$nama', '$jk', '$kelas')
            ON DUPLICATE KEY UPDATE nama_siswa='$nama', jenis_kelamin='$jk', kelas='$kelas'";

    if(mysqli_query($conn, $sql)) $success++;
}
echo json_encode(["status" => "success", "message" => "$success data berhasil disinkronkan."]);
?>
