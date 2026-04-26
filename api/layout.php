<?php
/**
 * FILE LAYOUT UTAMA (HEADER & SIDEBAR)
 * File ini berfungsi sebagai kerangka tampilan untuk semua halaman admin berbasis web.
 * Dengan menyertakan file ini, setiap halaman akan memiliki navigasi yang seragam.
 */

// Menghubungkan ke database agar semua halaman web otomatis memiliki akses data
include 'config.php';
?>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistem Absensi SMPN 5 Lumajang</title>

    <!-- Memuat CSS Bootstrap 5 untuk tampilan yang responsif dan modern -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Menambahkan Font Awesome untuk ikon-ikon menarik -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <style>
        /* Mengatur warna latar belakang halaman agar tidak terlalu putih menyilaukan */
        body { background: #f4f6f9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

        /* Mengatur desain Sidebar (Menu Samping) yang tetap (Fixed) di sebelah kiri */
        .sidebar {
            width: 250px;
            height: 100vh;
            position: fixed;
            background: #0d6efd; /* Warna biru utama */
            color: white;
            transition: all 0.3s;
        }

        /* Mengatur tampilan link navigasi di dalam sidebar */
        .sidebar a {
            color: rgba(255,255,255,0.8);
            display: block;
            padding: 15px 25px;
            text-decoration: none;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        /* Memberikan efek hover saat menu diarahkan oleh kursor */
        .sidebar a:hover {
            background: rgba(255,255,255,0.1);
            color: white;
            padding-left: 30px;
        }

        /* Mengatur area konten utama agar tidak tertutup oleh sidebar */
        .content {
            margin-left: 250px;
            padding: 30px;
            min-height: 100vh;
        }

        /* Responsivitas untuk layar kecil (HP) */
        @media (max-width: 768px) {
            .sidebar { width: 70px; }
            .sidebar a span { display: none; }
            .content { margin-left: 70px; }
            .sidebar h4 { font-size: 0.8rem; }
        }
    </style>
</head>
<body>

<!-- BAGIAN SIDEBAR (MENU NAVIGASI) -->
<div class="sidebar">
    <div class="text-center py-4">
        <h4 class="fw-bold"><i class="fas fa-user-check"></i> <span>ABSENSI</span></h4>
        <small class="text-white-50">SMPN 5 Lumajang</small>
    </div>
    <hr class="mx-3 my-0">

    <nav class="mt-2">
        <a href="dashboard.php"><i class="fas fa-home me-2"></i> <span>Dashboard</span></a>
        <a href="absensi.php"><i class="fas fa-calendar-check me-2"></i> <span>Absensi</span></a>
        <a href="rekap.php"><i class="fas fa-file-invoice me-2"></i> <span>Rekap</span></a>
        <a href="logout.php" class="text-warning"><i class="fas fa-sign-out-alt me-2"></i> <span>Logout</span></a>
    </nav>
</div>

<!-- BAGIAN KONTEN UTAMA -->
<!-- Tag pembuka <div> ini akan ditutup di masing-masing file yang menyertakan layout ini -->
<div class="content">
