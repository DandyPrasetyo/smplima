-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 14, 2026 at 01:12 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_apk_wb`
--

-- --------------------------------------------------------

--
-- Table structure for table `absensi`
--

CREATE TABLE `absensi` (
  `id_absensi` int NOT NULL,
  `siswa_id` varchar(50) NOT NULL,
  `tanggal` date NOT NULL,
  `status` enum('Hadir','Sakit','Izin','Alpha') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `absensi`
--

INSERT INTO `absensi` (`id_absensi`, `siswa_id`, `tanggal`, `status`) VALUES
(23, '4256', '2026-04-12', 'Hadir'),
(24, '4257', '2026-04-12', 'Hadir'),
(25, '4258', '2026-04-12', 'Hadir'),
(26, '4259', '2026-04-12', 'Hadir'),
(27, '4260', '2026-04-12', 'Hadir'),
(28, '4261', '2026-04-12', 'Hadir'),
(29, '4262', '2026-04-12', 'Hadir'),
(30, '4263', '2026-04-12', 'Hadir'),
(31, '4264', '2026-04-12', 'Hadir'),
(32, '4265', '2026-04-12', 'Hadir'),
(33, '4266', '2026-04-12', 'Hadir'),
(34, '4267', '2026-04-12', 'Hadir'),
(35, '4268', '2026-04-12', 'Hadir'),
(36, '4287', '2026-04-12', 'Sakit'),
(37, '4286', '2026-04-12', 'Sakit'),
(38, '4285', '2026-04-12', 'Izin'),
(39, '4284', '2026-04-12', 'Hadir'),
(40, '4283', '2026-04-12', 'Hadir'),
(41, '4282', '2026-04-12', 'Hadir'),
(42, '4281', '2026-04-12', 'Hadir'),
(43, '4280', '2026-04-12', 'Alpha'),
(44, '4279', '2026-04-12', 'Hadir'),
(45, '4278', '2026-04-12', 'Hadir'),
(46, '4277', '2026-04-12', 'Hadir'),
(47, '4276', '2026-04-12', 'Hadir'),
(48, '4275', '2026-04-12', 'Hadir'),
(49, '4274', '2026-04-12', 'Hadir'),
(50, '4273', '2026-04-12', 'Hadir'),
(51, '4272', '2026-04-12', 'Hadir'),
(52, '4270', '2026-04-12', 'Hadir'),
(53, '4269', '2026-04-12', 'Sakit');

-- --------------------------------------------------------

--
-- Table structure for table `kelas`
--

CREATE TABLE `kelas` (
  `id` int NOT NULL,
  `nama_kelas` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kelas`
--

INSERT INTO `kelas` (`id`, `nama_kelas`) VALUES
(13, ''),
(8, '7A'),
(9, '7B'),
(10, '8A'),
(46, '9F');

-- --------------------------------------------------------

--
-- Table structure for table `siswa`
--

