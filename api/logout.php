<?php
/**
 * SKRIP LOGOUT (PENGELUARAN PENGGUNA)
 * Digunakan untuk mengakhiri sesi pengguna pada antarmuka web.
 */

// Memulai atau melanjutkan sesi yang ada
session_start();

// Menghapus seluruh data sesi yang tersimpan di server
session_destroy();

/**
 * Setelah sesi dihancurkan, pengguna dialihkan (redirect)
 * kembali ke halaman login utama.
 */
header("Location: login.php");
exit;

/**
 * PENJELASAN FUNGSI FILE LOGOUT.PHP:
 * 1. session_start(): Memastikan PHP mengenali sesi mana yang akan ditutup.
 * 2. session_destroy(): Membersihkan semua data login (seperti username/role) dari memori server.
 * 3. header("Location: login.php"): Memindahkan tampilan browser pengguna ke halaman login agar mereka bisa masuk kembali jika diperlukan.
 * 4. exit: Menghentikan eksekusi skrip agar tidak ada kode di bawahnya yang dijalankan setelah pengalihan.
 */
?>
