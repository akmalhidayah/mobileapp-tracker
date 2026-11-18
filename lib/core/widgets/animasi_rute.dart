import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Ilustrasi dekoratif, bukan lokasi atau pelacakan pengguna.
/// Hanya kanvas kecil ini yang digambar ulang selama animasi berjalan.
class AnimasiRute extends StatefulWidget {
  const AnimasiRute({super.key});

  @override
  State<AnimasiRute> createState() => _AnimasiRuteState();
}

class _AnimasiRuteState extends State<AnimasiRute>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gerak = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _gerak.stop();
      if (_gerak.value == 0) _gerak.value = 0.2;
    } else if (!_gerak.isAnimating) {
      _gerak.repeat();
    }
  }

  @override
  void dispose() {
    _gerak.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: RepaintBoundary(child: CustomPaint(painter: _PelukisRute(_gerak))),
    ),
  );
}

class _PelukisRute extends CustomPainter {
  _PelukisRute(this.gerak) : super(repaint: gerak);
  final Animation<double> gerak;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width, h = size.height;
    final awal = Offset(w * 0.14, h * 0.3);
    final akhir = Offset(w * 0.86, h * 0.82);
    final rute = Path()
      ..moveTo(awal.dx, awal.dy)
      ..lineTo(w * 0.66, h * 0.3)
      ..cubicTo(w * 0.86, h * 0.3, w * 0.86, h * 0.56, w * 0.66, h * 0.56)
      ..lineTo(w * 0.34, h * 0.56)
      ..cubicTo(w * 0.14, h * 0.56, w * 0.14, h * 0.82, w * 0.34, h * 0.82)
      ..lineTo(akhir.dx, akhir.dy);
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      rute,
      garis
        ..color = AppColors.permukaan
        ..strokeWidth = 14,
    );
    canvas.drawPath(
      rute,
      garis
        ..color = AppColors.gelap
        ..strokeWidth = 8,
    );

    final ukuran = rute.computeMetrics().first;
    // Jeda singkat di ujung sebelum perjalanan ilustrasi diulang.
    final progres = (gerak.value / 0.85).clamp(0.0, 1.0);
    canvas.drawPath(
      ukuran.extractPath(0, ukuran.length * progres),
      garis
        ..color = AppColors.aksen
        ..strokeWidth = 5,
    );
    _pin(canvas, awal);
    _pin(canvas, akhir);
    final arah = ukuran.getTangentForOffset(ukuran.length * progres);
    if (arah != null) {
      final denyut = (gerak.value * 4) % 1;
      final isi = Paint()
        ..color = AppColors.aksen.withValues(alpha: 0.3 * (1 - denyut));
      canvas.drawCircle(arah.position, 22 + 10 * denyut, isi);
      canvas.drawCircle(arah.position, 21, isi..color = AppColors.permukaan);
      canvas.drawCircle(arah.position, 18, isi..color = AppColors.gelap);
      _truk(canvas, arah.position, arah.vector.dx < 0);
    }
  }

  void _truk(Canvas canvas, Offset posisi, bool keKiri) {
    canvas.save();
    canvas.translate(posisi.dx, posisi.dy);
    if (keKiri) canvas.scale(-1, 1);
    final isi = Paint()..color = AppColors.aksen;
    final bak = Path()
      ..moveTo(-13, -9)
      ..lineTo(2, -9)
      ..lineTo(0, 1)
      ..lineTo(-10, 1)
      ..close();
    canvas.drawPath(bak, isi);
    final kabin = Path()
      ..moveTo(4, -6)
      ..lineTo(10, -6)
      ..lineTo(14, 1)
      ..lineTo(14, 6)
      ..lineTo(-12, 6)
      ..lineTo(-12, 3)
      ..lineTo(4, 3)
      ..close();
    canvas.drawPath(kabin, isi);
    canvas.drawRect(
      const Rect.fromLTWH(6, -4, 4, 4),
      isi..color = AppColors.permukaan,
    );
    for (final x in [-7.0, 9.0]) {
      canvas.drawCircle(Offset(x, 7), 4, isi..color = AppColors.gelap);
      canvas.drawCircle(Offset(x, 7), 2.5, isi..color = AppColors.permukaan);
    }
    canvas.restore();
  }

  void _pin(Canvas canvas, Offset titik) {
    canvas.save();
    canvas.translate(titik.dx, titik.dy);
    final bentuk = Path()
      ..moveTo(0, 0)
      ..cubicTo(-6, -7, -17, -19, -17, -29)
      ..cubicTo(-17, -51, 17, -51, 17, -29)
      ..cubicTo(17, -19, 6, -7, 0, 0)
      ..close();
    canvas.drawPath(
      bentuk,
      Paint()
        ..color = AppColors.permukaan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawPath(bentuk, Paint()..color = AppColors.aksenTeks);
    canvas.drawCircle(
      const Offset(0, -29),
      11,
      Paint()..color = AppColors.aksen,
    );
    canvas.drawCircle(
      const Offset(0, -29),
      6,
      Paint()..color = AppColors.permukaan,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PelukisRute oldDelegate) =>
      oldDelegate.gerak != gerak;
}
