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
      Truk(
        nomor: 'DT-11',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'topabiring',
      ),
      Truk(
        nomor: 'DT-15',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'topabiring',
      ),
      Truk(
        nomor: 'DT-21',
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
      Truk(
        nomor: 'DT-34',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-36',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-38',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-40',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-42',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'fajar',
      ),
      Truk(
        nomor: 'DT-45',
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
      Truk(
        nomor: 'DT-55',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'koperasi',
      ),
      Truk(
        nomor: 'DT-58',
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
      Truk(
        nomor: 'DT-66',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'prima_karya',
      ),
      Truk(
        nomor: 'DT-68',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'prima_karya',
      ),
      Truk(
        nomor: 'DT-69',
        jenis: 'Dump truck',
        kapasitasTon: 30,
        vendorId: 'prima_karya',
      ),
    ],
  );

  static const List<Vendor> daftarVendor = [
    topabiring,
    fajar,
    koperasi,
    primaKarya,
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
  ];

  /// Keadaan awal layar Cek kesiapan HP.
  static const Map<PengaturanHp, bool> kesiapanAwal = {
    PengaturanHp.izinLokasi: false,
    PengaturanHp.notifikasi: true,
    PengaturanHp.optimasiBaterai: false,
    PengaturanHp.mulaiOtomatis: false,
    PengaturanHp.gps: true,
  };

  // KOORDINAT CONTOH — ganti dengan koordinat area tambang asli
  static const AreaKerja areaMuat = AreaKerja(
    nama: 'Crusher',
    jenis: JenisArea.muat,
    // Di simulasi satu siklus hanya ±75 detik, jadi batasnya 4 detik.
    // Di lapangan nilainya dalam hitungan menit.
    durasiMinimum: Duration(seconds: 4),
    poligon: [
      LatLng(-4.7988, 119.5987),
      LatLng(-4.7989, 119.6013),
      LatLng(-4.8012, 119.6014),
      LatLng(-4.8011, 119.5986),
    ],
  );

  // KOORDINAT CONTOH — ganti dengan koordinat area tambang asli
  static const AreaKerja areaBongkar = AreaKerja(
    nama: 'Stockpile',
    jenis: JenisArea.bongkar,
    durasiMinimum: Duration(seconds: 4),
    poligon: [
      LatLng(-4.8138, 119.6147),
      LatLng(-4.8139, 119.6174),
      LatLng(-4.8163, 119.6173),
      LatLng(-4.8162, 119.6146),
    ],
  );

  // KOORDINAT CONTOH — ganti dengan koordinat area tambang asli
  static const Rute ruteHauling = Rute(
    nama: 'Hauling utama',
    toleransiMeter: 30,
    versi: 1,
    garis: [
      LatLng(-4.80000, 119.60000),
      LatLng(-4.80060, 119.60090),
      LatLng(-4.80110, 119.60190),
      LatLng(-4.80130, 119.60300),
      LatLng(-4.80120, 119.60420),
      LatLng(-4.80140, 119.60540),
      LatLng(-4.80210, 119.60640),
      LatLng(-4.80320, 119.60710),
      LatLng(-4.80440, 119.60750),
      LatLng(-4.80560, 119.60770),
      LatLng(-4.80680, 119.60810),
      LatLng(-4.80780, 119.60890),
      LatLng(-4.80850, 119.61000),
      LatLng(-4.80900, 119.61120),
      LatLng(-4.80960, 119.61230),
      LatLng(-4.81050, 119.61320),
      LatLng(-4.81160, 119.61390),
      LatLng(-4.81270, 119.61450),
      LatLng(-4.81370, 119.61520),
      LatLng(-4.81450, 119.61570),
      LatLng(-4.81500, 119.61600),
    ],
  );
}
