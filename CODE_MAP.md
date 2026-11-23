# Peta kode Tracker Clinker Tonasa

Dokumen ini memetakan kode dashboard admin dan aplikasi supir. Untuk perintah kerja, baca [AGENTS.md](AGENTS.md). Untuk status integrasi, baca [RINGKASAN.md](RINGKASAN.md).

## Gambaran aliran data

```text
Dashboard admin
Browser → URL Django → sesi/izin → view → template HTML
                                  ├─ SQLite: akun, ekspeditur, truk, pengemudi
                                  └─ data_contoh.py: posisi simulasi, rute, angka laporan
        HTML halaman Monitoring → JSON data-armada → React → Leaflet

Aplikasi supir
Widget Flutter → AppScope / AppState → TrackingService
                                     └─ FakeTrackingService → snapshot & ringkasan
                                                             └─ MesinRitase
```

Keduanya memakai rute demo yang sama, tetapi belum bertukar data. Permintaan jaringan untuk peta dasar berasal dari masing-masing klien.

## Dashboard admin

| Bagian | Titik masuk | Alur dan catatan |
| --- | --- | --- |
| Konfigurasi | [config/settings.py](https://github.com/akmalhidayah/web_tracker/blob/main/config/settings.py), [config/urls.py](https://github.com/akmalhidayah/web_tracker/blob/main/config/urls.py), [manage.py](https://github.com/akmalhidayah/web_tracker/blob/main/manage.py) | Django, aplikasi `monitoring`, SQLite, `Asia/Makassar`, bahasa Indonesia, template dan aset statis. Nama variabel lingkungan untuk konfigurasi: `DJANGO_DEBUG`, `DJANGO_SECRET_KEY`, `DJANGO_ALLOWED_HOSTS`, `DJANGO_DB_PATH`. |
| Login dan logout | [monitoring/urls.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/urls.py), [monitoring/forms.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/forms.py), [masuk.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/masuk.html) | `/masuk/` memakai `LoginView` dan `MasukForm`; sukses kembali ke tujuan valid atau ke Monitoring. `/keluar/` memakai `LogoutView` via POST. Form akun web menggunakan data dan sesi Django. |
| Profil dan sandi | [monitoring/views.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/views.py), [profil.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/profil.html), [sandi.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/sandi.html) | `/profil/` mengubah nama serta email pengguna yang sedang login; `/profil/ganti-sandi/` memakai mekanisme ganti sandi Django. |
| Tampilan daftar Data Master | [monitoring/panel.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/panel.py), [change_list.html](https://github.com/akmalhidayah/web_tracker/blob/main/templates/admin/change_list.html), [panel_hero.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/panel_hero.html), bagian "Panel pengelolaan" di [admin.css](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/static/monitoring/admin.css) | `PanelAdminMixin` menambah kartu ringkasan, tab penyaring dengan jumlah, dan kolom aksi ke Ekspeditur, Truk, Pengemudi, User, dan Grup. Kartu judul yang sama tampil di halaman daftar dan formulir. Parameter tab memakai nama filter bawaan admin, jadi harus ada di `list_filter`. |
| Data Master | [monitoring/models.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/models.py), [monitoring/admin.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/admin.py), [templates/admin/base.html](https://github.com/akmalhidayah/web_tracker/blob/main/templates/admin/base.html) | `Ekspeditur` menyimpan kode, warna, dan status aktif. `Truk` dan `Pengemudi` terkait ke ekspeditur. Relasi ekspeditur dilindungi dari penghapusan jika masih dirujuk. Pengemudi belum terhubung ke akun login Flutter. |
| User Panel | [monitoring/admin.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/admin.py), [templatetags/navigasi.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templatetags/navigasi.py) | Di bawah Data Master; pengelolaan User dan Group memakai kelas admin yang membatasi akses ke superuser. Master lain memakai izin Django. Nama model internal `Ekspeditur` dipakai untuk rute admin. |
| Skema dan seed | [monitoring/migrations/](https://github.com/akmalhidayah/web_tracker/tree/main/monitoring/migrations), [isi_master_contoh.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/management/commands/isi_master_contoh.py) | Migrasi `0001` membuat model. `0002` dan `0003` mencatat perubahan istilah tampilan. Perintah seed menyiapkan ekspeditur dan truk contoh, bukan sumber telemetri atau laporan produksi. |
| Kerangka halaman | [base.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/base.html), [topbar.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/topbar.html), [sidebar.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/sidebar.html) | Header dan sidebar dipakai bersama halaman web dan admin. `navigasi.js` menangani panel menu HP, penutupan dari luar, dan pilihan buka/tutup di desktop. |
| Gaya dan ikon | [dashboard.css](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/static/monitoring/dashboard.css), [admin.css](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/static/monitoring/admin.css), [aset.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templatetags/aset.py) | Tema merah dan konten putih; foto login `login-tonasa.avif` berasal dari `start-bg.avif`. Ikon merek `tracker-icon.png` dibedakan dari favicon, logo SIG/Semen Tonasa, dan SVG truk. `aset_versi` memasukkan versi aset berdasarkan waktu modifikasi. |

### Monitoring

1. `monitoring()` di [views.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/views.py) mengambil ekspeditur dan truk aktif dari SQLite. [data_contoh.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/data_contoh.py) menyusun fixture posisi berdasarkan nomor lambung, serta rute `RUTE` dan titik `AREA`. Truk aktif tanpa posisi contoh tetap masuk daftar.
2. [monitoring.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/monitoring.html) menanam JSON `data-armada` dan memuat bundel React. [monitoring.jsx](https://github.com/akmalhidayah/web_tracker/blob/main/frontend/src/monitoring.jsx) mengelola ringkasan, pencarian, filter ekspeditur/status, pilihan truk, legenda, dan kontrol layar penuh.
3. [gerak_armada.js](https://github.com/akmalhidayah/web_tracker/blob/main/frontend/src/gerak_armada.js) memindahkan ikon truk demo di lintasan; posisi itu hanya berubah di browser. [peta_ringkas.js](https://github.com/akmalhidayah/web_tracker/blob/main/frontend/src/peta_ringkas.js) menggambar tile vektor OpenFreeMap dengan Canvas. Mode Detail dan fallback memakai tile raster OpenStreetMap.
4. [frontend/build.mjs](https://github.com/akmalhidayah/web_tracker/blob/main/frontend/build.mjs) membundel JS/CSS ke `monitoring/static/monitoring/app/`. Tidak ada server React terpisah untuk preview biasa.

### Laporan

| Bagian | Sumber |
| --- | --- |
| Judul, waktu, tabel ringkas | [laporan.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/laporan.html) dan `laporan()` di [views.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/views.py) |
| Grafik batang vertikal, garis ritase, dan grafik total | [grafik_laporan.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/grafik_laporan.py), [grafik_armada.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/grafik_armada.html), [batang_laporan.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/batang_laporan.html) |
| Kalender dan tabel harian `?tanggal=YYYY-MM-DD` | [riwayat_laporan.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/riwayat_laporan.py), [riwayat_armada.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/riwayat_armada.html), [baris_laporan_harian.html](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/templates/monitoring/partials/baris_laporan_harian.html) |
| Fixture dan target | [data_contoh.py](https://github.com/akmalhidayah/web_tracker/blob/main/monitoring/data_contoh.py): `LAPORAN`, `LAPORAN_HARIAN`, `TARGET_RITASE_CONTOH`, dan `WAKTU_CONTOH` |

Grafik dan tabel ringkas memakai cuplikan 17 November 2026 pukul 13.00 WITA. Kalender hanya mengubah tabel harian. Tabel harian menampilkan satu baris per ekspeditur dan total; rata-rata ritase = ritase ÷ unit operasi, muatan per ritase = volume ÷ ritase, dan capaian = realisasi ÷ target. Nilai yang tidak dapat dihitung tampil sebagai **—**.

## Aplikasi supir

| Bagian | Titik masuk | Alur dan catatan |
| --- | --- | --- |
| Bootstrap | [lib/main.dart](lib/main.dart), [lib/app/app_scope.dart](lib/app/app_scope.dart) | `AplikasiSupir` membuat `AppState` dengan `FakeTrackingService`; widget mendapat state melalui `AppScope`. |
| Rute dan penjagaan alur | [nama_rute.dart](lib/app/nama_rute.dart), [routes.dart](lib/app/routes.dart), [app_state.dart](lib/state/app_state.dart) | `lindungiRute` menyesuaikan layar dengan login, persetujuan, kesiapan, truk, dan sesi. Rute debug dan galeri hanya terbuka di build debug. |
| Pembuka dan login | [features/awal/](lib/features/awal/), [features/masuk/](lib/features/masuk/) | `LayarAwal` membuka panel login. `AppState.masuk` mencocokkan nomor dengan akun demo, bukan dengan Django. |
| Persetujuan dan kesiapan | [features/persetujuan/](lib/features/persetujuan/), [features/kesiapan/](lib/features/kesiapan/) | Ketentuan privasi dan pengaturan HP demo disimpan dalam state runtime. Tombol di layar kesiapan tidak mengubah izin perangkat sungguhan. |
| Armadanya supir | [features/pilih_truk/](lib/features/pilih_truk/), [features/beranda/](lib/features/beranda/), [dummy_data.dart](lib/data/dummy/dummy_data.dart) | Daftar truk disaring menurut vendor akun demo. QR adalah simulasi pemilihan unit. `AppState.bolehMulai` memeriksa semua syarat sesi. |
| Sesi dan ringkasan | [layar_sesi.dart](lib/features/sesi_aktif/layar_sesi.dart), [layar_ringkasan.dart](lib/features/ringkasan/layar_ringkasan.dart) | Sesi membaca `SnapshotSesi`, menampilkan status dan pengiriman simulasi, lalu menghasilkan `RingkasanSesi`. Ringkasan menampilkan tanggal, durasi, ritase, dan estimasi muatan. |
| Peta | [peta_sesi.dart](lib/features/peta/peta_sesi.dart), [layar_peta.dart](lib/features/peta/layar_peta.dart), [kontrol_peta.dart](lib/features/peta/kontrol_peta.dart) | Peta mini dan layar peta penuh, ikuti truk, perbesar seluruh rute, legenda dan filter warna tile. `KonfigurasiPeta` menyediakan `TANPA_TILE` dan `TILE_URL`. |
| Kontrak layanan | [tracking_service.dart](lib/data/services/tracking_service.dart), [fake_tracking_service.dart](lib/data/services/fake_tracking_service.dart), [konfigurasi_simulasi.dart](lib/data/services/konfigurasi_simulasi.dart) | Layanan demo membuat snapshot dengan waktu virtual, antrean dan konfirmasi kirim (ACK) di memori, serta mengelola sesi selesai/manual/otomatis. Adapter nyata kelak masuk lewat kontrak ini. |
| Aturan ritase | [mesin_ritase.dart](lib/data/services/mesin_ritase.dart), [lib/data/models/](lib/data/models/), [geo.dart](lib/core/utils/geo.dart) | Transisi memerlukan urutan muat → bermuatan → bongkar → keluar; cek posisi dalam area, akurasi, waktu berhenti, dan jeda data. Poligon pada fixture belum geofence resmi. |
| Desain bersama | [lib/core/theme/](lib/core/theme/), [lib/core/widgets/](lib/core/widgets/) | Warna, tipografi, ukuran, komponen UI dan logo. `BingkaiHp` membatasi lebar Flutter web ke 430 px. |
| Rilis dan aset | [pubspec.yaml](pubspec.yaml), [web/](web/), [android/](android/), [scripts/](scripts/) | Launcher Android legacy/adaptive, favicon dan manifest web berada di proyek ini. Build release Android masih memakai signing debug untuk demo. |
| Pengujian | [test/](test/) | `app_state_test.dart`: aturan alur. `alur_widget_test.dart`: layar dan interaksi. `fake_tracking_service_test.dart`: waktu, ritase, jeda, antrean dan ACK simulasi. Ada juga tes format dan kontras. |

### Titik perubahan yang sering dicari

| Jika ingin mengubah… | Mulai di… |
| --- | --- |
| Sidebar, login, dan tema web | Partial Django dan CSS biasa dashboard; login web supir adalah halaman Flutter yang berbeda. |
| Peta di halaman Monitoring | `frontend/src/monitoring.jsx` dan `dashboard.css`; build ulang jika JSX berubah. |
| Titik Muat/Bongkar atau jalur demo | `AREA`/`RUTE` di Python dan `titikMuat`/`titikBongkar`/`ruteHauling` di Dart. |
| Sumber angka laporan harian | `LAPORAN_HARIAN` dan `riwayat_laporan.py`; jangan isi tanggal tanpa catatan dengan cuplikan lama. |
| Beralih dari demo ke API | Tambahkan kontrak API Django dan adapter Flutter melalui `TrackingService`; pindahkan master akun dan penugasan sebelum mengandalkan laporan aktual. |
