<?php
/**
 * HALAMAN REKAPITULASI ABSENSI (VERSI WEB)
 * Digunakan untuk melihat seluruh riwayat absensi secara langsung melalui browser.
 */

include 'layout.php'; // Menyertakan desain header dan koneksi database
?>

<div class="container mt-4">
    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0"><i class="fas fa-list"></i> Rekapitulasi Absensi Siswa</h5>
        </div>
        <div class="card-body">
            <!-- Tabel Bootstrap untuk menyajikan data -->
            <table class="table table-hover table-striped">
                <thead class="table-dark">
                    <tr>
                        <th>Nama Siswa</th>
                        <th>Tanggal</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <?php
                /**
                 * QUERY PENGAMBILAN DATA:
                 * Menghubungkan tabel 'absensi' dengan tabel 'siswa' menggunakan kolom NIS.
                 * Data diurutkan dari tanggal yang paling baru (DESC).
                 */
                $query = "SELECT s.nama_siswa, a.tanggal, a.status
                          FROM absensi a
                          JOIN siswa s ON s.nis = a.siswa_id
                          ORDER BY a.tanggal DESC";

                $result = mysqli_query($conn, $query);

                // Perulangan untuk menampilkan setiap baris data hasil query
                while($data = mysqli_fetch_assoc($result)){
                    // Menentukan warna label (badge) berdasarkan status
                    $warna_badge = "secondary";
                    if($data['status'] == "Hadir") $warna_badge = "success";
                    elseif($data['status'] == "Sakit") $warna_badge = "info";
                    elseif($data['status'] == "Izin") $warna_badge = "warning text-dark";
                    elseif($data['status'] == "Alpha") $warna_badge = "danger";
                ?>
                <tr>
                    <td><?= htmlspecialchars($data['nama_siswa']) ?></td>
                    <td><?= date('d-m-Y', strtotime($data['tanggal'])) ?></td>
                    <td>
                        <span class="badge bg-<?= $warna_badge ?>">
                            <?= $data['status'] ?>
                        </span>
                    </td>
                </tr>
                <?php } ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php
/**
 * PENJELASAN FUNGSI FILE REKAP.PHP:
 * 1. Menyajikan data absensi dalam format tabel web yang bersih dan profesional.
 * 2. Menggunakan JOIN SQL untuk menggabungkan data identitas siswa dengan data kehadiran.
 * 3. Dilengkapi dengan sistem pewarnaan otomatis (Badge) agar status kehadiran mudah dibedakan secara visual.
 * 4. Memastikan keamanan tampilan data dengan fungsi htmlspecialchars() untuk mencegah serangan XSS.
 * 5. File ini bergantung pada 'layout.php' yang menyediakan desain navigasi dan koneksi ke database.
 */
?>
