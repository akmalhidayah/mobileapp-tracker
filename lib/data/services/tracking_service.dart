import '../models/snapshot_sesi.dart';

abstract class TrackingService {
  Stream<SnapshotSesi> get perubahan;
  SnapshotSesi? get terkini;
  List<SnapshotSesi> get riwayat;
  Future<void> mulai({required String nomorTruk});

  /// Hentikan rekaman dahulu, lalu coba sinkronkan antrean.
  Future<void> selesai();
  Future<void> kirimSekarang();
  Future<void> reset();
  void dispose();
}

abstract interface class KendaliSimulasi {
  bool get simulasiGpsMati;
  set simulasiGpsMati(bool nilai);
  bool get izinDicabut;
  set izinDicabut(bool nilai);
  bool get uploadOffline;
  set uploadOffline(bool nilai);
  bool get gagalUpload;
  set gagalUpload(bool nilai);
  int get baterai;
  set baterai(int nilai);
  bool get charging;
  set charging(bool nilai);
  int get percepatan;
  set percepatan(int nilai);
  void lompatKe(Duration durasi);
}
