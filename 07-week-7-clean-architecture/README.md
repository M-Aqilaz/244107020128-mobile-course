# Laporan Praktikum Minggu 7: Clean Architecture

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Clean Architecture & Refactoring Feature-First  

### Identitas Mahasiswa
- **Nama:** Muhammad Aqil Azami  
- **NIM:** 244107020128  
- **Kelas:** TI-3H  
- **Program Studi:** D-IV Teknik Informatika  
- **Jurusan:** Jurusan Teknologi Informasi - Politeknik Negeri Malang  

---

## 1. Deskripsi & Tujuan Praktikum

Di jobsheet Minggu 7 ini, saya melakukan refactoring (penataan ulang kode) pada project **Campus Notify** yang sebelumnya sudah dikerjakan di Minggu 6. 

Alasan utama dilakukannya refactor ini karena pada kode lama semuanya masih tercampur jadi satu:
- Widget di UI masih manggil penyimpanan secure storage dan parsing data secara langsung.
- Interface dan implementasi repository masih disatukan dalam satu file.
- Logika bisnis dan formatting teks masih nempel di dalam method `build()` widget.

Melalui praktikum ini, struktur kode dirapikan menjadi struktur **Feature-First** dan dipisahkan ke dalam 3 layer utama: **Presentation**, **Domain**, dan **Data**, dengan mengikuti aturan **Dependency Rule** (panah ketergantungan hanya boleh mengarah ke dalam).

---

## 2. Diagram Layer & Arah Dependensi

Prinsip utama Clean Architecture adalah layer **Domain** harus murni berdiri sendiri tanpa tahu implementasi teknis di luarnya (baik itu framework Flutter, database, maupun HTTP client).

```text
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│   (Halaman UI, Widget, Riverpod Notifier, GoRouter)    │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ (bergantung ke)
                            ▼
┌────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                      │
│   (Entity bisnis, Interface Repository, Use Cases,     │
│    Failure)  --> Murni Dart (tanpa import Flutter)     │
└───────────────────────────▲────────────────────────────┘
                            │
                            │ (mengimplementasikan kontrak)
                            │
┌───────────────────────────┴────────────────────────────┐
│                       DATA LAYER                       │
│   (Model JSON/SQLite, Implementasi Repository,         │
│    TokenStore, Secure Storage, Dio/HTTP)               │
└────────────────────────────────────────────────────────┘
```

### Poin Penting Aturan Dependensi:
1. **Domain itu Inti:** File di dalam folder `domain/` sama sekali tidak boleh ada import `package:flutter`, `package:dio`, `package:sqflite`, ataupun `package:firebase`.
2. **Dependency Inversion (DIP):** Presentation dan Data sama-sama bergantung ke Domain. Layer Data hanya bertugas memenuhi kontrak (*interface*) yang sudah dibuat oleh Domain.
3. **Dependency Injection (DI):** Di dalam widget UI tidak boleh ada instansiasi manual seperti `new AuthRepository()`. Semua kebutuhan objek disuntikkan lewat Provider Riverpod.

---

## 3. Tabel Audit File Lama (Praktikum 1 - Step 2)

Berikut adalah catatan hasil audit file lama project `campus_notify` sebelum direfactor, beserta masalahnya dan ke mana file tersebut dipindahkan:

| File Lama | Layer Awal | Masalah yang Ditemukan | Solusi & Lokasi Baru |
| :--- | :--- | :--- | :--- |
| `lib/pages/login_page.dart` | Presentation | Validasi input login dan logic auth masih nyampur di form UI. | Dipindah ke `lib/features/auth/presentation/pages/login_page.dart`. Validasi input diserahkan ke `LoginUseCase`. |
| `lib/pages/home_page.dart` | Presentation | Format tanggal dan masking token langsung ditulis di dalam widget. | Dipindah ke `lib/features/home/presentation/pages/home_page.dart`. Fungsi format dipindah ke `lib/core/format.dart`. |
| `lib/pages/announcement_detail_page.dart` | Presentation | Menampilkan data mentah tanpa entitas domain yang jelas. | Diubah jadi `lib/features/announcements/presentation/pages/announcement_page.dart` memakai entity domain. |
| `lib/data/auth_repository.dart` | Data + Kontrak | Interface dan fungsi secure storage dijadikan satu kelas konkret. | Dipecah: interface di `domain/repositories/auth_repository.dart`, implementasi di `data/repositories/auth_repository_impl.dart`. |
| `lib/providers/auth_provider.dart` | Presentation | Notifier mengakses storage langsung tanpa lewat abstraksi repository. | Direfaktor di `features/auth/presentation/providers/auth_providers.dart` lewat usecase dan interface repository. |
| `lib/messaging/push_service.dart` | Infrastructure | Service push notification FCM masih bercampur dengan rute aplikasi. | Dipindah ke `features/notification/messaging/push_service.dart` dan di-wire lewat provider. |

