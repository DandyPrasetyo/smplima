<?php
error_reporting(0); // Matikan pesan error PHP agar tidak merusak JSON
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'config.php';

$tanggal = isset($_GET['tanggal']) ? $_GET['tanggal'] : date('Y-m-d');
$kelas = isset($_GET['kelas']) ? $_GET['kelas'] : '';

if ($kelas == '') {
    echo json_encode([]);
    exit;
}

// Logika tanggal kemarin
$tanggal_kemarin = date('Y-m-d', strtotime($tanggal . ' -1 day'));

$sql = "SELECT
            s.nis,
            s.nama_siswa,
            (SELECT status FROM absensi WHERE siswa_id = s.nis AND tanggal = '$tanggal' LIMIT 1) as status_hari_ini,
            (SELECT status FROM absensi WHERE siswa_id = s.nis AND tanggal = '$tanggal_kemarin' LIMIT 1) as status_kemarin
        FROM siswa s
        JOIN kelas k ON s.kelas_id = k.id
        WHERE k.nama_kelas = '$kelas'
        ORDER BY s.nama_siswa ASC";

$result = mysqli_query($conn, $sql);
$data = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        // Pastikan status tidak NULL agar tidak error di Flutter
        $row['status_hari_ini'] = $row['status_hari_ini'] ?? "";
        $row['status_kemarin'] = $row['status_kemarin'] ?? "-";
        $data[] = $row;
    }
}

echo json_encode($data);
?>
