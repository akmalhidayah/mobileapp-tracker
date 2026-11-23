import 'package:flutter_map/flutter_map.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_space.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/app_ukuran.dart';
import '../../core/widgets/komponen.dart';
import '../../data/dummy/dummy_data.dart';
import '../../data/models/snapshot_sesi.dart';
import 'kontrol_peta.dart';

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
    child: ClipRRect(
      borderRadius: AppRadius.brKartu,
      child: SizedBox(
        height: AppUkuran.petaMini,
        child: PetaSesi(
          snapshot: snapshot,
          tileGagal: tileGagal,
          onPerbesar: onPerbesar,
        ),
      ),
    ),
  );
}

class PetaSesi extends StatefulWidget {
  const PetaSesi({
    super.key,
    required this.snapshot,
    required this.tileGagal,
    this.penuh = false,
    this.onPerbesar,
  });
  final SnapshotSesi snapshot;
  final bool tileGagal, penuh;
  final VoidCallback? onPerbesar;
  @override
  State<PetaSesi> createState() => PetaSesiState();
}

class PetaSesiState extends State<PetaSesi> {
  // Lunakkan warna tile saja; rute, ikon, dan status tetap kontras.
  static const _warnaRingkas = ColorFilter.matrix(<double>[
    // R, G, B, A, terang
    0.51, 0.32, 0.03, 0, 34,
    0.10, 0.73, 0.03, 0, 34,
    0.10, 0.32, 0.44, 0, 32,
    0, 0, 0, 1, 0,
  ]);

  final _controller = MapController();
  bool _siap = false, _ikuti = true, _gagal = false;
  bool _legendaTerbuka = false, _detailPeta = false;
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
          DummyData.titikMuat.posisi,
          DummyData.titikBongkar.posisi,
        ]),
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s32,
          AppSpace.s32,
          AppSpace.s32,
          AppSpace.s20 * 4,
        ),
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
    final state = AppScope.baca(context);
    final rute = state.ruteHauling.garis;
    final warnaVendor = AppColors.warnaTrukPeta(state.supir?.vendor.id);
    final gagal = widget.tileGagal || _gagal || KonfigurasiPeta.tanpaTile;
    return Column(
      children: [
        if (widget.penuh)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpace.s4,
              children: [
                TombolPeta(
                  label: _ikuti ? 'Mengikuti truk' : 'Ikuti saya',
                  ikon: Icons.my_location_rounded,
                  aktif: _ikuti,
                  onTap: ikuti,
                ),
                TombolPeta(
                  label: 'Lihat seluruh rute',
                  ikon: Icons.route_rounded,
                  onTap: seluruhRute,
                ),
                TombolPeta(
                  label: _detailPeta ? 'Peta ringkas' : 'Detail peta',
                  ikon: Icons.layers_outlined,
                  hanyaIkon: true,
                  aktif: _detailPeta,
                  onTap: gagal
                      ? null
                      : () => setState(() => _detailPeta = !_detailPeta),
                ),
              ],
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, batas) => Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: p?.posisi ?? rute.first,
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
                      ImageFiltered(
                        imageFilter: _warnaRingkas,
                        enabled: !_detailPeta,
                        child: TileLayer(
                          key: ValueKey(_percobaan),
                          urlTemplate: KonfigurasiPeta.tileUrl,
                          userAgentPackageName:
                              'com.tonasa.tracker.aplikasi_supir',
                          panBuffer: 0,
                          errorTileCallback: (_, _, _) => _gagalTile(),
                        ),
                      ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: rute,
                          color: AppColors.ruteGaris,
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
                    MarkerLayer(
                      markers: [
                        for (final (lokasi, jenis, warna) in [
                          (DummyData.titikMuat, 'Muat', AppColors.sukses),
                          (
                            DummyData.titikBongkar,
                            'Bongkar',
                            AppColors.titikBongkar,
                          ),
                        ])
                          Marker(
                            point: lokasi.posisi,
                            width: AppUkuran.ikonBesar,
                            height: AppUkuran.ikonBesar,
                            alignment: Alignment.topCenter,
                            child: Tooltip(
                              message: '$jenis · ${lokasi.nama}',
                              child: Icon(
                                Icons.location_on_rounded,
                                color: warna,
                                size: AppUkuran.ikonBesar,
                              ),
                            ),
                          ),
                        if (p != null)
                          Marker(
                            point: p.posisi,
                            width: AppUkuran.penandaTruk,
                            height: AppUkuran.penandaTruk,
                            child: _PenandaTruk(
                              snapshot: s,
                              warnaVendor: warnaVendor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: AppSpace.s8,
                  right: AppSpace.s8,
                  bottom: AppSpace.s8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.penuh && _legendaTerbuka)
                        LegendaPeta(
                          warnaTruk: warnaVendor,
                          tinggiMaks: batas.maxHeight * .5,
                        ),
                      if (widget.penuh)
                        Semantics(
                          expanded: _legendaTerbuka,
                          child: TombolPeta(
                            label: 'Legenda',
                            ikon: _legendaTerbuka
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            aktif: _legendaTerbuka,
                            onTap: () => setState(
                              () => _legendaTerbuka = !_legendaTerbuka,
                            ),
                          ),
                        )
                      else if (widget.onPerbesar != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TombolPeta(
                            label: 'Perbesar peta',
                            ikon: Icons.open_in_full_rounded,
                            onTap: widget.onPerbesar,
                          ),
                        ),
                      const KreditPeta(),
                    ],
                  ),
                ),
                if (gagal || p == null || !s.lokasiTersedia)
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
                                : !s.lokasiTersedia
                                ? 'Lokasi tidak tersedia. Menampilkan posisi terakhir.'
                                : 'Peta dasar tidak tersedia. Posisi simulasi tetap diperbarui.',
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
        ),
      ],
    );
  }
}

class _PenandaTruk extends StatelessWidget {
  const _PenandaTruk({required this.snapshot, required this.warnaVendor});

  final SnapshotSesi snapshot;
  final Color warnaVendor;

  @override
  Widget build(BuildContext context) {
    final (warnaTitik, keterangan) = snapshot.lokasiTersedia
        ? (warnaStatusPeta(snapshot.status), snapshot.status.tahap)
        : (AppColors.teksSekunder, 'lokasi terakhir usang');
    return Semantics(
      image: true,
      label: 'Posisi ${snapshot.nomorTruk}, $keterangan',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.permukaan,
          borderRadius: AppRadius.brKecil,
          border: Border.all(color: warnaVendor),
          boxShadow: const [
            BoxShadow(color: AppColors.permukaan, spreadRadius: 1.5),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              color: warnaVendor,
              size: AppUkuran.ikon,
            ),
            Positioned(
              top: AppUkuran.garis,
              right: AppUkuran.garis,
              child: Container(
                width: AppUkuran.titikStatus,
                height: AppUkuran.titikStatus,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: warnaTitik,
                  border: Border.all(color: AppColors.permukaan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
