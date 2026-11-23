# Handoff frontend Tracker Truk — 17 November 2026

## Audit kondisi awal

- Root yang digunakan: `tracker-tonasa/aplikasi_supir`, bukan proyek baru.
- Git sejak awal menunjukkan seluruh `aplikasi_supir/` sebagai **untracked**.
  Tidak dilakukan reset, clean, commit, push, deployment atau upgrade SDK.
- Tidak ditemukan AGENTS.md yang berlaku di workspace/parent yang diperiksa.
- Tersedia: tema/token, bingkai HP, model, fixture, geometri, format, logo asli,
  service/state parsial, dua berkas tes, template Android dan web.
- Belum tersedia: semua layar nyata, komponen UI selain bingkai, wiring
  AppScope/composition root, peta, debug, dan dokumentasi proyek.
- Baseline analyzer: error `Rute.masuk` pada main dan satu lint constructor.
- Baseline tes: **16 lulus, 1 gagal** — melintas cepat tanpa berhenti masih
  menghasilkan status bermuatan. Hasil awal dipisahkan dari hasil akhir.
- SDK lokal: Flutter 3.50.0 stable / Dart 3.14.0. Chrome tersedia;
  Android SDK tidak ditemukan. Tidak ada proses Flutter lama sebelum audit.
- PDF requirement lokal dibaca 13 halaman. Figma node 11:3 gagal diakses karena
  kuota MCP Starter; tidak mengulang panggilan berkuota. Tidak ada screenshot
  acuan/prompt lama/log lengkap di workspace. Visual mengikuti token tertulis.

## Hasil implementasi

Alur Masuk → Persetujuan → Kesiapan → Pilih truk → Beranda → Sesi → Peta →
Konfirmasi selesai → Ringkasan → Beranda sudah tersambung. Semua guard
penting berlaku di state, termasuk pemanggilan langsung dan rute langsung.
Saat izin hilang dalam sesi, layar sesi dan akses Selesai tetap tersedia.

Perbaikan inti:

- Komposisi FakeTrackingService hanya di main; UI membaca AppState/snapshot.
- Rekaman unik, pending nyata, ACK per batch, deduplikasi, pengiriman tunggal,
  arsip antrean lintas sesi, penghentian sebelum sinkronisasi, epoch reset.
- Clock virtual dengan timestamp/seq/durasi konsisten, percepatan 5×,
  pengingat 12 jam dan penghentian 16 jam tanpa menunggu waktu nyata.
- Ritase membutuhkan dwell diam berbasis timestamp, kualitas GPS, urutan
  lengkap, dua sampel keluar; jitter/duplikat tidak menambah hitungan.
- GPS/izin, baterai/charging, tile gagal dan upload offline dipisahkan.
- Peta mini/penuh, follow/manual pan, fit seluruh rute, poligon, jejak,
  radius akurasi meter, marker arah, fallback peta dasar, atribusi terbaca.
- Font lokal + lisensi, token warna/ukuran, UI Indonesia, scrolling dan
  pembatas overlay web. Galeri/debug hanya dapat diakses pada mode debug.

Ekspektasi tes antrean lama diperbaiki karena counter tiap 3 detik tidak
mewakili titik GPS yang sebelumnya dibuat tiap detik. Kini tes memeriksa
rekaman awal + setiap interval rekam, serta persamaan ACK + pending.
Tes transisi geofence disesuaikan untuk dua titik keluar (penahan jitter),
dan tetap menguji dwell minimum, lintasan cepat, kualitas dan pembatalan.

## Berkas utama

| Bagian | Lokasi |
|---|---|
| Entry point / lifecycle state | `lib/main.dart` |
| Rute / guard | `lib/app/routes.dart`, `lib/app/nama_rute.dart`, `lib/state/app_state.dart` |
| Kontrak integrasi | `lib/data/services/tracking_service.dart` |
| Simulasi / ACK / jam | `lib/data/services/fake_tracking_service.dart`, `konfigurasi_simulasi.dart` |
| Aturan ritase | `lib/data/services/mesin_ritase.dart` |
| Komponen bersama | `lib/core/widgets/komponen.dart` |
| Seluruh layar | `lib/features/` |
| Peta | `lib/features/peta/peta_sesi.dart` |
| Tes | `test/format_test.dart`, `fake_tracking_service_test.dart`, `app_state_test.dart`, `alur_widget_test.dart`, `kontras_test.dart` |
| Font dan lisensi | `assets/fonts/` |

## Batas integrasi

Frontend demo dalam memori. Belum ada backend, token autentikasi nyata,
GPS Kotlin/background, durable queue/Room, process-death/reboot recovery,
QR kamera, push notification, WhatsApp atau dashboard. Pengaturan perangkat
adalah konfirmasi simulasi. Data akan hilang saat refresh/restart/reset.
Ritase adalah hasil simulasi konservatif, bukan angka resmi operasional.
Kebijakan retensi dan kontrak API status/ritase masih perlu diputuskan.