---

## 4. Struktur Folder Project Setelah Refactor

Struktur folder project yang sudah diubah ke format **Feature-First**:

```text
lib/
├── core/
│   ├── failures.dart                                  # Sealed class Failure murni Dart
│   └── format.dart                                    # Fungsi format tanggal & sensor token
├── features/
│   ├── announcements/
│   │   ├── data/
│   │   │   ├── models/announcement_model.dart         # Model JSON & mapping .toEntity()
│   │   │   └── repositories/announcement_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/announcement.dart             # Entity pengumuman murni Dart
│   │   │   ├── repositories/announcement_repository.dart # Interface repository
│   │   │   └── usecases/
│   │   │       ├── get_announcements.dart             # Use case ambil list pengumuman
│   │   │       └── get_announcement_detail.dart       # Use case ambil detail pengumuman
│   │   └── presentation/
│   │       ├── pages/announcement_page.dart           # Halaman detail pengumuman
│   │       └── providers/announcement_providers.dart  # Wiring DI Riverpod
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/token_store.dart           # Wrapper FlutterSecureStorage
│   │   │   ├── models/user_session_model.dart         # Model sesi user
│   │   │   └── repositories/auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/user_session.dart             # Entity user session
│   │   │   ├── repositories/auth_repository.dart      # Interface repository auth
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart                 # Validasi email & password
│   │   │       ├── logout_usecase.dart                # Use case logout
│   │   │       └── refresh_token_usecase.dart         # Use case refresh token
│   │   └── presentation/
│   │       ├── pages/login_page.dart                  # Halaman form login
│   │       └── providers/auth_providers.dart          # State provider auth
│   ├── home/
│   │   └── presentation/
│   │       └── pages/home_page.dart                   # Dashboard utama & daftar pengumuman
│   └── notification/
│       ├── messaging/
│       │   ├── push_service.dart                      # Service FCM & notifikasi lokal
│       │   └── route_parser.dart                      # Parser payload rute pengumuman
│       └── presentation/
│           └── providers/push_providers.dart          # Provider stream notifikasi
├── routes.dart                                        # Konfigurasi GoRouter & deep link
└── main.dart                                          # Entry point aplikasi & inisialisasi
```

---

## 5. Fitur Utama & Paket yang Digunakan

- **Flutter SDK & Dart 3:** Menggunakan fitur modern Dart seperti Sealed Class untuk `Failure` dan Dart Records `({T? data, Failure? failure})` untuk return type sukses/gagal yang aman.
- **Flutter Riverpod (`^3.4.3`):** Manajemen state dan dependency injection tanpa perlu library DI tambahan.
- **GoRouter (`^18.0.2`):** Navigasi rute deklaratif, handling deep link `/pengumuman/:id`, dan redirect otomatis saat user belum login.
- **Flutter Secure Storage (`^11.2.0`):** Simpan token terenkripsi di keystore perangkat.
- **Firebase Messaging (`^16.7.0`) & Local Notifications (`^22.3.1`):** Menerima notifikasi foreground dan background.

---

## 6. Cara Menjalankan & Menguji Proyek

### 1. Menjalankan Cek Analisis Kode (Linter)
Untuk memastikan tidak ada warning atau error kode:
```bash
flutter analyze
```
*(Hasil: No issues found!)*

### 2. Menjalankan Unit Test dan Widget Test
Untuk menguji use case domain dengan fake repository dan widget test:
```bash
flutter test
```
*(Hasil: All 11 tests passed!)*

