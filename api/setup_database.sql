-- Script untuk membuat database dan tabel yang dibutuhkan
-- Jalankan di phpMyAdmin atau MySQL Client

CREATE DATABASE IF NOT EXISTS db_apk_wb;
USE db_apk_wb;

-- Tabel Kelas
CREATE TABLE IF NOT EXISTS `kelas` (
  `id_kelas` int(11) NOT NULL AUTO_INCREMENT,
  `nama_kelas` varchar(20) NOT NULL,
  PRIMARY KEY (`id_kelas`),
  UNIQUE KEY `nama_kelas` (`nama_kelas`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabel Siswa
CREATE TABLE IF NOT EXISTS `siswa` (
  `id_siswa` int(11) NOT NULL AUTO_INCREMENT,
  `nis` varchar(20) NOT NULL,
  `nama_siswa` varchar(100) NOT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `kelas` varchar(20) NOT NULL,
  PRIMARY KEY (`id_siswa`),
  UNIQUE KEY `nis` (`nis`),
  KEY `fk_kelas_siswa` (`kelas`),
  CONSTRAINT `fk_kelas_siswa` FOREIGN KEY (`kelas`) REFERENCES `kelas` (`nama_kelas`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Contoh data awal kelas jika diperlukan
INSERT IGNORE INTO `kelas` (`nama_kelas`) VALUES ('7A'), ('7B'), ('7C'), ('8A'), ('8B'), ('9A'), ('9B');
