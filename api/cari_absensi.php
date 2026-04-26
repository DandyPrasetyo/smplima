<?php
include 'config.php';

header('Content-Type: application/json');
error_reporting(0);

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $nama  = isset($_GET['nama']) ? $_GET['nama'] : '';
    $kelas = isset($_GET['kelas']) ? $_GET['kelas'] : '';
    $tgl   = isset($_GET['tanggal']) ? $_GET['tanggal'] : date('Y-m-d'); // Format: YYYY-MM-DD

    if (empty($nama) || empty($kelas)) {
        echo json_encode(["status" => "error", "message" => "Nama dan Kelas harus diisi."]);
        exit;
    }

    // Query untuk mencari siswa berdasarkan Nama dan Kelas saja
    $query = "SELECT s.nama_siswa, s.nis, s.kelas, a.status, a.tanggal
              FROM siswa s
              LEFT JOIN absensi a ON s.nis = a.siswa_id AND a.tanggal = '$tgl'
              WHERE s.kelas = '$kelas'
              AND (s.nama_siswa LIKE '%$nama%' OR '$nama' LIKE CONCAT('%', s.nama_siswa, '%'))
              LIMIT 1";

    $result = mysqli_query($conn, $query);
    if (!$result) {
        echo json_encode(["status" => "error", "message" => "Query Error: " . mysqli_error($conn)]);
        exit;
    }

    $data = mysqli_fetch_assoc($result);

    if ($data) {
        // Jika status null, berarti belum diabsen oleh petugas/admin
        if ($data['status'] == null) {
            $data['status'] = "Belum Diabsen Petugas";
        }
        echo json_encode([
            "status" => "success",
            "data" => $data
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Siswa tidak ditemukan. Pastikan Nama dan Kelas sudah benar."
        ]);
    }
}
?>
