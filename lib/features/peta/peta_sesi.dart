import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';
import '../../app/app_scope.dart';
import '../../data/models/snapshot_sesi.dart';

abstract final class KonfigurasiPeta {
  static const tileUrl = String.fromEnvironment(
    'TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
  static const tanpaTile = bool.fromEnvironment('TANPA_TILE');
}

class PetaMini extends StatelessWidget {
  const PetaMini({
    super.key,
    required this.snapshot,
    required this.tileGagal,
    required this.onPerbesar,
  });
  final SnapshotSesi snapshot;
  final bool tileGagal;
  final VoidCallback onPerbesar;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpace.s12),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.brKartu,
          child: SizedBox(
            height: AppUkuran.petaMini,
            child: PetaSesi(snapshot: snapshot, tileGagal: tileGagal),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TombolKecil('Perbesar peta', onTap: onPerbesar),
        ),
      ],
    ),
  );
}

class PetaSesi extends StatefulWidget {
  const PetaSesi({
    super.key,
    required this.snapshot,
    required this.tileGagal,
    this.penuh = false,
  });
  final SnapshotSesi snapshot;
  final bool tileGagal, penuh;
  @override
  State<PetaSesi> createState() => PetaSesiState();
}

class PetaSesiState extends State<PetaSesi> {
  final _controller = MapController();
  bool _siap = false, _ikuti = true, _gagal = false;
  int _percobaan = 0;
  bool get mengikuti => _ikuti;
  @override
  void didUpdateWidget(PetaSesi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tileGagal && !widget.tileGagal) {
      _gagal = false;
      _percobaan++;
    }
    if (widget.snapshot.posisi != oldWidget.snapshot.posisi && _ikuti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pusatkan();
      });
    }
  }

  void _pusatkan() {
    final p = widget.snapshot.posisi;
    if (_siap && p != null) _controller.move(p.posisi, _controller.camera.zoom);
  }

  void ikuti() {
    setState(() => _ikuti = true);
    _pusatkan();
  }

  void seluruhRute() {
    if (!_siap) return;
    setState(() => _ikuti = false);
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints([
          ...AppScope.baca(context).ruteHauling.garis,
          ...AppScope.baca(context).areaMuat.poligon,
          ...AppScope.baca(context).areaBongkar.poligon,
        ]),
        padding: const EdgeInsets.all(AppSpace.s32),
      ),
    );
  }

  void _gagalTile() {
    if (_gagal) return;
    _gagal = true; // latch segera agar banyak callback tidak menjadwalkan rebuild berulang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _siap = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.snapshot, p = s.posisi;
    final gagal = widget.tileGagal || _gagal || KonfigurasiPeta.tanpaTile;
    return Column(
      children: [
        if (widget.penuh)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.s8),
            child: Wrap(
              spacing: AppSpace.s8,
              children: [
                TombolKecil(
                  _ikuti ? 'Mengikuti truk' : 'Ikuti saya',
                  onTap: ikuti,
                ),
                TombolKecil('Lihat seluruh rute', onTap: seluruhRute),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter:
                      p?.posisi ??
                      AppScope.baca(context).ruteHauling.garis.first,
                  initialZoom: 15,
                  backgroundColor: AppColors.latarLuar,
                  interactionOptions: InteractionOptions(
                    flags: widget.penuh
                        ? InteractiveFlag.all & ~InteractiveFlag.rotate
                        : InteractiveFlag.none,
                  ),
                  onMapReady: () {
                    _siap = true;
                    _pusatkan();
                  },
                  onPositionChanged: (_, hasGesture) {
                    if (hasGesture && _ikuti && mounted) {
                      setState(() => _ikuti = false);
                    }
                  },
                ),
                children: [
                  if (!gagal)
                    TileLayer(
                      key: ValueKey(_percobaan),
                      urlTemplate: KonfigurasiPeta.tileUrl,
                      userAgentPackageName: 'com.tonasa.tracker.aplikasi_supir',
                      panBuffer: 0,
                      errorTileCallback: (_, e, s) => _gagalTile(),
                    ),
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: AppScope.baca(context).areaMuat.poligon,
                        color: AppColors.isiAreaMuat,
                        borderColor: AppColors.aksenTeks,
                        borderStrokeWidth: AppUkuran.areaPoligon,
                      ),
                      Polygon(
                        points: AppScope.baca(context).areaBongkar.poligon,
                        color: AppColors.isiAreaBongkar,
                        borderColor: AppColors.info,
                        borderStrokeWidth: AppUkuran.areaPoligon,
                      ),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: AppScope.baca(context).ruteHauling.garis,
                        color: AppColors.info,
                        strokeWidth: AppUkuran.ruteTengah,
                        borderColor: AppColors.ruteDasar,
                        borderStrokeWidth: 2,
                      ),
                      if (s.jejak.length > 1)
                        Polyline(
                          points: s.jejak.map((t) => t.posisi).toList(),
                          color: AppColors.jejak,
                          strokeWidth: AppUkuran.jejak,
                        ),
                    ],
                  ),
                  if (p != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: p.posisi,
                          radius: p.akurasi,
                          useRadiusInMeter: true,
                          color: AppColors.isiAkurasi,
                          borderColor: AppColors.aksenTeks,
                          borderStrokeWidth: 1,
                        ),
                      ],
                    ),
                  if (p != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: p.posisi,
                          width: AppUkuran.kotakPenanda,
                          height: AppUkuran.kotakPenanda,
                          child: Semantics(
                            label:
                                'Posisi ${s.nomorTruk}${s.lokasiTersedia ? '' : ', usang'}',
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpace.s4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.permukaan,
                                    borderRadius: AppRadius.brKecil,
                                  ),
                                  child: Text(
                                    s.nomorTruk,
                                    style: AppText.kecilTebal,
                                  ),
                                ),
                                Transform.rotate(
                                  angle: p.arah * math.pi / 180,
                                  child: Icon(
                                    Icons.navigation,
                                    size: AppUkuran.penandaTruk,
                                    color: s.lokasiTersedia
                                        ? AppColors.aksenTeks
                                        : AppColors.teksSekunder,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      color: AppColors.permukaan,
                      padding: const EdgeInsets.all(AppSpace.s4),
                      child: Text(
                        '© OpenStreetMap contributors',
                        style: AppText.mikro,
                      ),
                    ),
                  ),
                ],
              ),
              if (gagal || p == null)
                Positioned(
                  top: AppSpace.s8,
                  left: AppSpace.s8,
                  right: AppSpace.s8,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpace.s8),
                    decoration: const BoxDecoration(
                      color: AppColors.permukaan,
                      borderRadius: AppRadius.brKecil,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p == null
                              ? 'Menunggu posisi GPS.'
                              : 'Peta dasar tidak tersedia. ${s.lokasiTersedia ? 'Posisi simulasi tetap diperbarui.' : 'Posisi terakhir usang; lokasi tidak tersedia.'}',
                          style: AppText.mikro,
                        ),
                        if (_gagal && !widget.tileGagal)
                          TombolKecil(
                            'Coba peta lagi',
                            onTap: () => setState(() {
                              _gagal = false;
                              _percobaan++;
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class LegendaPeta extends StatelessWidget {
  const LegendaPeta({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpace.s16,
    runSpacing: AppSpace.s8,
    children: [
      for (final item in [
        ('Muat', AppColors.aksenTeks),
        ('Bongkar', AppColors.info),
        ('Rute resmi', AppColors.info),
        ('Jejak sesi', AppColors.teks),
      ])
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: AppUkuran.simbolLegenda, color: item.$2),
            const SizedBox(width: AppSpace.s4),
            Text(item.$1, style: AppText.mikro),
          ],
        ),
    ],
  );
}