Build Android dan background tracking belum diverifikasi karena Android SDK
belum tersedia. Kesamaan presisi terhadap frame Figma belum diverifikasi.
Panduan menjalankan dan skenario uji terdapat di README.

## Verifikasi sebelum perubahan visual lanjutan

- `flutter test --concurrency=1`: **41 lulus, 0 gagal**. Perintah ini
  dijalankan satu proses setelah tiga kegagalan gestur sebelumnya; tes gestur
  kini lulus pada semua ukuran/skala yang dicakup.
- `flutter analyze`: **No issues found** (pemeriksaan ulang setelah tes).
- `flutter build web --no-web-resources-cdn --no-wasm-dry-run`: berhasil pada
  pemeriksaan sebelum perubahan kecil akses fixture peta. Build ulang setelah
  perubahan itu tidak dijalankan karena beban laptop; Safari sudah berhasil
  menampilkan hasil build yang tersedia dari `aplikasi_supir/build/web`.
- Preview Safari melalui `python3 -m http.server 8732 --directory
  aplikasi_supir/build/web` dari root repository berhasil dibuka pengguna.
- Android build belum tersedia tanpa Android SDK. Presisi terhadap layer Figma
  tetap belum diverifikasi karena limit MCP Starter.

## Perubahan visual lanjutan — 17 November 2026

- Login tetap penuh tanpa kartu luar; komponen logo SIG–Tonasa kini dipakai
  bersama dengan header beranda dan sesi aktif.
- Aksen oranye diseragamkan, latar dibuat netral, ikon privasi/kesiapan/status
  dan statistik diberi bidang warna yang konsisten.
- Ilustrasi truk tambang transparan ditambahkan pada pilihan armada, thumbnail
  daftar truk, kartu beranda, dan header durasi sesi. Prompt ada di `ASSETS.md`.
- Kesiapan HP menampilkan progres dari state yang sama; alur pemilihan,
  izin, mulai/selesai sesi, dan penghitungan data tetap memakai logika sebelumnya.
- Hanya format Dart dan pemeriksaan sumber secara manual untuk perubahan ini.
  Sesuai permintaan pengguna, tes, analyzer, build, dan preview tidak dijalankan.
  Hasil verifikasi historis di atas tidak memverifikasi perubahan visual terbaru.
  Build web/APK perlu diperbarui oleh pengguna sebelum pengujian manual.

## Halaman pembuka sebelum login

- Rute awal `/` menampilkan `LayarAwal`: foto pengguna `start-bg.avif` yang
  dikonversi ke PNG, gradasi putih, logo SIG–Tonasa, teks, dan tombol Mulai.
- Tombol Mulai menuju `/masuk`. Pengguna yang sudah login tetap mengikuti
  guard persetujuan/kesiapan/sesi. Keluar akun tetap menuju form login.
- Konten dapat digulir pada layar pendek atau teks besar.
- Hanya format Dart dan peninjauan sumber; tidak menjalankan tes atau build.
- Uji manual setelah build: buka URL dasar `/`, tekan Mulai, isi login, lalu
  periksa alur berikutnya. Tes widget lama yang mengasumsikan form login
  langsung muncul saat aplikasi dibuka perlu disesuaikan bila tes dilanjutkan.

## Login berupa panel bawah dan animasi rute

- Halaman awal kini memakai kembali `bg_login.png`, sesuai pilihan terakhir
  pengguna. `bg_start.png` tetap tersimpan tetapi tidak ditampilkan.
- Mulai membuka modal login dari bawah dengan radius atas 32, pegangan geser,
  tombol tutup, serta penyesuaian keyboard dan konten yang dapat digulir.
  Rute `/masuk` membuka panel otomatis di atas halaman awal yang sama.
- Nomor HP dan PIN tetap divalidasi sebelum masuk ke persetujuan. Menutup
  panel mengembalikan pengguna ke halaman awal tanpa masuk akun.
- `AnimasiRute` melukis dua pin dan jalur berkontras putih/gelap/oranye di atas
  latar. Penanda bergerak selama 6 detik berulang; bukan data GPS pengguna.
  Animasi menghormati pengaturan reduce motion dan controller dibuang saat
  widget ditutup. Repaint terbatas pada kanvas, tanpa paket atau aset tambahan.
- Pemeriksaan hanya membaca sumber dan format Dart; tidak menjalankan
  analyzer, tes, build, atau preview. Uji manual: buka/tutup panel berulang,
  tombol kembali, keyboard, PIN salah, login berhasil, dan skala teks besar.

## Ikon Android dan web

- Ikon Flutter memakai gambar `icontrackerapp.png` pengguna. Master disimpan dalam
  proyek, lengkap dengan skrip pembentukan ukuran tanpa dependensi baru.
- Android memakai mipmap legacy dan adaptive icon untuk API 26+; roundIcon
  menunjuk sumber yang sama. Web memakai favicon, Apple touch icon, dan
  ikon manifest biasa/maskable yang baru.
- Metadata instalasi web menjadi Tracker Truk – Semen Tonasa dengan tema
  oranye. URL ikon web memakai versi untuk membedakan dari favicon lama.
