import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/supir.dart';
import '../models/truk.dart';
import '../models/vendor.dart';

typedef ProfilSopir = ({Supir supir, int? trukTerpilihId, bool sudahSetuju});

// Naikkan bersama versi kebijakan Django saat teks persetujuan berubah.
const versiPersetujuanSopir = 1;

class KesalahanAkun implements Exception {
  const KesalahanAkun(this.pesan, {this.sesiHabis = false});

  final String pesan;
  final bool sesiHabis;
}

class AkunSopirApi {
  AkunSopirApi({
    required this.alamat,
    http.Client? klien,
    Future<String> Function()? instalasi,
    this._penyimpanan,
  }) : _klien = klien ?? http.Client(),
       _instalasi = instalasi ?? _idInstalasi;

  final Uri alamat;
  final http.Client _klien;
  final Future<String> Function() _instalasi;
  final FlutterSecureStorage? _penyimpanan;
  String get _kunciToken => 'tracker_tonasa_login:${alamat.origin}';
  String? _token;

  static Uri? alamatServer(String nilai) {
    if (nilai.isEmpty && kDebugMode) {
      final android =
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
      return Uri.parse(
        android ? 'http://10.0.2.2:8000' : 'http://127.0.0.1:8000',
      );
    }
    final uri = Uri.tryParse(nilai.trim());
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      return null;
    }
    if (uri.scheme == 'https') return uri;
    if (!kDebugMode || uri.scheme != 'http') return null;
    const loopback = {'127.0.0.1', 'localhost', '::1', '10.0.2.2'};
    final ios = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    return loopback.contains(uri.host) || (ios && _ipPrivat(uri.host))
        ? uri
        : null;
  }

  static bool _ipPrivat(String host) {
    final bagian = host.split('.').map(int.tryParse).toList();
    if (bagian.length != 4 ||
        bagian.any((n) => n == null || n < 0 || n > 255)) {
      return false;
    }
    final awal = bagian[0]!, kedua = bagian[1]!;
    return awal == 10 ||
        (awal == 172 && kedua >= 16 && kedua <= 31) ||
        (awal == 192 && kedua == 168);
  }

  static Future<String> _idInstalasi() async {
    const kunci = 'tracker_tonasa_instalasi';
    final preferensi = SharedPreferencesAsync();
    final ada = await preferensi.getString(kunci);
    if (ada != null) return ada;
    final baru = const Uuid().v4();
    await preferensi.setString(kunci, baru);
    return baru;
  }

  Future<ProfilSopir> masuk({required String noHp, required String pin}) async {
    final respons = await _kirim(
      'login',
      data: {'nomor_hp': noHp, 'pin': pin, 'instalasi': await _instalasi()},
    );
    if (respons.statusCode == 401 || respons.statusCode == 400) {
      throw const KesalahanAkun('Periksa kembali nomor HP dan PIN Anda.');
    }
    if (respons.statusCode == 429) {
      throw const KesalahanAkun(
        'Terlalu banyak percobaan. Tunggu dan coba lagi.',
      );
    }
    final data = _json(respons);
    final profil = _profil(data);
    final token = data['token'] as String;
    await _penyimpanan?.write(key: _kunciToken, value: token);
    _token = token;
    return profil;
  }

  Future<ProfilSopir?> pulihkan() async {
    final token = await _penyimpanan?.read(key: _kunciToken);
    if (token == null) return null;
    try {
      final profil = await _periksa(token);
      _token = token;
      return profil;
    } on KesalahanAkun catch (error) {
      if (error.sesiHabis) return null;
      rethrow;
    }
  }

  Future<ProfilSopir> periksaSesi() => _periksa(_token);

  Future<ProfilSopir> _periksa(String? token) async {
    final respons = await _terautentikasi(
      'session',
      data: const {},
      token: token,
    );
    return _profil(_json(respons));
  }

  ProfilSopir _profil(Map<String, dynamic> data) {
    if (data['versi_persetujuan'] != versiPersetujuanSopir) {
      throw const KesalahanAkun(
        'Versi persetujuan berbeda dengan server. Hubungi admin untuk pembaruan aplikasi.',
      );
    }
    final profil = data['pengemudi'] as Map<String, dynamic>;
    final perusahaan = data['ekspeditur'] as Map<String, dynamic>;
    final id = perusahaan['id'].toString();
    final truk = data['truk'] as List;
    return (
      supir: Supir(
        nama: profil['nama'] as String,
        noHp: profil['nomor_hp'] as String,
        vendor: Vendor(
          id: id,
          nama: perusahaan['nama'] as String,
          namaSingkat: perusahaan['nama_singkat'] as String,
          daftarTruk: List.unmodifiable([
            for (final item in truk)
              Truk(
                id: item['id'] as int,
                nomor: item['nomor_lambung'] as String,
                vendorId: id,
                jenis: 'Dump truck',
                kapasitasTon: num.tryParse(
                  item['kapasitas_ton']?.toString() ?? '',
                ),
              ),
          ]),
        ),
      ),
      trukTerpilihId: data['truk_terpilih_id'] as int?,
      sudahSetuju: data['sudah_setuju'] == true,
    );
  }

  Future<void> setuju() async {
    final respons = await _terautentikasi(
      'consent',
      data: {'versi': versiPersetujuanSopir},
      token: _token,
    );
    if (respons.statusCode != 204) {
      throw KesalahanAkun(
        respons.statusCode == 409
            ? 'Versi persetujuan berubah. Hubungi admin untuk pembaruan aplikasi.'
            : 'Persetujuan belum tersimpan. Coba lagi.',
      );
    }
  }

  Future<void> pilihTruk(int id) async {
    final respons = await _terautentikasi(
      'selected-truck',
      data: {'truk_id': id},
      token: _token,
    );
    if (respons.statusCode != 204) {
      throw KesalahanAkun(
        respons.statusCode == 409
            ? 'Truk ini tidak lagi ditugaskan kepada Anda. Muat ulang penugasan.'
            : 'Pilihan truk belum tersimpan. Coba lagi.',
      );
    }
  }

  Future<void> keluar() async {
    if (_token == null) return;
    final respons = await _kirim('logout', data: const {}, token: _token);
    if (respons.statusCode != 204 && respons.statusCode != 401) {
      throw const KesalahanAkun('Belum bisa keluar. Coba lagi.');
    }
    await _hapusToken();
  }

  Future<void> _hapusToken() async {
    await _penyimpanan?.delete(key: _kunciToken);
    _token = null;
  }

  Future<http.Response> _terautentikasi(
    String tujuan, {
    required Map<String, Object> data,
    required String? token,
  }) async {
    if (token != null) {
      final respons = await _kirim(tujuan, data: data, token: token);
      if (respons.statusCode != 401) return respons;
    }
    await _hapusToken();
    throw const KesalahanAkun(
      'Sesi login sudah habis. Masuk kembali.',
      sesiHabis: true,
    );
  }

  Future<http.Response> _kirim(
    String tujuan, {
    Map<String, Object>? data,
    String? token,
  }) async {
    final uri = alamat.resolve('/api/v1/driver/$tujuan/');
    final header = {
      'Accept': 'application/json',
      if (data != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final request = http.Request(data == null ? 'GET' : 'POST', uri)
      ..followRedirects = false
      ..headers.addAll(header);
    if (data != null) request.body = jsonEncode(data);
    try {
      return await _klien
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 12));
    } on http.ClientException {
      throw const KesalahanAkun(
        'Server belum bisa dihubungi. Periksa koneksi Anda.',
      );
    } on TimeoutException {
      throw const KesalahanAkun(
        'Server belum bisa dihubungi. Periksa koneksi Anda.',
      );
    }
  }

  Map<String, dynamic> _json(http.Response respons) {
    if (respons.statusCode != 200) {
      throw const KesalahanAkun(
        'Server belum bisa memproses permintaan. Coba lagi.',
      );
    }
    return jsonDecode(utf8.decode(respons.bodyBytes)) as Map<String, dynamic>;
  }

  void dispose() => _klien.close();
}
