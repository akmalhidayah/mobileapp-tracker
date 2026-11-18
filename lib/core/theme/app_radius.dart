import 'package:flutter/painting.dart';

/// Token radius sudut.
abstract final class AppRadius {
  static const double tombol = 14;
  static const double kartu = 14;
  static const double kartuBesar = 16;
  static const double input = 12;
  static const double tombolKecil = 10;
  static const double kecil = 6;
  static const double chip = 999;

  static const BorderRadius brTombol = BorderRadius.all(
    Radius.circular(tombol),
  );
  static const BorderRadius brKartu = BorderRadius.all(Radius.circular(kartu));
  static const BorderRadius brKartuBesar = BorderRadius.all(
    Radius.circular(kartuBesar),
  );
  static const BorderRadius brInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius brTombolKecil = BorderRadius.all(
    Radius.circular(tombolKecil),
  );
  static const BorderRadius brKecil = BorderRadius.all(Radius.circular(kecil));
  static const BorderRadius brChip = BorderRadius.all(Radius.circular(chip));

  /// Sudut atas bottom sheet.
  static const BorderRadius brLembarBawah = BorderRadius.vertical(
    top: Radius.circular(kartuBesar),
  );
  static const BorderRadius brLogin = BorderRadius.vertical(
    top: Radius.circular(32),
  );
}
