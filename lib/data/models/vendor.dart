import 'truk.dart';

/// Perusahaan ekspeditur (vendor) pemilik armada. Supir hanya melihat
/// truk milik vendor tempat dia terdaftar.
class Vendor {
  const Vendor({
    required this.id,
    required this.nama,
    required this.namaSingkat,
    required this.daftarTruk,
  });

  /// ID stabil dari konfigurasi admin; dipakai untuk mencocokkan armada.
  final String id;

  /// Nama lengkap, tampil di header, misalnya "PT. Topabiring Trans Logistik".
  final String nama;

  /// Nama pendek untuk ruang sempit, misalnya "Topabiring".
  final String namaSingkat;

  /// Nomor lambung armada vendor ini.
  final List<Truk> daftarTruk;
}
