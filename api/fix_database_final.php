<?php
include 'config.php';

// 1. Pastikan tabel kelas punya kolom 'id'
$sql1 = "ALTER TABLE kelas CHANGE COLUMN id_kelas id INT AUTO_INCREMENT";
mysqli_query($conn, $sql1);

// 2. Pastikan tabel siswa punya kolom 'kelas_id' (bukan 'kelas' teks)
$sql2 = "ALTER TABLE siswa CHANGE COLUMN kelas kelas_id INT";
mysqli_query($conn, $sql2);

echo json_encode(["status" => "Database has been synchronized!"]);
?>
