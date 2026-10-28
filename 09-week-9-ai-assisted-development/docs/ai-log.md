# Log AI-Assisted Development: Fitur Pencarian & Empty State

**Mata Kuliah:** Pemrograman Mobile  
**Jobsheet:** Minggu 9 - AI-Assisted Development & Vibe Coding  
**Nama Mahasiswa:** Muhammad Aqil Azami  
**NIM:** 244107020128  
**Kelas:** TI-3H  
**Jurusan:** Jurusan Teknologi Informasi - Politeknik Negeri Malang  

---

## 1. Formula 5 Slot Prompt yang Digunakan (Praktikum 1 - Step 2)

Sesuai materi di Jobsheet 9, prompt yang baik tidak boleh asal kabur seperti *"bikinin search dong"*, melainkan harus mengisi 5 slot formula secara spesifik:

1. **Peran (*Role*):** Senior Flutter Developer.
2. **Konteks (*Context*):** Project Flutter `campus_notify` dengan struktur Clean Architecture (*feature-first*: presentation -> domain <- data), state management Flutter Riverpod 3.x, dan routing GoRouter.
3. **Tugas (*Task*):** Tambahkan fitur pencarian (*search filter*) untuk pengumuman kampus berdasarkan judul, kategori, atau isi pengumuman, serta tampilkan Empty State ramah pengguna jika query tidak cocok.
4. **Batasan (*Constraints*):**
   - Jangan merusak atau mengubah aturan Clean Architecture.
   - Jangan memanggil SQLite atau Dio langsung dari widget UI.
   - Logika pencarian harus berada di layer domain use case murni (tanpa import Flutter).
   - Maksimal 80 baris kode per komponen agar mudah diverifikasi.
5. **Keluaran (*Output*):** Kode use case domain, Riverpod provider, widget search bar + empty state, serta unit test dan widget test pembukti.

### Teks Prompt Asli (Verbatim):
```text
Sebagai senior Flutter developer, tolong bantu tambahkan fitur pencarian (search & filter) pada pengumuman di project campus_notify.
Konteks:
- Menggunakan Clean Architecture feature-first (presentation -> domain <- data).
- State management: flutter_riverpod versi 3.x.
- Rute: GoRouter (/pengumuman/:id).
Batasan:
- Jangan panggil database SQLite atau Dio dari widget UI.
- Logika filter harus ditaruh di layer domain (use case murni tanpa import framework Flutter).
- Sediakan tampilan Empty State saat pengumuman tidak ditemukan.
- Kode ringkas (< 80 baris per file).
Berikan:
1. Use case domain murni.
2. Provider Riverpod yang rapi.
3. Potongan widget search input + empty state.
4. Unit test domain dan widget test untuk empty state.
```

---

## 2. Output Awal yang Diberikan AI (Praktikum 2 - Step 3)

Berikut adalah draf awal kode yang digenerate oleh AI sebelum saya review:

```dart
// Draf Awal AI: announcement_filter.dart
import 'package:flutter/foundation.dart'; // <-- BUKTI HALUSINASI / KEBOCORAN LAYER

class FilterAnnouncementsUseCase {
  List filter(List announcements, String query) {
    // AI menulis pencarian case-sensitive dan tanpa trim:
    return announcements.where((a) => a.title.contains(query)).toList();
  }
}

// Draf Provider AI:
final searchQueryProvider = StateProvider<String>((ref) => ''); // <-- API KADALUARSA DI RIVERPOD 3
```

---

## 3. Temuan Halusinasi, Bug, dan Cara Pembuktiannya (Step 1, 3, 4)

Setelah saya telaah baris demi baris (*line-by-line verification*), saya menemukan 3 masalah nyata pada kode buatan AI:

### Bug 1: Pencarian Case-Sensitive & Tidak Ada Trimming Spasi (Logika Salah Tapi Yakin)
- **Gejala:** AI menulis `a.title.contains(query)`.
- **Dampak:** Kalau user mengetik `"uts"` (huruf kecil) atau ada spasi `" UTS "`, pengumuman `"Jadwal Ujian Tengah Semester (UTS)"` malah tidak muncul sama sekali.
- **Cara Membuktikan (Test Merah):** Saya buat unit test di `test/search_filter_test.dart` dengan input `'uts'` pada data `'Jadwal Ujian Tengah Semester (UTS)'`. Awalnya test ini **FAIL (Merah)**.
- **Solusi & Refactor (Test Hijau):** Saya ubah kodenya dengan menormalkan query menggunakan `.trim().toLowerCase()` dan mengecek `title`, `body`, serta `category`. Test langsung **PASS (Hijau)**.

