# Laporan Praktikum Pemrograman Mobile
## Minggu 13: CI/CD dan Otomatisasi (*CI/CD Automation*)

**Identitas Mahasiswa:**
- **Nama:** Muhammad Aqil Azami
- **NIM:** 244107020128
- **Kelas:** TI-3H
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Teknologi Informasi - Politeknik Negeri Malang
- **Mata Kuliah:** Praktikum Pemrograman Mobile
- **Semester:** Ganjil 2026/2027

---

## 1. Ringkasan Praktikum

Pada praktikum Minggu ke-13 ini, saya menerapkan otomatisasi pipeline **Continuous Integration & Continuous Delivery/Deployment (CI/CD)** pada project Flutter `campus_notify` menggunakan **GitHub Actions**.

Tujuan utama dari otomatisasi ini adalah:
1. Memastikan setiap perubahan kode yang di-push atau diajukan melalui Pull Request teruji secara konsisten tanpa pemeriksaan manual yang rentan terlewat.
2. Menjalankan formatting kode, analisis statis (*linter*), dan seluruh unit/widget test secara otomatis.
3. Mengompilasi aplikasi Android menjadi artefak siap pakai, yaitu **APK (`.apk`)** untuk pengujian internal dan **App Bundle (`.aab`)** untuk rilis Google Play Store.
4. Menerapkan manajemen versi (*Semantic Versioning*) dan prinsip keamanan penanganan berkas rahasia (*secrets management*).

---

## 2. Struktur Pipeline GitHub Actions (`.github/workflows/flutter-ci.yml`)

Workflow pipeline ditempatkan di root repository pada `.github/workflows/flutter-ci.yml` dengan konfigurasi utama sebagai berikut:

### a. Event Trigger & Permission
```yaml
name: Flutter CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```
- **Trigger:** Berjalan otomatis saat ada `push` ke branch `main`, saat pembukaan `pull_request` menuju `main`, atau dijalankan manual melalui `workflow_dispatch`.
- **Permission (`contents: read`):** Menerapkan prinsip *least privilege*, di mana job CI hanya memerlukan izin membaca source code tanpa izin menulis ke repository.
- **Concurrency:** Membatalkan (*cancel-in-progress*) build yang sedang berjalan jika ada commit baru pada branch/PR yang sama untuk menghemat alokasi runner.

### b. Tahapan Eksekusi (*Pipeline Steps*)
Pipeline dijalankan di atas runner `ubuntu-latest` dengan urutan:
1. **Checkout Repository:** Mengambil source code project menggunakan `actions/checkout@v4`.
2. **Setup Java 17:** Mengonfigurasi Temurin JDK 17 menggunakan `actions/setup-java@v4` sebagai prasyarat build Gradle Android.
3. **Setup Flutter SDK:** Memasang Flutter SDK channel `stable` menggunakan `subosito/flutter-action@v2`.
4. **Install Dependencies:** Menjalankan `flutter pub get` untuk mengunduh semua package.
5. **Code Formatting:** Menjalankan `dart format --output=none --set-exit-if-changed lib test` untuk memastikan kepatuhan gaya kode resmi Dart.
6. **Static Analysis:** Menjalankan `flutter analyze --no-fatal-infos --no-fatal-warnings` untuk memastikan tidak ada error logika atau pelanggaran linter.
7. **Automated Testing & Coverage:** Menjalankan `flutter test --coverage` untuk mengeksekusi seluruh 53 unit, widget, dan service test serta menghasilkan `coverage/lcov.info`.
8. **Build Android APK:** Menjalankan `flutter build apk --release` untuk menghasilkan file biner APK (`build/app/outputs/flutter-apk/app-release.apk`).
9. **Build Android App Bundle:** Menjalankan `flutter build appbundle --release` untuk menghasilkan berkas distribusi AAB (`build/app/outputs/bundle/release/app-release.aab`).
10. **Upload Artifacts:** Menyimpan berkas APK dan AAB ke penyimpanan GitHub Actions menggunakan `actions/upload-artifact@v4` dengan nama `android-builds` dan masa simpan (*retention*) selama 7 hari.

---

## 3. Strategi Versioning (Semantic Versioning)

Pada berkas `pubspec.yaml`, versi aplikasi diatur dengan format Semantic Versioning:
```yaml
version: 1.3.0+1
```

### Penjelasan Format:
- **`1` (Major):** Diperbarui ketika ada perubahan arsitektur besar yang merusak kompatibilitas ke belakang (*breaking changes*).
- **`3` (Minor):** Diperbarui saat penambahan fitur baru yang tetap kompatibel (dalam hal ini merepresentasikan pencapaian modul Minggu 13).
- **`0` (Patch):** Diperbarui saat ada perbaikan bug kecil tanpa menambah fitur baru.
- **`+1` (Build Number / Version Code):** Angka integer bertambah (*incremental*) untuk setiap kompilasi rilis ke Play Store.

### Rencana Versi Berikutnya:
- Jika terdapat perbaikan minor pada pipeline atau perbaikan bug validasi tugas: versi akan dinaikkan menjadi `1.3.1+2` (patch release).
- Jika ada penambahan fitur modul baru (misalnya modul autentikasi biometrik): versi akan dinaikkan menjadi `1.4.0+3` (minor release).
- Penandaan Git Tag seperti `v1.3.0` digunakan pada commit stabil yang sudah lolos uji CI untuk menghubungkan riwayat commit dengan artefak build yang dihasilkan.

