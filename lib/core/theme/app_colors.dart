import 'dart:ui';

/// Token warna aplikasi. Layar dan komponen tidak boleh menulis warna
/// langsung; semua lewat kelas ini.
abstract final class AppColors {
  // Aksen
  static const Color aksen = Color(0xFFF29A00);
  static const Color aksenLembut = Color(0xFFFFF3DF);
  static const Color aksenTeks = Color(0xFF854500);
  static const Color aksenGaris = Color(0xFFB86B00);
  static const Color oranyeMasuk = Color(0xFFF29A00);
  static const Color oranyeMasukLembut = Color(0xFFFFF3DF);
  static const Color oranyeMasukTeks = Color(0xFF854500);

  // Teks
  static const Color teks = Color(0xFF15191E);
  static const Color teksSekunder = Color(0xFF5B636D);

  /// Teks di atas latar gelap (header sesi, tombol gelap).
  static const Color teksTerbalik = Color(0xFFFFFFFF);

  /// Keterangan di atas latar gelap. Jangan pakai [teksSekunder] di sana
  /// karena kontrasnya tidak cukup.
  static const Color teksTerbalikSekunder = Color(0xFFC5CAD0);

  // Permukaan
  static const Color latar = Color(0xFFF6F7F9);
  static const Color latarLuar = Color(0xFFE9EBE7);
  static const Color permukaan = Color(0xFFFFFFFF);
  static const Color gelap = Color(0xFF15191E);

  // Garis dan keadaan nonaktif
  static const Color garis = Color(0xFFE4E7EB);
  static const Color garisKuat = Color(0xFFC2C8C1);
  static const Color nonaktif = Color(0xFFE1E4DF);

  /// Teks di atas [nonaktif] (tombol yang belum bisa ditekan).
  static const Color teksNonaktif = Color(0xFF5B636D);

  // Status
  static const Color sukses = Color(0xFF1D7A46);
  static const Color suksesLembut = Color(0xFFE5F3EA);

  /// Hijau terang untuk titik "merekam" di atas latar gelap.
  static const Color suksesTerang = Color(0xFF4ADE80);
  static const Color bahaya = Color(0xFFB42318);
  static const Color bahayaLembut = Color(0xFFFDECEA);
  static const Color infoLembut = Color(0xFFEAF1FF);
  static const Color headerLembut = Color(0xFF293440);
  static const Color info = Color(0xFF1D4ED8);

  // Peta
  static const Color isiAreaMuat = Color(0x40F5B301); // aksen 25%
  static const Color isiAreaBongkar = Color(0x241D4ED8); // info 14%
  static const Color titikBongkar = Color(0xFF6E45A7);
  static const Color isiAkurasi = Color(0x26F5B301); // aksen 15%
  static const Color jejak = Color(0xB315191E); // teks 70%
  static const Color ruteDasar = Color(0xFFFFFFFF);

  /// Tirai di belakang dialog dan bottom sheet.
  static const Color tirai = Color(0x8015191E);
  static const Color transparan = Color(0x00000000);
}
