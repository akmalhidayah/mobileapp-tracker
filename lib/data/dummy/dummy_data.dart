import 'package:latlong2/latlong.dart';

import '../models/area_kerja.dart';
import '../models/pengaturan_hp.dart';
import '../models/rute.dart';
import '../models/supir.dart';
import '../models/truk.dart';
import '../models/vendor.dart';

/// Semua data contoh aplikasi. Nanti diganti data dari server.
abstract final class DummyData {
  // NOMOR LAMBUNG CONTOH — ganti dengan data armada asli tiap vendor.
  static const Vendor topabiring = Vendor(
    id: 'topabiring',
    nama: 'PT. Topabiring Trans Logistik',
    namaSingkat: 'Topabiring',
    daftarTruk: [
      Truk(
        nomor: 'DT-03',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'topabiring',
      ),
      Truk(
        nomor: 'DT-07',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'topabiring',
      ),
    ],
  );

  static const Vendor fajar = Vendor(
    id: 'fajar',
    nama: 'PT. Fajar Trans Sejahtera',
    namaSingkat: 'Fajar',
    daftarTruk: [
      Truk(
        nomor: 'DT-31',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-32',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
    ],
  );

  static const Vendor koperasi = Vendor(
    id: 'koperasi',
    nama: 'Koperasi Produsen Karyawan Semen Tonasa',
    namaSingkat: 'Koperasi',
    daftarTruk: [
      Truk(
        nomor: 'DT-51',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'koperasi',
      ),
      Truk(
        nomor: 'DT-52',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'koperasi',
      ),
    ],
  );

  static const Vendor primaKarya = Vendor(
    id: 'prima_karya',
    nama: 'PT. Prima Karya Manunggal',
    namaSingkat: 'Prima Karya',
    daftarTruk: [
      Truk(
        nomor: 'DT-61',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'prima_karya',
      ),
      Truk(
        nomor: 'DT-63',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'prima_karya',
      ),
    ],
  );

  static const Vendor tambahan = Vendor(
    id: 'tambahan',
    nama: 'Armada Tambahan',
    namaSingkat: 'Armada Tambahan',
    daftarTruk: [
      Truk(
        nomor: 'DT-91',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'tambahan',
      ),
      Truk(
        nomor: 'DT-92',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'tambahan',
      ),
    ],
  );

  static const List<Vendor> daftarVendor = [
    topabiring,
    fajar,
    koperasi,
    primaKarya,
    tambahan,
  ];

  /// Semua truk dari semua vendor.
  static final List<Truk> daftarTruk = [
    for (final v in daftarVendor) ...v.daftarTruk,
  ];

  /// Akun supir contoh. Nomor HP menentukan vendor dan daftar truknya.
  /// Di aplikasi asli data ini datang dari server.
  static const List<Supir> akunSupir = [
    Supir(nama: 'Rahmat', noHp: '081234567890', vendor: topabiring),
    Supir(nama: 'Hasan', noHp: '081234567891', vendor: fajar),
    Supir(nama: 'Yusuf', noHp: '081234567892', vendor: koperasi),
    Supir(nama: 'Andi', noHp: '081234567893', vendor: primaKarya),
    Supir(nama: 'Dedi', noHp: '081234567894', vendor: tambahan),
  ];

  /// Keadaan awal layar Cek kesiapan HP.
  static const Map<PengaturanHp, bool> kesiapanAwal = {
    PengaturanHp.izinLokasi: false,
    PengaturanHp.notifikasi: true,
    PengaturanHp.optimasiBaterai: false,
    PengaturanHp.mulaiOtomatis: false,
    PengaturanHp.gps: true,
  };

  static const _posisiMuat = LatLng(-4.7835447437522305, 119.62012886932237);
  static const _posisiBongkar = LatLng(-4.818083399198741, 119.49784845111566);

  // Pin hasil mapping yang juga menjadi ujung rute simulasi.
  static const titikMuat = (nama: 'Limestone Crusher 2', posisi: _posisiMuat);
  static const titikBongkar = (nama: 'Biringkassi', posisi: _posisiBongkar);

  static final areaMuat = AreaKerja(
    nama: titikMuat.nama,
    jenis: JenisArea.muat,
    durasiMinimum: const Duration(seconds: 4),
    poligon: _poligonSimulasi(_posisiMuat),
  );

  static final areaBongkar = AreaKerja(
    nama: titikBongkar.nama,
    jenis: JenisArea.bongkar,
    durasiMinimum: const Duration(seconds: 4),
    poligon: _poligonSimulasi(_posisiBongkar),
  );

  // Kotak ilustrasi di sekitar pin agar ritase simulasi dapat dihitung.
  static List<LatLng> _poligonSimulasi(LatLng pusat) {
    const setengahSisi = 0.00075;
    final lat = pusat.latitude;
    final lon = pusat.longitude;
    return List.unmodifiable([
      LatLng(lat - setengahSisi, lon - setengahSisi),
      LatLng(lat - setengahSisi, lon + setengahSisi),
      LatLng(lat + setengahSisi, lon + setengahSisi),
      LatLng(lat + setengahSisi, lon - setengahSisi),
    ]);
  }

  // Rute demo sama dengan dashboard (OSRM/FOSSGIS, data OpenStreetMap).
  // Segmen pendek dari jalan ke pin adalah ilustrasi.
  static const Rute ruteHauling = Rute(
    nama: 'Limestone Crusher 2 – Biringkassi',
    toleransiMeter: 30,
    versi: 2,
    garis: [
      _posisiMuat,
      LatLng(-4.787019, 119.619387),
      LatLng(-4.787206, 119.618777),
      LatLng(-4.788369, 119.618620),
      LatLng(-4.787516, 119.617588),
      LatLng(-4.787467, 119.615357),
      LatLng(-4.788838, 119.615167),
      LatLng(-4.789808, 119.611832),
      LatLng(-4.799642, 119.607357),
      LatLng(-4.800599, 119.606003),
      LatLng(-4.802312, 119.597268),
      LatLng(-4.800588, 119.587864),
      LatLng(-4.801320, 119.580551),
      LatLng(-4.806854, 119.573131),
      LatLng(-4.809870, 119.557159),
      LatLng(-4.812198, 119.553396),
      LatLng(-4.813123, 119.549421),
      LatLng(-4.814974, 119.545397),
      LatLng(-4.813215, 119.540819),
      LatLng(-4.8146665, 119.5221265),
      LatLng(-4.816118, 119.503434),
      LatLng(-4.817203, 119.503368),
      LatLng(-4.817425, 119.499013),
      LatLng(-4.817972, 119.498981),
      _posisiBongkar,
    ],
  );
}
