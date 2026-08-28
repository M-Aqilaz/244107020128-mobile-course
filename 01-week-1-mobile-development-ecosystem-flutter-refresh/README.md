# Minggu 1 — Mobile Development Ecosystem & Flutter Refresh

## Tujuan
Memahami ekosistem pengembangan mobile (native, hybrid, cross-platform),
arsitektur Flutter, peran Dart, widget tree, hot reload/restart,
dan dasar Dart (null safety).

## Fitur utama
Aplikasi profil mahasiswa sederhana:
- `AppBar` berjudul "Profil Mahasiswa"
- Ikon `Icons.school` (size 72)
- Teks nama: **Muhammad Aqil Azami**
- Teks sub: "Pemrograman Mobile - Minggu 1"

## Stack teknologi
- Flutter 3.47.1 (stable)
- Dart (null safety)
- Material Design 3

## Cara menjalankan
```bash
flutter pub get
flutter run
```
Pastikan `flutter devices` menampilkan minimal satu target
(emulator atau perangkat fisik dengan USB debugging).

## Hasil yang dicapai
- Project Flutter pertama berjalan
- Mengubah UI default menjadi profil mahasiswa
- Memahami hot reload vs hot restart (lihat bawah)
- Repository diinisialisasi & diunggah ke GitHub

## Hot Reload vs Hot Restart
- **Hot reload**: menyuntikkan ulang source code yang berubah ke Dart VM,
  lalu membangun ulang widget tree dari posisi state saat ini. State
  (nilai variabel, halaman terbuka) **tetap utuh**. Cocok saat ubah tampilan
  / layout kecil. Di terminal: tekan `r`.
- **Hot restart**: mematikan & menjalankan ulang aplikasi dari awal, men-reset
  seluruh state ke nilai awal. Dipakai bila perubahan menyentuh `initState`,
  global variable, atau state tidak ke-update saat hot reload. Di terminal:
  tekan `R` (kapital).
- Praktikum: ubah ikon/teks lalu bandingkan — hot reload cepat & state tetap;
  ubah nilai awal lalu hot restart untuk lihat reset.

## Mini Assignment
Aplikasi profil mahasiswa diperluas dengan widget dasar (tanpa package eksternal):
- **NIM**: ditambah baris `Text('NIM: 244107020128')` di dalam `Row` + `Icon(Icons.badge)`.
- **Info tambahan**: `Text('Teknik Informatika')` (Row + `Icon(Icons.computer)`),
  serta email `muhaaqil6002@gmail.com` sebagai teks italic abu-abu.
- **Widget dipakai**: `Card`, `Padding`, `Column`, `Row`, `SizedBox`, `Icon`, `Text`.
- `AppBar` + `Icons.school` + nama tetap dipertahankan.
- File: `lib/main.dart` (lihat body `Scaffold`).

## Kendala Setup
Satu kendala nyata: **OneDrive memblokir proses build** (MSBuild/tooling
Windows tidak bisa menulis ke dalam folder yang disinkronkan OneDrive).
Akibatnya `flutter build` / `flutter run` tidak bisa dijalankan dari dalam
folder `OneDrive/Documents/...` ini.

Solusi jujur: source tetap di repo ini untuk version control & pengumpulan,
sedangkan build/run dilakukan di folder di luar OneDrive (mis. `C:\flutter_course\week1`).
Validasi yang berhasil di environment ini: `flutter analyze` → **No issues found!**
Build/emulator belum dijalankan di sini karena keterbatasan tersebut di atas.

> GAP: screenshot hasil aplikasi belum di-capture (tidak ada emulator/display
> di environment). Jalankan sendiri:
> ```bash
> cd 01-week-1-mobile-development-ecosystem-flutter-refresh
> flutter run
> ```
> lalu screenshot ke `screenshots/profile.png`.

## Bukti visual
- `screenshots/` — capture hasil aplikasi di device/emulator
