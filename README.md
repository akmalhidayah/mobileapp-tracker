# Tracker Truk — aplikasi supir (demo frontend)

Flutter Android dengan preview melalui Chrome. Semua nomor, koordinat, ritase,
izin, dan pengiriman adalah simulasi. Tidak ada backend, autentikasi nyata,
GPS native/background, kamera QR, notifikasi native, atau dashboard web terpisah.

## Menjalankan

Lingkungan yang digunakan: Flutter **3.50.0**, Dart **3.14.0**. Gunakan versi
terkunci `pubspec.lock`; tidak perlu meng-upgrade SDK atau paket.

```sh
flutter pub get
flutter run -d chrome
```

Jalankan perintah di atas dari root repo ini. Untuk membuka hasil build web
tanpa menjalankan Flutter terus-menerus:

```sh
flutter build web --no-wasm-dry-run --no-web-resources-cdn
python3 -m http.server 8732 --bind 127.0.0.1 --directory build/web
```

Buka `http://127.0.0.1:8732` di browser. Untuk APK demo jalankan
`flutter build apk --release`; hasilnya ada di
`build/app/outputs/flutter-apk/app-release.apk`.

Nomor demo: `081234567890`; PIN: `123456`. Semua nomor berformat 10–15 digit
(setelah separator spasi, +, titik, kurung, dan tanda hubung dibuang) dan PIN
tepat 6 digit diterima. PIN tidak disimpan di state atau dicetak ke log.

1. Masuk, baca empat penjelasan privasi, centang persetujuan.
2. Pada Kesiapan HP, tekan **Atur → Simulasikan sudah diatur** untuk setiap
   item yang belum siap. Notifikasi dan GPS awalnya siap.
3. Pilih truk sesuai vendor akun demo, atau gunakan tombol scan QR simulasi.
4. Di Beranda, tekan **Mulai**. Perekaman dimulai hanya setelah semua syarat
   lolos di state. Ganti truk dan logout diblok selama sesi.
5. Perbesar peta, geser untuk melepas follow, gunakan **Ikuti saya** atau
   **Lihat seluruh rute**. Back kembali tanpa mengganti sesi.
6. **Selesai sesi → Ya, selesai** menghentikan sesi. Ringkasan menampilkan
   vendor, truk, waktu mulai/selesai, durasi, ritase, dan estimasi muatan.

Preview web dibatasi 430 px, termasuk dialog, snackbar dan bottom sheet.
Font Inter dan Space Grotesk tersedia lokal di `assets/fonts/`, dengan lisensi
SIL OFL masing-masing. Logo asli menggunakan aset yang sudah ada.

## Skenario debug

Hanya pada build debug: ketuk logo di Masuk lima kali, atau ikon serangga
pada Sesi aktif / Ringkasan. Rute debug dan galeri dilindungi pada release.

- **GPS mati / izin dicabut**: durasi lanjut, posisi terakhir usang, tidak ada
  rekaman baru. Pulihkan kondisi untuk melanjutkan seq; jeda ditandai.
- **Tile peta gagal**: peta dasar hilang, poligon/rute/marker tetap ada.
  Kondisi ini terpisah dari GPS dan pengiriman.
- **Upload offline / gagal**: pending tetap tersimpan; selesaikan sesi,
  matikan kondisi offline dari debug Ringkasan, lalu coba kirim lagi.
- **Baterai rendah** + **Sedang dicas** nonaktif: banner muncul pada <15%.
- **Percepatan 5×**: waktu virtual bergerak lima detik setiap detik nyata.
- **Lompat ke 12 jam**: pengingat persisten sekali per sesi.
- **Lompat ke 16 jam**: sesi berakhir otomatis, termasuk ketika offline.
  Lompatan bukan ribuan rekaman palsu: data yang dilewati ditandai sebagai jeda.
- **Reset demo**: hentikan timer, hapus seluruh data dan kontrol simulasi.
  ACK yang datang setelah reset tidak boleh memengaruhi sesi baru.

## Waktu, antrean, dan ritase

`KonfigurasiSimulasi` memisahkan interval rekam dan upload. Pada demo, tick
perjalanan 1 detik virtual, rekam **1 detik**, upload **30 detik**, berhenti
sekitar **5 detik** di tiap ujung rute. Siklus penuh sekitar 74 detik virtual.
Interval rekam 1 detik dipilih agar dwell pendek benar-benar didukung beberapa
rekaman, bukan counter antrean yang berbeda dari jejak. Setiap titik pada jejak
adalah rekaman; tidak ada titik interpolasi yang dihitung sebagai rekaman.

Target requirement untuk integrasi nanti: rekam bergerak 30 detik; idle 120
detik setelah diam 2 menit; upload 180–300 detik. Konfigurasi demo tidak
mengimplementasikan penjadwalan idle produksi. Kecepatan 28–36 km/j adalah
angka contoh; perpindahan peta dipercepat dan bukan kecepatan fisik terukur.

Rekaman memiliki `(sessionId, seq, timestamp)` unik. Jam diinjeksi dan
`maju()`/`lompatKe()` menggunakan clock virtual yang sama. Untuk setiap sesi:
`total rekaman = ACK unik + pending`. Jejak renderer dibatasi 200 titik,
sedangkan pending tetap utuh. Upload tunggal memakai salinan batch; ACK
parsial hanya menghapus ID yang ada di batch tersebut. Pending sesi lama
bertahan ketika sesi baru dimulai, dan pengiriman ulang tidak menyalakan GPS.

