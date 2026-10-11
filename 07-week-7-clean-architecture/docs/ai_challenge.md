# Catatan AI Challenge: Evaluasi Usulan AI untuk Refactor Clean Architecture

**Nama:** Muhammad Aqil Azami  
**NIM:** 244107020128  
**Kelas:** TI-3H  
**Mata Kuliah:** Pemrograman Mobile (Jobsheet 7)  

---

## 1. Prompt yang Saya Berikan ke AI

Sesuai instruksi di Step 5 Codelab, ini prompt yang saya pakai waktu minta saran ke AI:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
(presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

---

## 2. Respon Awal dari AI

Setelah saya kasih prompt itu, AI ngasih rekomendasi:
1. **Pemisahan Folder:** AI nyaranin fitur dibagi jadi `features/auth` dan `features/announcements`, masing-masing punya subfolder `data`, `domain`, dan `presentation`.
2. **Pemecahan File:** File repository lama yang nyampur disaranin dipecah dua: interface-nya masuk domain, implementasinya masuk data.
3. **Use Case yang Diusulkan:** AI nyaranin bikin banyak use case terpisah buat hampir semua aksi: `GetAnnouncementsUseCase`, `GetAnnouncementDetailUseCase`, `LoginUseCase`, `LogoutUseCase`, `RefreshTokenUseCase`, sampai-sampai hal sepele kayak ngecek status login disuruh bikin `CheckAuthStatusUseCase`.
4. **Wiring DI:** AI nyontohin wiring pakai Riverpod biasa (provider biasa tanpa library DI tambahan).

---

## 3. Checklist & Koreksi Saya Terhadap Kode AI

Sebagai mahasiswa yang ngerjain sendiri, saya gak langsung telan mentah-mentah hasil dari AI. Saya cek kodenya satu-satu sesuai checklist yang dikasih dosen:

| Kriteria Checklist | Status | Catatan & Analisis Saya |
| :--- | :---: | :--- |
| **Interface repo di domain & implementasi di data?** | **OK** | AI sudah benar memisahkan abstract class ke `domain/repositories/` dan implementasinya ke `data/repositories/`. |
| **Domain benar-benar bersih tanpa import Flutter?** | **Saya Koreksi** | Pas saya cek draf kode entity auth dari AI, ternyata ada baris `import 'package:flutter/foundation.dart'` cuma buat anotasi `@immutable`. Baris ini langsung saya hapus biar layer domain beneran murni Dart tanpa ada embel-embel Flutter. |
| **Gak over-engineering bikin usecase CRUD 1 baris?** | **Saya Tolak** | AI menyarankan bikin `CheckAuthStatusUseCase` yang isinya cuma manggil `repo.isLoggedIn()`. Ini saya tolak karena boros file dan gak ada aturan bisnisnya. Cukup panggil repository langsung lewat provider notifier. |
| **Entity bebas dari toMap/fromMap?** | **OK** | Entity di domain cuma berisi data class murni. Fungsi konversi JSON/database ditaruh di `data/models/`. |
| **DI terpusat di Provider Riverpod?** | **OK** | Di widget UI tidak ada `new AuthRepository()`, semuanya dipanggil lewat `ref.watch` atau `ref.read`. |

---

## 4. Tabel Perbandingan: Usulan AI vs Keputusan Saya

Di tabel ini saya bandingkan apa yang disarankan AI dan apa yang akhirnya saya terapkan di project:

| Hal yang Direview | Usulan Awal AI | Keputusan yang Saya Ambil | Alasan Saya |
| :--- | :--- | :--- | :--- |
| **Tipe Return Error / Sukses** | Nyaranin install package `fpdart` buat pakai `Either<Failure, T>` | Pakai **Dart Records** bawaan Dart 3: `({T? data, Failure? failure})` | Biar gak perlu install package tambahan yang bikin project berat. Dart Records bawaan sudah type-safe, simpel, dan gampang dibaca teman sekelompok. |
| **Use Case Cek Status Login** | Bikin file `CheckAuthStatusUseCase` terpisah | Langsung panggil via `authRepositoryProvider` di notifier | Kalau fungsinya cuma return boolean satu baris tanpa validasi logika apa-apa, bikin use case khusus itu buang-buang waktu dan bikin kebanyakan file. |
| **Validasi Login** | Ditaruh di form UI (`validator` TextFormField) | Dipindah ke **`LoginUseCase`** di layer domain | Validasi format email dan password minimal 6 karakter itu aturan bisnis, jadi harus ada di domain biar bisa dites lewat unit test tanpa render tampilan UI. |
| **Format Tanggal & Masking Token** | Dibiarkan nempel di fungsi widget halaman | Diekstrak jadi fungsi murni di **`lib/core/format.dart`** | Biar tampilan UI rapi dan fungsi formatnya bisa dites sendiri tanpa butuh BuildContext Flutter. |
| **Push Notification FCM** | Nyaranin push service masuk domain | Ditaruh terpisah di `features/notification/messaging/` | FCM dan local notification itu urusan platform device (I/O luar), jadi gak boleh ngotorin layer domain yang harus murni. |

---

## 5. Bukti Cek Sterilitas Dependensi (3 Perintah Grep)

Untuk memastikan aturan dependensi Clean Architecture benar-benar dipatuhi (panah cuma boleh mengarah ke dalam), saya coba tes pakai 3 perintah pencarian di PowerShell:

### 1. Grep Presentation (Pastikan gak ada akses database/network langsung di UI)
```powershell
Get-ChildItem -Recurse lib/features/*/presentation/ | Select-String "dio|sqflite|flutter_secure_storage|dart:convert"
```
**Hasil:** `0 matches` (Bersih). Di folder UI gak ada yang nyentuh Dio, SQLite, SecureStorage, atau jsonDecode langsung.

### 2. Grep Domain (Pastikan domain murni Dart tanpa library framework)
```powershell
Get-ChildItem -Recurse lib/features/*/domain/ | Select-String "package:flutter|package:dio|sqflite|firebase"
```
**Hasil:** `0 matches` (Bersih). Semua entity, repository interface, dan use case bebas dari import Flutter/Dio/Firebase/SQLite.

### 3. Grep Core (Pastikan core utilitas murni Dart)
```powershell
Get-ChildItem -Recurse lib/core/ | Select-String "package:flutter|package:dio|sqflite|firebase"
```
**Hasil:** `0 matches` (Bersih). File `failures.dart` dan `format.dart` murni pakai fungsi bawaan Dart.

---

## 6. Kesimpulan Saya

Dari eksperimen ini, saya belajar kalau AI itu memang cepat buat bikinin kerangka folder dan boilerplate kode. Tapi kita sebagai mahasiswa yang ngoding tetap harus mikir dan kritis:
- Jangan asal terima saran AI yang bikin kodingan jadi kepanjangan atau kebanyakan file (*over-engineering*).
- Kita harus jeli ngecek jangan sampai ada import framework luar yang bocor ke layer domain.
- Lebih baik manfaatin fitur bawaan bahasa pemrograman yang kita pakai (seperti Dart Records) daripada buru-buru install library tambahan dari luar.