CREATE TABLE `siswa` (
  `nis` varchar(20) NOT NULL,
  `nama_siswa` varchar(100) NOT NULL,
  `kelas` varchar(10) NOT NULL,
  `jenis_kelamin` enum('L','P') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `siswa`
--

INSERT INTO `siswa` (`nis`, `nama_siswa`, `kelas`, `jenis_kelamin`) VALUES
('4256', 'ACHMAD FAIZ YAHYA', '7A', 'L'),
('4257', 'Adenta Prayudha Sasongko', '7A', 'L'),
('4258', 'AHMAD IBRAHIM MURJA MULYADI', '7A', 'L'),
('4259', 'AKHMAD HAIKAL AL AWWAL', '7A', 'L'),
('4260', 'ANANDA AYU KIRANA', '7A', 'P'),
('4261', 'ARRIVAL SYAMSI DHUHA AL- JANNAH', '7A', 'L'),
('4262', 'ATIKA NAJWA PUTRI', '7A', 'P'),
('4263', 'CALISTHA QUEENA AQILA', '7A', 'P'),
('4264', 'DANISH JULIAN CAHYA PUTRA', '7A', 'L'),
('4265', 'DIFRANS NOVRIANSYAH', '7A', 'L'),
('4266', 'IFNA ZAHIRA', '7A', 'P'),
('4267', 'ISVI HUMAIROH RAMADHANI', '7A', 'P'),
('4268', 'Izam Bastian Alfareza', '7A', 'L'),
('4269', 'JESKA ADAM MAULANA', '7A', 'L'),
('4270', 'KAYLA DWI ALISHA', '7A', 'P'),
('4272', 'LUVIANDA NASYA SHAYNA', '7A', 'P'),
('4273', 'MAULANA MALIK IBRAHIM', '7A', 'L'),
('4274', 'MOCH DAVID SETIAWAN', '7A', 'L'),
('4275', 'MOCH. MAULANA ZAKARIA', '7A', 'L'),
('4276', 'MOCHAMAD RENDY ARTADINATA', '7A', 'L'),
('4277', 'MUHAMMAD GEBY PRAKOSO', '7A', 'L'),
('4278', 'NABILLAH PUTRI HIDAYAH', '7A', 'P'),
('4279', 'NATASYA ANINDIA SAFIRA JUNI SAPUTRI', '7A', 'P'),
('4280', 'Ni Putu Alisha Putri Kalyani', '7A', 'P'),
('4281', 'RADEN MOCHAMMAD RAIHAN ALFAATIH', '7A', 'L'),
('4282', 'Reiko Odelia Amanda', '7A', 'P'),
('4283', 'REYNIA AULIA LATHIEF', '7A', 'P'),
('4284', 'RUSYDAH AZKI MAULIDIYAH', '7A', 'P'),
('4285', 'SEVANYA DARA MEYLITA', '7A', 'P'),
('4286', 'SOFI INDRA PAKERTI', '7A', 'P'),
('4287', 'Syahrini Aulia Zafirah', '7A', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `role` enum('ADMIN','GURU','PETUGAS','SISWA') NOT NULL,
  `kelas` varchar(10) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `nama_lengkap`, `role`, `kelas`, `created_at`) VALUES
(1, 'admin', 'admin123', 'Pak Guru Admin', 'ADMIN', NULL, '2026-04-07 06:11:29'),
(2, 'petugas1', 'petugas123', 'Budi Petugas', 'PETUGAS', NULL, '2026-04-07 06:11:29'),
(3, 'Wildan123', '$2y$10$cs1GrA7P3ydF72rhlZqvIevkla4HrDTYiyC4j75hilmNyn3BIfVPi', 'Wildan', 'ADMIN', '', '2026-04-07 07:21:29'),
(4, 'admin12', '$2y$10$IGqNWKlKieCAYny16wO4E.EVTukGCgRr2H8SXxcftox87ahNQCh26', 'admin12', 'ADMIN', '', '2026-04-07 07:24:25'),
(6, '7a', '$2y$10$7hPq8wJZSOKyx5zG2mGD..IzGLac1wHTyKH7ypcqTnWQ3A3eWTPvC', '7a', 'PETUGAS', '', '2026-04-07 07:27:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `absensi`
--
ALTER TABLE `absensi`
  ADD PRIMARY KEY (`id_absensi`),
  ADD UNIQUE KEY `unique_daily_absen` (`siswa_id`,`tanggal`);

--
-- Indexes for table `kelas`
--
ALTER TABLE `kelas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nama_kelas` (`nama_kelas`),
  ADD UNIQUE KEY `nama_kelas_2` (`nama_kelas`);

--
-- Indexes for table `siswa`
--
ALTER TABLE `siswa`
  ADD PRIMARY KEY (`nis`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `absensi`
--
ALTER TABLE `absensi`
  MODIFY `id_absensi` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `kelas`
--
ALTER TABLE `kelas`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `absensi`
--
ALTER TABLE `absensi`
  ADD CONSTRAINT `fk_siswa_absensi` FOREIGN KEY (`siswa_id`) REFERENCES `siswa` (`nis`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
