/// Tahap perjalanan truk dalam satu ritase.
enum StatusPerjalanan {
  kosong('Kosong', 'Menuju area muat', 'Kosong'),
  diLoading('Di loading', 'Sedang muat di area loading', 'Muat'),
  bermuatan('Bermuatan', 'Menuju area bongkar', 'Bermuatan'),
  diDumping('Di dumping', 'Sedang bongkar di area dumping', 'Bongkar');

  const StatusPerjalanan(this.nama, this.keterangan, this.tahap);

  /// Nama status yang ditampilkan besar.
  final String nama;

  /// Penjelasan singkat di bawah nama.
  final String keterangan;

  /// Label pendek di bawah batang progres.
  final String tahap;
}
