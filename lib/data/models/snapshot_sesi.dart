import 'status_perjalanan.dart';
import 'titik_gps.dart';

/// Keadaan sesi pada satu saat. Dipancarkan oleh TrackingService setiap
/// ada perubahan.
class SnapshotSesi {
  const SnapshotSesi({
    this.sessionId = '',
    this.nomorTruk = '',
    this.aktif = false,
    this.izinLokasi = true,
    this.sedangKirim = false,
    this.gagalKirim = false,
    this.pengingat12Jam = false,
    this.otomatis = false,
    this.perluDicek = false,
    required this.waktu,
    required this.durasi,
    required this.posisi,
    required this.jejak,
    required this.status,
    required this.ritase,
    required this.belumTerkirim,
    required this.titikTerkirim,
    required this.kirimTerakhir,
    required this.gpsAktif,
    required this.baterai,
    required this.sedangDicas,
  });

  final String sessionId;
  final String nomorTruk;
  final bool aktif, izinLokasi, sedangKirim, gagalKirim;
  final bool pengingat12Jam, otomatis, perluDicek;
  int get totalRekaman => titikTerkirim + belumTerkirim;
  bool get lokasiTersedia => gpsAktif && izinLokasi;
  DateTime get mulai => waktu.subtract(durasi);

  /// Maksimal titik jejak yang disimpan untuk digambar di peta.
  static const int maksJejak = 200;

  /// Waktu snapshot ini dibuat.
  final DateTime waktu;
  final Duration durasi;

  /// Posisi terakhir; null jika belum ada titik sama sekali.
  final TitikGps? posisi;

  /// Titik-titik terakhir, paling banyak [maksJejak].
  final List<TitikGps> jejak;
  final StatusPerjalanan status;
  final int ritase;

  /// Jumlah titik yang masih menunggu dikirim ke server.
  final int belumTerkirim;

  /// Jumlah titik yang sudah terkirim sepanjang sesi.
  final int titikTerkirim;
  final DateTime? kirimTerakhir;
  final bool gpsAktif;

  /// Persentase baterai HP, 0 sampai 100.
  final int baterai;
  final bool sedangDicas;
}
