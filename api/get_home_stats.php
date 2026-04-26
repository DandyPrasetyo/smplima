<?php
/**
 * API UNTUK MENGAMBIL STATISTIK REAL-TIME DI HALAMAN HOME
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'config.php';

// Hitung Total Siswa
$qSiswa = mysqli_query($conn, "SELECT COUNT(*) as total FROM siswa");
$rSiswa = mysqli_fetch_assoc($qSiswa);

// Hitung Total Petugas (User dengan role 'PETUGAS')
$qPetugas = mysqli_query($conn, "SELECT COUNT(*) as total FROM users WHERE role = 'PETUGAS'");
$rPetugas = mysqli_fetch_assoc($qPetugas);

// Hitung Total Admin (User dengan role 'ADMIN / GURU')
$qAdmin = mysqli_query($conn, "SELECT COUNT(*) as total FROM users WHERE role = 'ADMIN / GURU'");
$rAdmin = mysqli_fetch_assoc($qAdmin);

// Hitung Total Kelas (Berdasarkan jumlah kelas unik di tabel siswa)
$qKelas = mysqli_query($conn, "SELECT COUNT(DISTINCT kelas) as total FROM siswa");
$rKelas = mysqli_fetch_assoc($qKelas);

echo json_encode([
    "status" => "success",
    "data" => [
        "siswa" => $rSiswa['total'] ?? 0,
        "petugas" => $rPetugas['total'] ?? 0,
        "admin" => $rAdmin['total'] ?? 0,
        "kelas" => $rKelas['total'] ?? 0
    ]
]);
?>