- Dimensi PNG, referensi manifest, dan sintaks JSON/XML diperiksa. Tidak ada
  tes aplikasi atau build dijalankan. Perlu build APK/web ulang untuk memasukkan
  perubahan; aplikasi yang terpasang sebelumnya perlu diperbarui.

## Persetujuan ringkas dengan rincian dalam panel bawah

- Empat kartu menampilkan judul dan ringkasan; ketuk kartu untuk membuka
  penjelasan lengkap dalam modal bawah dengan sudut membulat dan tombol tutup.
- Informasi jenis data, waktu mulai/selesai, batas 16 jam, tujuan, retensi demo,
  dan data yang tidak direkam tetap tersedia. Mengerti hanya menutup rincian.
- Panel tindakan terpisah di bawah berisi centang persetujuan, Setuju dan
  lanjut, serta Tidak setuju. Penolakan keluar akun dan kembali ke halaman awal.
- Panel tindakan ikut digulir pada layar pendek atau skala teks besar agar
  kartu tidak kehilangan ruang baca. Tampilan memakai ilustrasi ikon perisai
  dan logo perusahaan, tanpa aset raster atau dependensi baru.
- Hanya format Dart dan peninjauan sumber; tes/build tidak dijalankan sesuai
  permintaan pengguna. Periksa manual empat rincian, tutup/geser panel,
  persetujuan belum dicentang, penolakan, dan lanjut ke kesiapan HP.

## Koreksi latar start dan kejelasan animasi

- Halaman start dikembalikan ke `bg_start.png` (sumber `start-bg.avif`), bukan
  ilustrasi `bg_login.png`, sesuai koreksi pengguna.
- Titik kecil di rute diganti badge truk dengan gelombang oranye, bergerak
  berulang setiap 4 detik. Tombol Putar/Jeda kemudian dihapus atas permintaan
  pengguna.
- Versi sebelumnya menampilkan rute diam jika perangkat meminta reduce
  motion. Default ini tetap dihormati. Pengaturan perangkat pengguna
  tidak diperiksa, jadi belum dikonfirmasi sebagai penyebab laporan animasi diam.
- Format Dart dan sumber diperiksa; tidak menjalankan tes/build/preview.

## Kesiapan HP dalam kartu dua kolom

- Header dipusatkan dengan ilustrasi telepon dan progres dinamis `n/5`.
- Empat pengaturan awal ditampilkan sebagai kartu dua kolom; GPS menjadi kartu
  selebar baris agar lima pengaturan tetap seimbang. Status siap/belum memakai
  warna semantik dan mengikuti state yang sama dengan guard sesi.
- Ketuk kartu untuk membuka instruksi lengkap pada panel bawah. Tombol di
  panel tetap hanya menyimulasikan pengaturan; tidak mengubah izin asli HP.
- Lanjut tetap aktif hanya jika lima pengaturan siap. Tombol ditempatkan pada
  panel bawah, dan ikut bergulir pada layar pendek/skala teks besar.
- Hanya format Dart dan pemeriksaan sumber; tes/build tidak dijalankan sesuai
  permintaan pengguna.

## Pengikatan nomor lambung ke vendor

- Tiap `Truk` kini memiliki `vendorId`, dan tiap `Vendor` mempunyai `id` stabil.
  Data contoh mengikat seluruh nomor lambung ke salah satu dari empat vendor.
- Akun supir menyimpan vendor. Daftar pilihan dan QR simulasi mengambil hanya
  truk milik vendor tersebut; state juga menolak pemilihan truk beda vendor.
- Kartu pilihan dan kartu truk beranda menampilkan nama vendor singkat.
- Ini masih konfigurasi demo dari `DummyData`. Ketika admin/backend tersedia,
  data akun, vendor, dan nomor lambung perlu diisi dari layanan admin dengan
  ID yang sama. Belum ada sinkronisasi admin atau pergantian armada waktu nyata.
- Hanya format dan pemeriksaan sumber; tidak menjalankan tes atau build.

## Ringkasan sesi mengikuti istilah laporan armada

- Layar ringkasan menampilkan ekspeditur, nomor lambung, tanggal/jam mulai
  dan selesai dari sesi, durasi, jumlah ritase, kapasitas truk per ritase,
  serta estimasi muatan (`ritase × kapasitasTon`). Estimasi diberi label jelas
  karena aplikasi belum mengukur berat muatan aktual.
- Titik terkirim, ACK, antrean pending, dan riwayat teknis tidak lagi tampil
  dalam ringkasan supir. Data sinkronisasi tetap ada di service/state untuk
  kebutuhan teknis dan integrasi admin nanti. Teks ACK di sesi aktif juga
  diganti informasi sinkronisasi terakhir tanpa jumlah titik.
- Format tanggal/jam mengikuti zona waktu lokal perangkat dan nama bulan
  Indonesia; kedua timestamp berasal dari sesi yang direkam, bukan tanggal
  laporan statis November 2026.
- Hanya format Dart dan pemeriksaan sumber; tidak menjalankan tes atau build.
