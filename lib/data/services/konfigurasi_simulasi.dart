/// Semua interval menggunakan waktu virtual, bukan wall clock.
class KonfigurasiSimulasi {
  const KonfigurasiSimulasi({
    this.rekam = const Duration(seconds: 1),
    this.upload = const Duration(seconds: 30),
    this.pengingat = const Duration(hours: 12),
    this.batas = const Duration(hours: 16),
  });
  final Duration rekam, upload, pengingat, batas;
  static const demo = KonfigurasiSimulasi();
  // Target integrasi: bergerak 30s, idle 120s setelah diam 2 menit,
  // upload 180–300s. Bukan implementasi tracking produksi.
}
