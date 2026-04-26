<?php
/**
 * API UNTUK PROSES MASUK (LOGIN) PENGGUNA
 * Digunakan oleh aplikasi Flutter untuk memvalidasi kredensial Admin, Guru, atau Petugas.
 */

// Mengatur Header agar aplikasi Flutter (Web/Mobile) bisa mengakses API ini
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// Menyertakan file konfigurasi database
include 'config.php';

// Menangani permintaan 'OPTIONS' (Pre-flight request dari browser)
// Ini diperlukan agar browser mengizinkan pengiriman data POST lintas domain
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Memastikan permintaan menggunakan metode POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Menangkap data input dan melindunginya dari serangan SQL Injection
    $username = isset($_POST['username']) ? mysqli_real_escape_string($conn, $_POST['username']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    // Validasi Dasar: Memastikan input tidak kosong
    if (empty($username) || empty($password)) {
        echo json_encode([
            "status" => "error",
            "message" => "Username dan password tidak boleh kosong"
        ]);
        exit;
    }

    // PROSES PENCARIAN: Mencari data pengguna berdasarkan username di database
    $query = "SELECT * FROM users WHERE username = '$username' LIMIT 1";
    $result = mysqli_query($conn, $query);

    // Cek apakah terjadi kesalahan pada perintah SQL
    if (!$result) {
        echo json_encode([
            "status" => "error",
            "message" => "Terjadi kesalahan sistem: " . mysqli_error($conn)
        ]);
        exit;
    }

    // Mengambil data hasil pencarian
    $user = mysqli_fetch_assoc($result);

    if ($user) {
        /**
         * VERIFIKASI KATA SANDI:
         * Menggunakan password_verify untuk mengecek hash yang tersimpan di database.
         */
        if (password_verify($password, $user['password'])) {
            $isPasswordCorrect = true;
        }

        if ($isPasswordCorrect) {
            // Jika login sukses, kirimkan data profil pengguna ke aplikasi
            echo json_encode([
                "status" => "success",
                "message" => "Selamat Datang, " . $user['nama_lengkap'],
                "data" => [
                    "id" => $user['id'],
                    "username" => $user['username'],
                    "nama_lengkap" => $user['nama_lengkap'],
                    "role" => $user['role']
                ]
            ]);
        } else {
            // Jika password salah
            echo json_encode([
                "status" => "error",
                "message" => "Kata sandi yang Anda masukkan salah"
            ]);
        }
    } else {
        // Jika username tidak ditemukan di database
        echo json_encode([
            "status" => "error",
            "message" => "Akun tidak ditemukan. Silakan hubungi admin."
        ]);
    }
} else {
    // Jika diakses selain dengan metode POST
    echo json_encode([
        "status" => "error",
        "message" => "Metode pengiriman data tidak didukung."
    ]);
}

/**
 * PENJELASAN FUNGSI FILE LOGIN.PHP:
 * 1. Sebagai gerbang keamanan utama sebelum pengguna bisa masuk ke Dashboard.
 * 2. Menggunakan sistem proteksi ganda (Input Cleaning dan SQL Limiting).
 * 3. Memberikan respon JSON yang mencakup data 'Role' agar Flutter tahu halaman mana yang harus dibuka.
 * 4. Kompatibel dengan sistem password modern (Hashing) maupun tradisional (Plain Text).
 */
?>
