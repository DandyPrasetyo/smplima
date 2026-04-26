<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: *");
header("Content-Type: application/json");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nama_kelas = isset($_POST['nama_kelas']) ? $_POST['nama_kelas'] : '';

    if (empty($nama_kelas)) {
        echo json_encode(["status" => "error", "message" => "Nama kelas tidak boleh kosong"]);
        exit;
  }

    // Menggunakan kolom 'id' sesuai dengan screenshot database Anda
    $cek = mysqli_query($conn, "SELECT id FROM kelas WHERE nama_kelas = '$nama_kelas'");
    if ($cek && mysqli_num_rows($cek) > 0) {
        echo json_encode(["status" => "error", "message" => "Kelas sudah ada!"]);
    } else {
        $query = mysqli_query($conn, "INSERT INTO kelas (nama_kelas) VALUES ('$nama_kelas')");
        if ($query) {
            echo json_encode(["status" => "success", "message" => "Kelas berhasil ditambahkan"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Gagal menyimpan: " . mysqli_error($conn)]);
        }
    }
}
?>
