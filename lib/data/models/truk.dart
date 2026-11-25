class Truk {
  const Truk({
    this.id,
    required this.nomor,
    required this.jenis,
    required this.kapasitasTon,
    required this.vendorId,
  });

  final int? id;

  /// Nomor lambung, misalnya "DT-07".
  final String nomor;
  final String jenis;
  final num? kapasitasTon;

  /// ID vendor yang ditetapkan admin sebagai pemilik nomor lambung ini.
  final String vendorId;

  /// Keterangan satu baris, misalnya "Dump truck · 30 ton".
  String get keterangan {
    final kapasitas = kapasitasTon;
    if (kapasitas == null) return '$jenis · Kapasitas belum diisi';
    final nilai = kapasitas == kapasitas.round()
        ? kapasitas.round()
        : kapasitas;
    return '$jenis · $nilai ton';
  }
}