### 3. Menjalankan Aplikasi
Bisa dijalankan di Google Chrome atau emulator Android:
```bash
flutter run -d chrome
```

---

## 7. Bukti Uji Sterilitas Arsitektur (3 Perintah Grep)

Untuk membuktikan bahwa pemisahan layer benar-benar bersih dan tidak melanggar Dependency Rule, saya menjalankan 3 perintah grep di PowerShell:

| Pengujian | Perintah PowerShell | Hasil | Keterangan |
| :--- | :--- | :---: | :--- |
| **Grep 1: Presentation bebas akses data mentah** | `Get-ChildItem -Recurse lib/features/*/presentation/ \| Select-String "dio\|sqflite\|flutter_secure_storage\|dart:convert"` | `0 matches` | **Lolos:** UI tidak menyentuh HTTP/storage/decode JSON secara langsung. |
| **Grep 2: Domain bebas framework luar** | `Get-ChildItem -Recurse lib/features/*/domain/ \| Select-String "package:flutter\|package:dio\|sqflite\|firebase"` | `0 matches` | **Lolos:** Domain murni Dart tanpa import framework. |
| **Grep 3: Core bebas framework luar** | `Get-ChildItem -Recurse lib/core/ \| Select-String "package:flutter\|package:dio\|sqflite\|firebase"` | `0 matches` | **Lolos:** Core murni Dart tanpa dependensi framework. |

---

## 8. Galeri Tangkapan Layar (Screenshot Asli)

Semua screenshot di bawah ini diambil langsung dari aplikasi yang sedang berjalan di browser dan tampilan PowerShell:

| No | Tampilan Layar | File Screenshot | Penjelasan |
| :---: | :---: | :---: | :--- |
| 1 | **Halaman Login** | `screenshots/01_login_page_clean.png` | Form login yang sudah terhubung dengan `LoginUseCase` dan token disimpan lewat TokenStore. |
| 2 | **Dashboard Mahasiswa** | `screenshots/02_home_dashboard_clean.png` | Menampilkan identitas mahasiswa (Muhammad Aqil Azami - 244107020128), sensor token FCM (OWASP), dan daftar pengumuman dari layer domain. |
| 3 | **Detail Pengumuman** | `screenshots/03_announcement_detail_clean.png` | Navigasi deep link `/pengumuman/1` dengan data yang diambil via `GetAnnouncementDetail`. Tampilannya bersih tanpa parsing data di UI. |
| 4 | **Notifikasi Foreground** | `screenshots/04_foreground_notification.png` | Tampilan banner notifikasi saat ada broadcast pengumuman baru yang masuk ketika aplikasi sedang dibuka. |
| 5 | **Uji Sterilitas (3 Grep)** | `screenshots/05_dependency_rule_grep.png` | Bukti terminal PowerShell yang menunjukkan 0 temuan pelanggaran dependensi di ketiga layer. |
| 6 | **Hasil Analisis & Test** | `screenshots/06_flutter_analyze_test.png` | Bukti terminal PowerShell saat `flutter analyze` bersih dan 11 unit/widget test berhasil lulus 100%. |

---

## 9. Jawaban Pertanyaan Refleksi (Step 7 Codelab)

Berikut adalah jawaban refleksi berdasarkan hasil pengerjaan praktikum:

### 1. Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?
**Jawaban:**  
Karena domain itu inti dari aplikasi dan pemilik aturan bisnis. Domain yang menentukan data apa saja yang dibutuhkan oleh aplikasi, bukan sebaliknya. Konsep ini sesuai dengan prinsip *Dependency Inversion* (modul tingkat tinggi tidak boleh bergantung pada modul tingkat rendah).  

Kalau interface ditaruh di folder `data`:
- Layer domain terpaksa harus mengimpor folder `data`. Akibatnya aturan Clean Architecture jadi rusak karena arah panahnya berbalik ke luar.
- Domain jadi terikat sama teknologi database atau jaringan tertentu.
- Nanti kalau suatu saat kita mau ganti sumber data (misalnya dari SQLite ganti ke Hive atau Firebase), domain-nya bisa ikutan rusak atau harus diedit ulang.
- Unit test di domain jadi susah dibikin karena domain tidak bisa berdiri sendiri tanpa narik folder data.

