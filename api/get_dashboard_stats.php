<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

// Pastikan tabel sesuai dengan database data_baru
$qKelas = mysqli_query($conn, "SELECT COUNT(*) as total FROM kelas");
$totalKelas = ($qKelas) ? mysqli_fetch_assoc($qKelas)['total'] : 0;

$qSiswa = mysqli_query($conn, "SELECT COUNT(*) as total FROM siswa");
$totalSiswa = ($qSiswa) ? mysqli_fetch_assoc($qSiswa)['total'] : 0;

$hari_ini = date('Y-m-d');
$qAbsen = mysqli_query($conn, "SELECT COUNT(*) as total FROM absensi WHERE tanggal = '$hari_ini'");
$totalAbsensi = ($qAbsen) ? mysqli_fetch_assoc($qAbsen)['total'] : 0;

echo json_encode([
    "total_kelas" => $totalKelas,
    "total_siswa" => $totalSiswa,
    "total_absensi" => $totalAbsensi
]);
?>
