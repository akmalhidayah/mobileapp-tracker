import 'package:aplikasi_supir/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pasangan teks normal memenuhi kontras 4.5:1', () {
    for (final pasangan in <(Color, Color)>[
      (AppColors.teks, AppColors.aksen),
      (AppColors.aksenTeks, AppColors.aksenLembut),
      (AppColors.teksSekunder, AppColors.latar),
      (AppColors.sukses, AppColors.suksesLembut),
      (AppColors.bahaya, AppColors.bahayaLembut),
      (AppColors.teksTerbalik, AppColors.bahaya),
      (AppColors.teksTerbalikSekunder, AppColors.gelap),
    ]) {
      final l = [pasangan.$1.computeLuminance(), pasangan.$2.computeLuminance()]
        ..sort();
      expect(
        (l.last + 0.05) / (l.first + 0.05),
        greaterThanOrEqualTo(4.5),
        reason: '$pasangan',
      );
    }
  });
}