### Bug 2: API Kadaluarsa / Deprecated di Riverpod 3 (`StateProvider`)
- **Gejala:** AI mengusulkan `final searchQueryProvider = StateProvider<String>((ref) => '');`.
- **Dampak:** Di project kami yang memakai `flutter_riverpod: ^3.4.3`, `StateProvider` menghasilkan error saat dikompilasi: `The function 'StateProvider' isn't defined`.
- **Cara Membuktikan:** Ditemukan langsung saat menjalankan `flutter analyze` di terminal.
- **Solusi & Refactor:** Saya refactor ke arsitektur modern Riverpod 3 menggunakan `Notifier<String>` dan `NotifierProvider`.

### Bug 3: Import Framework Bocor ke Layer Domain
- **Gejala:** AI menyertakan `import 'package:flutter/foundation.dart';` di file use case domain hanya untuk anotasi `@immutable`.
- **Dampak:** Melanggar prinsip Dependency Rule Clean Architecture (Domain harus 100% murni Dart).
- **Cara Membuktikan:** Terbukti saat dilakukan pemeriksaan grep sterilitas arsitektur (`Select-String "package:flutter" lib/features/*/domain/`).
- **Solusi & Refactor:** Menghapus import Flutter dan menggantinya dengan pure Dart `const SearchAnnouncements()`.

---

## 4. AI Challenge: Review Kode Senior Dev & Tabel Terima/Tolak (Step 5)

Pada Step 5, saya meminta AI mereview kode yang sudah direfactor dengan prompt:
```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Berikut adalah hasil evaluasi saya terhadap 3 temuan yang diajukan AI:

| No | Temuan / Usulan AI | Level | Keputusan Saya | Alasan Teknis & Pertimbangan Mahasiswa |
| :---: | :--- | :---: | :---: | :--- |
| 1 | **Saran:** Tambahkan tombol pembersih (*Clear Button*) pada kolom input pencarian agar user tidak perlu menghapus teks huruf demi huruf saat ingin mereset filter. | Saran UX | **DITERIMA & DIIMPLEMENTASIKAN** | Usulan ini sangat relevan untuk kenyamanan pengguna (*usability*). Saya menambahkan `IconButton(icon: Icons.clear_rounded)` yang otomatis muncul saat kolom pencarian terisi teks. |
| 2 | **Saran:** Pindahkan logika pencarian ke database SQLite dengan query `SELECT * FROM announcements WHERE title LIKE '%query%'` setiap kali user mengetik. | Saran Arsitektur | **DITOLAK** | Data pengumuman lokal sudah tersimpan di memori Riverpod provider (in-memory caching) dengan jumlah puluhan data. Melakukan query I/O ke disk database SQLite setiap ketukan huruf justru membebani performa dan menambah latency yang tidak perlu. In-memory filtering di domain usecase jauh lebih cepat dan instan. |
| 3 | **Saran:** Sediakan tombol aksi *Reset Pencarian* di dalam tampilan Empty State saat pencarian tidak menghasilkan data. | Saran UX / UI | **DITERIMA & DIIMPLEMENTASIKAN** | Menghindari kondisi jalan buntu (*dead end*) bagi pengguna. Jika pencarian kosong, user bisa langsung mengklik tombol "Reset Pencarian" untuk mengembalikan semua daftar pengumuman. |

---

## 5. Ringkasan Pengujian & Bukti Mesin Hijau (Step 6)

Setelah semua perbaikan dan refactoring diterapkan:
1. **Static Analysis (`flutter analyze`):**  
   `No issues found!` (0 warning, 0 error).
2. **Unit Test Domain (`test/search_filter_test.dart`):**  
   5 test case lulus 100% (case-insensitive, empty query, no match, multi-field match, trimming whitespace).
3. **Widget Test UI & Empty State (`test/search_widget_test.dart`):**  
   Lulus 100% (memverifikasi interaksi pengetikan query, filtering daftar pengumuman, kemunculan card Empty State, dan fungsi tombol reset).
4. **Total Seluruh Pengujian Proyek:**  
   **17 / 17 tests passed!**

---
*Dokumen ini disusun sebagai bukti pelaksanaan workflow AI-Assisted Development yang kritis, teruji, dan bertanggung jawab.*
