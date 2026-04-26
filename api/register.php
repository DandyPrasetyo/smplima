<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include 'config.php';

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { exit; }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $nama     = isset($_POST['nama']) ? mysqli_real_escape_string($conn, $_POST['nama']) : '';
    $username = isset($_POST['username']) ? mysqli_real_escape_string($conn, $_POST['username']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    // Konversi Role ke Lowercase agar cocok dengan ENUM ('admin', 'guru', 'petugas')
    $role_input = isset($_POST['role']) ? $_POST['role'] : 'guru';
    $role = strtolower(mysqli_real_escape_string($conn, $role_input));

    if (empty($username) || empty($password) || empty($nama)) {
        echo json_encode(["status" => "error", "message" => "Harap isi semua kolom!"]);
        exit;
    }

    $cek = mysqli_query($conn, "SELECT id FROM users WHERE username = '$username'");
    if (mysqli_num_rows($cek) > 0) {
        echo json_encode(["status" => "error", "message" => "Username sudah terdaftar!"]);
        exit;
    }

    // Gunakan password_hash agar sinkron dengan login.php
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);

    $query = "INSERT INTO users (username, password, nama_lengkap, role)
              VALUES ('$username', '$hashed_password', '$nama', '$role')";

    if (mysqli_query($conn, $query)) {
        echo json_encode(["status" => "success", "message" => "Pendaftaran Berhasil!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Gagal Database: " . mysqli_error($conn)]);
    }
}
?>