---

## 4. Keamanan, Secrets, dan Pengelolaan Konfigurasi

1. **GitHub Actions Secrets:**  
   Material sensitif seperti Android Keystore (`.jks`), password keystore, key alias, dan token autentikasi API privat tidak boleh dimasukkan ke dalam commit repository. Seluruh data tersebut wajib disimpan di **Repository Secrets (Settings -> Secrets and variables -> Actions)** dan diinjeksikan saat build melalui environment variable.
2. **Keterbatasan `--dart-define`:**  
   Nilai yang disisipkan melalui `--dart-define` atau `--dart-define-from-file` akan dikompilasi langsung ke dalam biner APK/AAB klien. Siapa pun dapat mengekstrak string tersebut menggunakan alat *reverse engineering* (seperti `jadx` atau `apktool`). Oleh karena itu, `--dart-define` hanya cocok untuk konfigurasi publik (seperti Base URL API atau nama environment), **bukan untuk token privat atau kunci rahasia perbankan/database**.
3. **Isolasi Workflow Pull Request:**  
   Workflow yang dipicu oleh pull request dari repository fork secara otomatis tidak diberikan akses ke GitHub Secrets untuk mencegah kebocoran kunci rahasia (*credential leakage*).

---

## 5. Hasil Pengujian & Eksekusi Pipeline

### 1. Pengujian Lokal di Terminal
- **`flutter analyze`:**
  ```text
  Analyzing 13-week-13-ci-cd-automation...
  No issues found!
  ```
- **`flutter test --coverage`:**
  ```text
  00:07 +53: All tests passed!
  ```
  Seluruh 53 skenario uji (Unit, Mock/Fake Repository, Widget, dan Performance) berhasil lolos 100%.

### 2. Artefak yang Dihasilkan
| Format | Lokasi Berkas Output | Kegunaan |
| :--- | :--- | :--- |
| **APK Release** | `build/app/outputs/flutter-apk/app-release.apk` | Pengujian mandiri, sideloading langsung ke perangkat Android tim QA/dosen. |
| **AAB Release** | `build/app/outputs/bundle/release/app-release.aab` | Format resmi upload distribusi ke Google Play Console (Play Store). |

---

## 6. Jawaban Pertanyaan Refleksi (Step 5)

### 1. Masalah apa yang ditemukan otomatis sebelum perubahan di-merge?
Pipeline CI secara otomatis mendeteksi:
- **Kegagalan Unit & Widget Test:** Jika ada perubahan kode yang merusak fitur lama (*regression*), test otomatis akan langsung mendeteksi kegagalan tersebut dan menghentikan pipeline.
- **Ketidaksesuaian Format Kode (`dart format`):** Menjaga standardisasi penulisan kode antar anggota tim tanpa perlu debat saat code review.
- **Kesalahan Analisis Statis & Tipe Data (`flutter analyze`):** Mendeteksi variabel yang tidak terpakai, potensi *null pointer exception*, atau dependensi *deprecated*.
- **Kerusakan Build Android / Gradle:** Memastikan project tetap dapat dikompilasi menjadi APK/AAB sebelum kode digabungkan ke branch utama (`main`).

### 2. Informasi apa yang Anda butuhkan untuk menyelidiki build yang gagal?
Informasi kunci yang dibutuhkan saat melakukan investigasi (*debugging*) build yang gagal:
1. **Nama Step yang Gagal:** Mengetahui secara tepat apakah kegagalan terjadi pada tahap `pub get`, `dart format`, `flutter analyze`, `flutter test`, atau `flutter build`.
2. **Detail Log & Stack Trace:** Membaca pesan error keluaran terminal pada step tersebut (misalnya baris file yang formatting-nya salah atau assertion test yang gagal).
3. **Commit Hash & Author:** Mengetahui perubahan kode spesifik mana yang memicu kegagalan dan siapa yang melakukan commit.
4. **Environment Runner:** Memeriksa versi Flutter SDK, Dart SDK, dan Java JDK yang digunakan runner di GitHub Actions untuk memastikan tidak ada perbedaan kompatibilitas dengan lingkungan lokal.

### 3. Bagian mana yang masih perlu persetujuan atau pemeriksaan manual sebelum rilis?
Meskipun CI/CD mengotomatiskan pengujian dan build, rilis ke pengguna akhir tetap membutuhkan pemeriksaan manual (*manual gate / approval*) pada:
1. **Pengujian Pengalaman Pengguna (UX & Real Device Testing):** Memastikan tampilan antarmuka, kehalusan animasi, dan responsivitas terasa nyaman saat digunakan langsung di berbagai tipe layar fisik smartphone.
2. **Persetujuan Penandatanganan Rilis (*Signing Approval*):** Memastikan aplikasi ditandatangani menggunakan sertifikat produksi (*release keystore*) yang sah oleh penanggung jawab rilis.
3. **Kepatuhan Kebijakan Toko Aplikasi (*Store Compliance*):** Memeriksa deskripsi aplikasi, tangkapan layar toko, kebijakan privasi (*privacy policy*), dan catatan perubahan rilis (*release notes / changelog*) sebelum dipublikasikan ke Google Play Store.