Mesin ritase memerlukan urutan muat → bermuatan → bongkar → keluar bongkar.
Dwell di fixture minimum 4 detik berdasarkan timestamp dan kecepatan ≤1 m/s
(asumsi demo). Akurasi >30 m tidak dipakai untuk transisi. Dua titik keluar
berturut-turut menahan jitter; timestamp berulang diabaikan. Kembali ke muat
membatalkan siklus lama. Jeda/akurasi buruk membatalkan bukti siklus secara
konservatif dan menandai **perlu dicek**. Backend kelak melakukan rekonsiliasi
lebih lengkap sesuai requirement; muatan tidak diteruskan lintas sesi.
Empat titik berjarak 30 detik hanya membentang 90 detik, bukan dua menit.

Semua data berada **dalam memori**. Refresh/restart menghapus login, persetujuan,
sesi dan pending. Logout menghapus persetujuan; antrean runtime tetap ada
sampai ACK/reset. Tidak ada klaim antrean tujuh hari atau recovery process death.

## Peta dan acuan

Simulasi mengikuti rute dashboard dari Limestone Crusher 2 ke Biringkassi
berdasarkan data jalan OpenStreetMap dan hasil mapping kedua pin. Sambungan
dari jalan ke pin dan batas area untuk menghitung ritase adalah ilustrasi.
Jarak tujuan diukur secara garis lurus dari posisi truk simulasi ke pin tujuan.

Ketuk **Perbesar peta** pada sesi aktif untuk membuka peta interaktif. Di layar
itu tersedia **Ikuti saya**, **Lihat seluruh rute**, serta ikon lapisan untuk
beralih dari warna lembut ke detail asli. **Legenda** di kanan bawah menjelaskan
warna titik status dan simbol peta.

URL tile terpusat di `KonfigurasiPeta`, default HTTPS OpenStreetMap. Atribusi
terbaca di peta. App ID native diberikan melalui `userAgentPackageName`;
browser menggunakan header browser dan Referer, bukan klaim header kustom.
Tidak ada fitur prefetch atau download massal. Penyedia produksi, kontak,
cache dan kapasitas penggunaan perlu diputuskan saat integrasi.
Lihat [kebijakan tile OSM](https://operations.osmfoundation.org/policies/tiles/)
dan [hak cipta OSM](https://www.openstreetmap.org/copyright).

Untuk preview/test tanpa meminta tile:

```sh
flutter run -d chrome --dart-define=TANPA_TILE=true
# Atau ganti penyedia yang telah disetujui:
flutter run -d chrome --dart-define='TILE_URL=https://provider.example/{z}/{x}/{y}.png'
```

Requirement lokal `../../Requirement Desain.pdf` (13 halaman, 17 November 2026)
telah dibaca. Acuan Figma `QvwJVstd7tA4jpHBvBS1VF / 11:3` terkena limit MCP
Starter pada audit. Screenshot visual awal/prompt Claude/log lengkap tidak
tersedia di workspace. Implementasi menggunakan token tertulis dan aset asli;
kesamaan ukuran layer Figma belum diverifikasi.

## Pemeriksaan

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
```

Tes menggunakan clock dan pengirim dummy tanpa waktu nyata, tile jaringan,
atau unduhan font. Matriks widget mencakup 360/390/430 px dan skala teks
1,0/1,3, keyboard, sheet, dialog, peta, Back, offline dan ringkasan.
`--no-web-resources-cdn` menyertakan renderer web lokal; tile tetap online
kecuali dinonaktifkan. Build web tidak membuktikan background GPS Android.

## Titik integrasi berikutnya

### Menyiapkan build APK pada Mac Intel

Jika muncul `No Android SDK found` dan Java juga belum terpasang, dari root
repo ini jalankan:

```sh
bash scripts/setup_android_macos.sh
```

Skrip menyiapkan Temurin Java 21 dan Android SDK di folder Library pengguna,
memverifikasi checksum unduhan, dan meminta Anda membaca/menyetujui lisensi.
Tidak memasang Android Studio atau emulator; unduhan termasuk NDK bisa
melebihi 1 GB. Lokasi Java/SDK disimpan melalui `flutter config`.
Skrip ini disediakan untuk menyiapkan mesin pengembang baru.

Setelah pemasangan selesai, jalankan sendiri:

```sh
flutter build apk --release
```

APK demo berada di `build/app/outputs/flutter-apk/app-release.apk`.
Build release saat ini memakai signing key debug bawaan template untuk
instalasi demo; signing distribusi produksi belum dikonfigurasi.
Gradle dibatasi satu worker dan heap 2 GB agar lebih sesuai laptop RAM 8 GB;
batas heap tersebut bukan batas total memori seluruh proses build.

Rujukan: [Android SDK](https://developer.android.com/tools/sdkmanager),
[arsip Temurin](https://adoptium.net/installation/archives).

### Integrasi produksi

- Ganti `FakeTrackingService` di composition root `main.dart` dengan adapter
  MethodChannel/EventChannel ke service Kotlin; layar tetap membaca AppState.
- Native: izin asli, foreground location service, Room/durable queue, recovery
  proses/reboot, pengaturan merek HP dan uji Doze/perangkat nyata.
- Backend: token supir, batch/ACK idempoten, konfigurasi interval, data master,
  aturan ritase resmi, rekonsiliasi kualitas/jeda dan siklus lintas sesi.
- Putuskan kontrak status/ritase aplikasi supir: respons upload contoh PDF
  baru memberikan ACK/config, belum kontrak lengkap status resmi.
- Finalisasi kebijakan penyimpanan/persetujuan bersama perusahaan.
- Dashboard Django/HTMX/Leaflet dikerjakan terpisah.

Lihat `docs/HANDOFF.md` untuk bukti pemeriksaan dan status terakhir.
