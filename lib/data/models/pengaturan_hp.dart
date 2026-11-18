/// Lima pengaturan HP yang harus aktif supaya pelacakan tidak terputus.
enum PengaturanHp {
  izinLokasi(
    judul: 'Izin lokasi',
    saatSiap: 'Diizinkan sepanjang waktu',
    saatBelum: 'Belum diizinkan sepanjang waktu',
    langkah:
        'Buka Pengaturan HP > Aplikasi > Tracker Truk > Izin > Lokasi, '
        'lalu pilih "Izinkan sepanjang waktu".',
  ),
  notifikasi(
    judul: 'Notifikasi',
    saatSiap: 'Aktif',
    saatBelum: 'Belum aktif',
    langkah:
        'Buka Pengaturan HP > Aplikasi > Tracker Truk > Notifikasi, '
        'lalu nyalakan "Izinkan notifikasi".',
  ),
  optimasiBaterai(
    judul: 'Optimasi baterai',
    saatSiap: 'Dikecualikan untuk aplikasi ini',
    saatBelum: 'Masih membatasi aplikasi ini',
    langkah:
        'Buka Pengaturan HP > Baterai > Optimasi baterai, cari Tracker '
        'Truk, lalu pilih "Jangan optimalkan".',
  ),
  mulaiOtomatis(
    judul: 'Mulai otomatis',
    saatSiap: 'Diizinkan',
    saatBelum: 'Belum diizinkan',
    langkah:
        'Buka Pengaturan HP > Aplikasi > Mulai otomatis (Autostart), '
        'lalu nyalakan untuk Tracker Truk.',
  ),
  gps(
    judul: 'GPS',
    saatSiap: 'Menyala, akurasi tinggi',
    saatBelum: 'Mati',
    langkah:
        'Tarik panel atas HP ke bawah lalu ketuk ikon Lokasi sampai '
        'menyala. Pilih mode "Akurasi tinggi" bila ditanya.',
  );

  const PengaturanHp({
    required this.judul,
    required this.saatSiap,
    required this.saatBelum,
    required this.langkah,
  });

  final String judul;
  final String saatSiap;
  final String saatBelum;

  /// Penjelasan singkat cara mengaturnya di Pengaturan HP.
  final String langkah;
}