---

### 2. Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?
**Jawaban:**  
- **Use case beneran dibutuhkan kalau:**
  1. Ada aturan bisnis atau validasi sebelum/sesudah data diambil. Contohnya di `LoginUseCase`, kita perlu ngecek dulu apakah format emailnya benar dan panjang password minimal 6 karakter sebelum manggil repository.
  2. Ada proses menggabungkan lebih dari satu repository. Misalnya fitur sinkronisasi offline yang harus ngambil data dari API Dio, terus nyimpen ke database lokal SQLite, baru ngasih tahu ke UI.
  3. Kita mau ngetes logika bisnis tersebut lewat unit test murni tanpa perlu ribet ngurusin lifecycle UI atau Riverpod notifier.

- **Repository langsung ke notifier sudah cukup kalau:**
  Operasinya cuma CRUD biasa satu baris tanpa aturan bisnis apa pun (misalnya cuma manggil `getAnnouncements()` yang tinggal terusin data dari repo ke provider). Bikin use case untuk fungsi yang cuma satu baris gini sebenernya nambah-nambahin file aja. Tapi kalau nanti fiturnya berkembang dan ada filternya, baru deh diekstrak jadi use case.

---

### 3. Apa biaya over-engineering (use case per CRUD satu-baris) bagi tim kecil? Kapan biayanya sepadan?
**Jawaban:**  
- **Biaya buat tim kecil:**
  1. **Kebanyakan file:** Kalau setiap fungsi CRUD satu baris dipaksa dibikinin use case, jumlah file di project bisa membengkak 3 sampai 4 kali lipat.
  2. **Bikin capek navigasi kodingan:** Waktu kita bisa habis cuma buat bolak-balik buka tab file di VS Code (dari page -> provider -> usecase -> repo interface -> repo impl -> datasource) cuma buat ngeliat 1 baris kode pemanggilan data sederhana.
  3. **Kerja jadi lambat:** Waktu yang harusnya dipakai buat nambahin fitur aplikasi malah habis buat nulis boilerplate dan nyambungin provider.

- **Kapan biayanya sepadan:**
  Biaya ini sepadan kalau aplikasinya sudah berskala besar dan dikerjakan oleh tim yang anggotanya banyak. Dengan memisahkan setiap use case ke satu file tersendiri, masing-masing programmer bisa ngerjain fiturnya tanpa rawan konflik saat nge-merge kode di Git, dan aturan bisnisnya tetap aman karena masing-masing punya test terpisah.

---

### 4. Bagian mana dari usulan AI yang Anda tolak atau sederhanakan, dan mengapa?
**Jawaban:**  
Saat mengerjakan AI Challenge di Step 5, ada beberapa saran dari AI yang sengaja saya tolak atau sederhanakan:

1. **Menolak package `fpdart` untuk tipe Either:**  
   AI menyarankan pakai library pihak ketiga `fpdart` buat return type `Either<Failure, T>`. Saya tolak karena menurut saya itu terlalu ribet dan nambah-nambahin dependensi luar. Di Dart 3 sekarang kita sudah punya fitur bawaan **Dart Records** seperti `({T? data, Failure? failure})` yang jauh lebih simpel, mudah dibaca, dan sudah type-safe tanpa perlu install library tambahan.
2. **Menolak use case tipis seperti `CheckAuthStatusUseCase`:**  
   AI menyarankan bikin file use case khusus cuma buat ngecek apakah user punya token atau tidak. Ini saya tolak karena fungsinya cuma return boolean satu baris tanpa ada logika bisnis sama sekali, jadi cukup dipanggil langsung lewat `authRepositoryProvider` di Riverpod notifier.
3. **Menghapus import Flutter di layer domain:**  
   AI sempat menyertakan `import 'package:flutter/foundation.dart'` di entity cuma buat anotasi `@immutable`. Ini langsung saya hapus karena layer domain harus 100% murni Dart dan tidak boleh mengimpor paket Flutter apa pun agar tetap steril.

---
