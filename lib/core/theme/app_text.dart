import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Token tipografi. Judul dan angka besar memakai Space Grotesk Bold,
/// sisanya Inter.
abstract final class AppText {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle _judul(double ukuran, {double tinggi = 1.15}) => TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: ukuran,
    fontWeight: FontWeight.w700,
    height: tinggi,
    letterSpacing: -0.3,
    color: AppColors.teks,
  );

  static TextStyle _isi(
    double ukuran, {
    FontWeight tebal = FontWeight.w400,
    double tinggi = 1.45,
    Color warna = AppColors.teks,
    double jarakHuruf = 0,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: ukuran,
    fontWeight: tebal,
    height: tinggi,
    letterSpacing: jarakHuruf,
    color: warna,
  );

  // Space Grotesk
  static TextStyle get judulBesar => _judul(30);
  static TextStyle get judul => _judul(28);
  static TextStyle get subjudulBesar => _judul(24, tinggi: 1.2);
  static TextStyle get subjudul => _judul(22, tinggi: 1.2);
  static TextStyle get nomorTruk => _judul(18, tinggi: 1.2);

  /// Durasi sesi 00:00:00, angka tabular supaya tidak bergoyang.
  static TextStyle get angkaBesar =>
      _judul(44, tinggi: 1.05).copyWith(fontFeatures: _tabular);

  /// Nilai statistik.
  static TextStyle get angka =>
      _judul(36, tinggi: 1.05).copyWith(fontFeatures: _tabular);

  // Inter
  static TextStyle get isiBesar => _isi(16, tinggi: 1.5);
  static TextStyle get isi => _isi(15);
  static TextStyle get label => _isi(15, tebal: FontWeight.w600, tinggi: 1.3);
  static TextStyle get tombol => _isi(16, tebal: FontWeight.w600, tinggi: 1.2);
  static TextStyle get kecil =>
      _isi(13, tinggi: 1.4, warna: AppColors.teksSekunder);
  static TextStyle get kecilTebal =>
      _isi(13, tebal: FontWeight.w600, tinggi: 1.3);
  static TextStyle get mikro =>
      _isi(12, tinggi: 1.35, warna: AppColors.teksSekunder);

  /// Label huruf besar seperti "LANGKAH 1 DARI 2".
  static TextStyle get penanda => _isi(
    12,
    tebal: FontWeight.w600,
    tinggi: 1.3,
    warna: AppColors.teksSekunder,
    jarakHuruf: 0.8,
  );
}
