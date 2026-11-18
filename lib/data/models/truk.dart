class Truk {
  const Truk({
    required this.nomor,
    required this.jenis,
    required this.kapasitasTon,
    required this.vendorId,
  });

  /// Nomor lambung, misalnya "DT-07".
  final String nomor;
  final String jenis;
  final int kapasitasTon;

  /// ID vendor yang ditetapkan admin sebagai pemilik nomor lambung ini.
  final String vendorId;

  /// Keterangan satu baris, misalnya "Dump truck · 30 ton".
  String get keterangan => '$jenis · $kapasitasTon ton';
}
