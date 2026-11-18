# Dokumentasi AI Review vs Keputusan Teknis Final

Dokumen ini memuat hasil eksperimen **AI Review Challenge** (Step 5 Codelab) pada proyek **Campus Notify**, mencakup prompt yang digunakan, analisis kritis terhadap 5 temuan AI, bukti verifikasi penerimaan/penolakan, serta tabel komparasi keputusan akhir.

---

## 1. Prompt Senior Reviewer yang Digunakan

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran) + alasan + usulan potongan kode perbaikan.
```

---

## 2. Rincian 5 Temuan AI Reviewer

### Temuan 1: Validasi Format Email Mengizinkan Karakter Ilegal (Kebenaran)
- **Level**: Blocker
- **Alasan AI**: Regex validasi email di `LoginUseCase` hanya memeriksa karakter `@` tanpa mengecek domain dan titik (`.`), sehingga input seperti `user@invalid` dianggap valid dan memicu request sia-sia ke server.
- **Usulan AI**:
  ```dart
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    return const Left(ValidationFailure('Format email tidak valid'));
  }
  ```

### Temuan 2: Token Refresh Failure Tidak Memiliki Unit Test Khusus (Pengujian)
- **Level**: Blocker
- **Alasan AI**: Terdapat implementasi `RefreshTokenUseCase`, namun belum ada pengujian untuk skenario ketika refresh token kadaluarsa atau bernilai kosong.
- **Usulan AI**:
  ```dart
  test('RefreshTokenUseCase mengembalikan failure saat token kosong', () async {
    final result = await refreshTokenUseCase('');
    expect(result.isLeft(), true);
  });
  ```

### Temuan 3: Mengimpor `BuildContext` ke dalam Domain Use Case untuk Localization (Arsitektur)
- **Level**: Saran
- **Alasan AI**: AI menyarankan use case menerima parameter `BuildContext context` agar pesan error `ValidationFailure` bisa langsung mengambil string terjemahan `AppLocalizations.of(context)`.
- **Usulan AI**:
  ```dart
  // Saran AI di domain/usecases/login_usecase.dart:
  import 'package:flutter/widgets.dart'; // <-- MELANGGAR ARSITEKTUR
  Future<Either<Failure, UserSession>> execute(BuildContext context, String email, String password) ...
  ```

### Temuan 4: Reorganisasi Urutan Import Berdasarkan Alfabet (Gaya Kode)
- **Level**: Saran
- **Alasan AI**: Import statement belum terurut secara alfabetis antara package bawaan Flutter dan library pihak ketiga.
- **Usulan AI**: Mengubah manual susunan import di 5 file presenter.

### Temuan 5: Optimasi Rebuild Widget Menggunakan `const` Constructor (Kinerja)
- **Level**: Saran
- **Alasan AI**: Beberapa widget statis (seperti icon dan divider di `HomePage`) belum dideklarasikan dengan `const`, menyebabkan alokasi memori berulang saat notifikasi baru masuk.
- **Usulan AI**: Tambahkan keyword `const` pada widget statis.

---

## 3. Verifikasi & Analisis Kritis (Penerimaan vs Penolakan)

### ✅ Temuan yang Diterima (Minimal 2 Terbukti Benar):
1. **Temuan 1 DITERIMA (Validasi Email Regex)**:  
   - **Bukti Verifikasi**: Dilakukan pengujian dengan string `"aqil@polinema"`. Validasi lama meloloskan input ini padahal tidak memiliki TLD (`.ac.id`/`.com`).
   - **Tindakan**: Menerapkan regex validasi yang lebih ketat pada `LoginUseCase` dan menambahkan unit test di `test/auth_usecase_test.dart`.
2. **Temuan 2 DITERIMA (Test Case Token Expired/Empty)**:  
   - **Bukti Verifikasi**: Diperiksa berkas `test/auth_usecase_test.dart`, coverage untuk branch `token.isEmpty` sebelumnya belum teruji secara eksplisit.
   - **Tindakan**: Menambahkan test case `RefreshTokenUseCase mengembalikan failure saat token kosong`. Pengujian langsung diverifikasi dengan `flutter test` (11/11 passed).
3. **Temuan 5 DITERIMA (Penambahan `const`)**:  
   - **Bukti Verifikasi**: Terbukti mengurangi rebuild tree dan mematuhi lint `prefer_const_constructors`.

---

### ❌ Temuan yang Ditolak (Minimal 1 Ditolak dengan Alasan Tertulis):
1. **Temuan 3 DITOLAK KERAS (Pelanggaran Dependency Rule Clean Architecture)**:
   - **Alasan Penolakan**:  
     Prinsip dasar Clean Architecture menyatakan bahwa **layer Domain harus 100% murni Dart**, independen dari UI framework, dan tidak boleh mengimpor package `flutter/*`.
   - Mengimpor `BuildContext` ke dalam Use Case akan membuat logika bisnis terikat ke platform Flutter UI, merusak kemudahan pengujian murni di CLI/Dart VM, dan melanggar prinsip *Separation of Concerns*.
   - **Solusi Alternatif yang Tepat**: Layer domain cukup mengembalikan objek Failure dengan kode error konstan (misal: `FailureCode.invalidEmail`). Layer Presentation (UI/Widget) yang bertanggung jawab menerjemahkan kode error tersebut ke bahasa lokal melalui `BuildContext`.

2. **Temuan 4 DITOLAK (Nitpick Style Non-Fungsional)**:
   - **Alasan Penolakan**:  
     Masalah urutan impor dan spasi adalah tugas linter otomatis dan formatter. Kita sudah memiliki aturan di `analysis_options.yaml` dan perintah CI `dart format --set-exit-if-changed .`. Melakukan review manual atau PR khusus hanya untuk urutan impor adalah pemborosan waktu review tim.

---

## 4. Tabel Komparasi Usulan AI vs Keputusan Teknis Final

| No | Subjek Temuan | Usulan Awal AI | Keputusan Anda | Alasan Teknis & Arsitektural |
| :-: | :--- | :--- | :---: | :--- |
| 1 | Validasi Email | Pakai Regex RFC lengkap di domain | **DITERIMA** | Menghindari pengiriman request jaringan tidak valid ke API gateway. |
| 2 | Unit Test Token | Tambah test case token kosong/expired | **DITERIMA** | Meningkatkan test coverage dan mencegah regresi pada autentikasi. |
| 3 | Lokalisasi Pesan Error | Masukkan `BuildContext` ke use case | **DITOLAK** | **Melanggar Clean Architecture Dependency Rule**. Domain dilarang keras mengimpor `package:flutter`. |
| 4 | Urutan Import | Atur manual posisi baris import | **DITOLAK** | Gaya penulisan sudah didelegasikan otomatis ke `dart format` dan CI pipeline. |
| 5 | Const Widget | Tambah `const` di elemen statis | **DITERIMA** | Mengoptimasi performa rendering Flutter dan menghemat memori runtime. |
