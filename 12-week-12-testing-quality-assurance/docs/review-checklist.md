# Checklist Review Kesiapan Mid-Project & Hygiene Git

Dokumen ini memuat audit riwayat commit, standar branch hygiene, checklist kelayakan paruh semester (Mid-Project Review), serta checklist peer review untuk proyek **Campus Notify**.

---

## 1. Audit Riwayat Commit (Praktikum 1)

### Log Commit Riwayat Sebelumnya (`git log --oneline -10`)
```text
2caab77 clear_week_7
a1ce5fe Merge branch 'main' of https://github.com/M-Aqilaz/244107020128-mobile-course
b038d6f minggu_6
29bfb01 Salah alamat github
9f339fc Created using Colab
38718eb minggu_kelima_clear
68e6440 minggu_4_clear
ba4134d minggu_keempat_clear
ef85666 minggu_ketiga_clear
574cb13 update_laporan_week_1
```

### Identifikasi Masalah:
1. **Pesan Commit Tidak Deskriptif**: Pesan seperti `clear_week_7` dan `minggu_6` tidak menjelaskan fitur atau berkas apa yang ditambahkan/diubah.
2. **Tidak Mengikuti Conventional Commits**: Tidak ada prefix tipe (`feat`, `fix`, `refactor`, dll.) dan scope komponen.
3. **Pencampuran Perubahan**: Satu commit memuat seluruh tugas mingguan sekaligus (ratusan baris) tanpa dipecah per fungsi logis.
4. **Commit Langsung ke `main`**: Semua perubahan di-push langsung ke branch produksi (`main`) tanpa melalui branch integrasi `develop` atau Pull Request.

---

### Tabel Perbaikan Commit (Simulasi Sebelum vs Sesudah)

| Hash Asli | Pesan Lama | Pesan Baru (Conventional Commits) | Alasan Perubahan |
| :--- | :--- | :--- | :--- |
| `2caab77` | `clear_week_7` | `refactor(clean-arch): terapkan clean architecture dan sterilisasi layer domain` | Menjelaskan secara presisi bahwa pekerjaan tersebut adalah penataan ulang arsitektur (refactoring) dan pemisahan 3 layer. |
| `b038d6f` | `minggu_6` | `feat(auth): tambahkan login secure storage dan fcm push notification` | Menegaskan bahwa penambahan fitur baru berfokus pada modul autentikasi dan layanan notifikasi. |
| `38718eb` | `minggu_kelima_clear` | `feat(offline): implementasi sqlite storage dan repository offline-first` | Memberikan konteks jelas bahwa fitur yang dibangun adalah penyimpanan lokal SQLite dan sinkronisasi offline. |
| `68e6440` | `minggu_4_clear` | `feat(network): integrasi dio client dan parsing rest api pengumuman` | Menunjukkan aksi integrasi jaringan HTTP dan model parser yang dibuat. |
| `ba4134d` | `minggu_keempat_clear`| `fix(network): tangani connection timeout dan interceptor error` | Membedakan commit perbaikan bug/error handling dari commit fitur utama. |

---

## 2. Checklist Kelayakan Paruh Semester (Mid-Project Review)

| No | Kriteria Kesiapan | Status | Bukti / Catatan |
| :-: | :--- | :---: | :--- |
| 1 | **Struktur Feature-First & 3 Layer** | ✅ Terpenuhi | Modul terpisah di `lib/features/auth/`, `announcements/`, `notification/`, dan `home/`. |
| 2 | **Sterilitas Layer Domain** | ✅ Terpenuhi | Tidak ada import `package:flutter`, `package:dio`, atau `package:sqflite` di dalam layer `domain/`. |
| 3 | **Static Analysis Bersih (`flutter analyze`)** | ✅ Terpenuhi | Output: `No issues found! (ran in 4.5s)`. |
| 4 | **Kode Rapi Terformat (`dart format`)** | ✅ Terpenuhi | Output: `Formatted 29 files (0 changed)` dengan exit code 0. |
| 5 | **Pengujian Otomatis (`flutter test`)** | ✅ Terpenuhi | Output: `All 11 tests passed!`. |
| 6 | **Ukuran Pull Request Terkendali** | ✅ Terpenuhi | PR dirancang kecil (< 300 baris) per satu fitur logis terfokus. |
| 7 | **Automasi CI/CD (`ci.yml`)** | ✅ Terpenuhi | Workflow `.github/workflows/ci.yml` aktif memverifikasi analyze & test. |
| 8 | **Dokumentasi & Reproduksibilitas** | ✅ Terpenuhi | `README.md` memuat cara menjalankan, arsitektur, dan refleksi lengkap. |

---

## 3. Bukti Sterilitas Layer Domain (Grep Verification)

Sesuai aturan Dependency Rule Clean Architecture, layer Domain tidak boleh memiliki ketergantungan pada framework UI atau library eksternal:

```bash
# Verifikasi 1: Tidak ada import Flutter di domain
Select-String -Path "lib/**/domain/**/*.dart" -Pattern "package:flutter/"
# Hasil: KOSONG (Steril)

# Verifikasi 2: Tidak ada import Dio di domain
Select-String -Path "lib/**/domain/**/*.dart" -Pattern "package:dio/"
# Hasil: KOSONG (Steril)

# Verifikasi 3: Tidak ada import SQLite di domain
Select-String -Path "lib/**/domain/**/*.dart" -Pattern "package:sqflite/"
# Hasil: KOSONG (Steril)
```

---

## 4. Panduan Pola Komentar Review Sejawat (Peer Review)

Setiap temuan wajib menggunakan formula konstruktif:
$$\text{Observasi} \longrightarrow \text{Dampak} \longrightarrow \text{Usulan Konkret}$$

### Contoh Penerapan:
- **Kebenaran (Null/Error Path):**  
  > *"Observasi: Pada `login_page.dart`, variabel `emailController.text` tidak ditrim sebelum divalidasi.  
  > Dampak: Spasi yang tidak sengaja tertekan di keyboard HP akan menyebabkan validasi gagal.  
  > Usulan: Gunakan `emailController.text.trim()` pada `LoginUseCase`."*

- **Arsitektur (Dependency Leak):**  
  > *"Observasi: Terdapat usulan impor `BuildContext` ke dalam use case untuk mengambil pesan terjemahan.  
  > Dampak: Layer domain menjadi bergantung pada framework Flutter UI sehingga tidak bisa diuji murni di Dart VM.  
  > Usulan: Kembalikan kode error / failure enum dari domain, lalu biarkan presentation layer yang memetakan ke string UI."*
