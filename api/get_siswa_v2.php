<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

// Gunakan LEFT JOIN agar siswa tetap muncul meskipun kelasnya terhapus (opsional)
// Kita ambil nama_kelas dari tabel kelas berdasarkan kelas_id
$query = "SELECT s.nis, s.nama_siswa, s.jenis_kelamin, k.nama_kelas as kelas, s.kelas_id
          FROM siswa s
          LEFT JOIN kelas k ON s.kelas_id = k.id
          ORDER BY k.nama_kelas ASC, s.nama_siswa ASC";

$result = mysqli_query($conn, $query);
$data = [];

if ($result) {
    while($row = mysqli_fetch_assoc($result)){
        $data[] = $row;
    }
}

echo json_encode($data);
?>
