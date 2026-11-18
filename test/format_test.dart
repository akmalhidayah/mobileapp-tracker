import 'package:aplikasi_supir/core/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDurasi', () {
    test('5025 detik menjadi 01:23:45', () {
      expect(formatDurasi(const Duration(seconds: 5025)), '01:23:45');
    });

    test('nol dan lebih dari sehari', () {
      expect(formatDurasi(Duration.zero), '00:00:00');
      expect(formatDurasi(const Duration(hours: 27, seconds: 5)), '27:00:05');
    });
  });

  group('formatLalu', () {
    test('75 detik menjadi 1 mnt lalu', () {
      expect(formatLalu(const Duration(seconds: 75)), '1 mnt lalu');
    });

    test('di bawah semenit, menit, dan jam', () {
      expect(formatLalu(const Duration(seconds: 12)), 'baru saja');
      expect(formatLalu(const Duration(minutes: 2, seconds: 30)), '2 mnt lalu');
      expect(formatLalu(const Duration(hours: 3)), '3 jam lalu');
    });
  });

  group('angka gaya Indonesia', () {
    test('titik ribuan dan koma desimal', () {
      expect(formatAngka(1234567), '1.234.567');
      expect(formatAngka(12345.64, desimal: 1), '12.345,6');
      expect(formatAngka(999), '999');
      expect(formatAngka(-1500), '-1.500');
    });

    test('jarak dan kecepatan', () {
      expect(formatJarak(1800), '1,8 km');
      expect(formatJarak(352), '350 m');
      expect(formatKecepatan(8.9), '32 km/j');
    });
  });
}
