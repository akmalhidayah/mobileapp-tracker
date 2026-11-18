import 'vendor.dart';

class Supir {
  const Supir({required this.nama, required this.noHp, required this.vendor});

  final String nama;
  final String noHp;

  /// Vendor tempat supir terdaftar; menentukan daftar truk yang muncul.
  final Vendor vendor;
}
