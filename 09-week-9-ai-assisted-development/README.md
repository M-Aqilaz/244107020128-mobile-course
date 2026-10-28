# Laporan Praktikum Minggu 9: AI-Assisted Development & Vibe Coding

**Mata Kuliah:** Pemrograman Mobile  
**Topik:** Workflow AI-Assisted Development, Pencegahan Halusinasi, dan Refactoring Clean Architecture  

### Identitas Mahasiswa
- **Nama:** Muhammad Aqil Azami  
- **NIM:** 244107020128  
- **Kelas:** TI-3H  
- **Program Studi:** D-IV Teknik Informatika  
- **Jurusan:** Jurusan Teknologi Informasi - Politeknik Negeri Malang  

---

## 1. Deskripsi Praktikum

Di jobsheet Minggu 9 ini, materi utamanya adalah mempraktikkan **AI-Assisted Development** secara bijak dan profesional, bukan sekadar *vibe coding* asal jadi. *Vibe coding* (hanya mengetik prompt, menerima kode AI mentah-mentah tanpa diverifikasi, lalu berharap aplikasi langsung jalan) sangat berbahaya karena bisa menimbulkan bug tersembunyi, kode halusinasi, dan merusak struktur arsitektur yang sudah rapi.

Pada praktikum ini, saya melanjutkan project **Campus Notify** dari Minggu 7 & 8 dengan menambahkan satu fitur baru menggunakan bantuan AI:
> **Fitur:** Pencarian (*Search & Filter*) Pengumuman Kampus secara reaktif berdasarkan judul, isi, dan kategori + Tampilan *Empty State* ramah pengguna jika kata kunci tidak ditemukan.

Seluruh kode yang dihasilkan AI diuji baris demi baris, diverifikasi keaslian API-nya, dibuktikan bug-nya melalui tes merah (*red test*), lalu direfactor agar tetap mematuhi prinsip **Clean Architecture (Feature-First)**.

---

## 2. Strategi Prompting: Formula 5 Slot (Step 2)

Agar AI tidak menghasilkan kode yang ngawur atau merusak arsitektur, saya menyusun prompt menggunakan **Formula 5 Slot** sesuai instruksi codelab:

| Slot Formula | Isi & Konteks Mahasiswa |
| :--- | :--- |
| **1. Peran (*Role*)** | Senior Flutter Developer |
| **2. Konteks (*Context*)** | Clean Architecture feature-first (`presentation -> domain <- data`), Riverpod 3.x, GoRouter, entity `Announcement` |
| **3. Tugas (*Task*)** | Buatkan fitur pencarian judul & isi pengumuman secara reaktif + tampilan Empty State saat query tidak ada |
| **4. Batasan (*Constraints*)** | Jangan panggil SQLite/Dio dari widget, use case harus di domain murni tanpa import Flutter, kode ringkas (< 80 baris) |
| **5. Keluaran (*Output*)** | Use case murni, Riverpod provider, potongan widget search input + empty state, unit test & widget test |

---

## 3. Arsitektur Fitur Pencarian (Clean Architecture)

Fitur pencarian ini tidak ditaruh sembarangan di dalam widget, melainkan dipisahkan ke layer masing-masing:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│   • Search Input TextField (onChanged -> Notifier)                     │
│   • announcementSearchQueryProvider (Riverpod 3 Notifier<String>)      │
│   • filteredAnnouncementsProvider (AsyncValue filter)                  │
│   • Empty State Card Widget (tampil saat hasil filter kosong)          │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    │ (memanggil use case)
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                                 │
│   • SearchAnnouncements Use Case (Murni Dart, 0% Flutter)              │
│     - Normalisasi query (trimming spasi & lowercase)                   │
│     - Pencarian fleksibel pada title, body, dan category               │
│     - Mengembalikan semua pengumuman jika query kosong                 │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │
                                    │ (mengonsumsi entity)
┌───────────────────────────────────┴────────────────────────────────────┐
│                            DATA LAYER                                  │
│   • AnnouncementRepository & Model (Data pengumuman dari cache SQLite) │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Temuan Halusinasi & Bug AI (Step 1, 3, 4)

Waktu pertama kali men-generate kode, saya menemukan beberapa kesalahan khas buatan AI:

1. **Logika Case-Sensitive & Tidak Ada Trimming Spasi:**  
   AI menulis `a.title.contains(query)`. Akibatnya, kalau mahasiswa mengetik `"uts"` huruf kecil atau ada spasi `" UTS "`, jadwal pengumuman UTS malah tidak muncul. Ini saya buktikan lewat unit test merah di `test/search_filter_test.dart`, lalu saya perbaiki kodenya memakai `.trim().toLowerCase()`.
2. **Paket Kadaluarsa di Riverpod 3:**  
   AI masih menyarankan `StateProvider` yang sudah usang dan menghasilkan error kompilasi di Riverpod v3. Saya perbaiki menggunakan `Notifier<String>` dan `NotifierProvider`.
3. **Impor Framework Bocor ke Domain:**  
   AI sempat menyertakan `import 'package:flutter/foundation.dart'` di use case domain. Langsung saya hapus agar layer domain tetap murni 100% Dart.

---

## 5. AI Challenge: Evaluasi Review Senior Dev (Step 5)

Pada sesi review kode oleh AI, saya mengevaluasi 3 saran yang diajukan:
- **Saran 1 (Diterima):** Menambahkan tombol silang (*Clear button*) di search bar agar user bisa langsung menghapus teks pencarian dengan satu ketukan.
- **Saran 2 (Ditolak):** AI menyarankan pencarian diarahkan ke query database SQLite (`LIKE '%query%'`). Saran ini saya tolak karena data pengumuman lokal sudah tersimpan di memori Riverpod provider (jumlahnya puluhan item), sehingga in-memory search di domain jauh lebih cepat dan tidak membebani I/O disk database setiap ketukan huruf.
- **Saran 3 (Diterima):** Menambahkan tombol aksi *Reset Pencarian* di tampilan Empty State agar alur UX tidak menemui jalan buntu.

---

## 6. Cara Menjalankan & Menguji Proyek

### 1. Menjalankan Static Analysis (Linter)
```bash
flutter analyze
```
*(Hasil: No issues found!)*

### 2. Format Kode Sesuai Standar Dart
```bash
dart format lib test
```

### 3. Menjalankan Seluruh Pengujian (17 Test)
```bash
flutter test
```
*(Hasil: All 17 tests passed!)*

### 4. Menjalankan Aplikasi di Google Chrome / Emulator
```bash
flutter run -d chrome
```

---

## 7. Galeri Tangkapan Layar (Screenshot Asli)

Semua tangkapan layar di bawah ini diambil langsung dari aplikasi yang sedang berjalan dan terminal PowerShell asli:

| No | File Screenshot | Tampilan Layar | Penjelasan |
| :---: | :--- | :---: | :--- |
| 1 | `screenshots/01_search_initial.png` | **Tampilan Awal Search Bar** | Halaman utama dengan kolom pencarian baru, identitas mahasiswa Muhammad Aqil Azami (244107020128), dan daftar lengkap pengumuman. |
| 2 | `screenshots/02_search_matched.png` | **Pencarian Cocok (Filter Aktif)** | Saat kolom pencarian diisi kata kunci `"UTS"`, daftar pengumuman langsung terfilter secara reaktif dan muncul tombol clear `X`. |
| 3 | `screenshots/03_search_empty_state.png` | **Tampilan Empty State** | Saat kata kunci tidak cocok (`"zzz-tidak-ada"`), aplikasi menampilkan ilustrasi ramah, pesan informatif, dan tombol *Reset Pencarian*. |
| 4 | `screenshots/04_search_detail_nav.png` | **Navigasi Detail Pengumuman** | Hasil pencarian yang diklik tetap dapat membuka halaman detail `/pengumuman/1` secara mulus via GoRouter deep link. |
| 5 | `screenshots/05_flutter_analyze_test.png` | **Bukti Mesin Hijau di Terminal** | Tangkapan layar PowerShell membuktikan `flutter analyze` 0 issues dan seluruh 17 unit test use case & widget test lulus 100%. |

---

## 8. Jawaban Pertanyaan Refleksi (Step 7 Codelab)

### 1. Satu halusinasi AI apa yang Anda temukan dan bagaimana membuktikannya?
**Jawaban:**  
Halusinasi yang paling nyata adalah penggunaan API usang pada paket `flutter_riverpod` versi 3. AI mengusulkan kode `StateProvider<String>((ref) => '')`, padahal di versi Riverpod 3 yang terpasang di project, `StateProvider` sudah tidak didukung. Hal ini langsung terbukti ketika saya menjalankan `flutter analyze` di terminal yang memunculkan pesan error `The function 'StateProvider' isn't defined`. Selain itu, AI juga membuat logika pencarian yang case-sensitive tanpa trimming spasi, yang saya buktikan kegagalannya (*red test*) lewat unit test `SearchAnnouncements`.

### 2. Prompt mana yang paling membantu dan apa yang Anda ubah?
**Jawaban:**  
Prompt yang paling membantu adalah **Formula 5 Slot pada Step 2**. Dengan memberikan batasan tegas (*constraints*) bahwa logika pencarian harus ditaruh di layer domain usecase tanpa mengimpor framework Flutter dan tidak boleh memanggil SQLite dari widget, AI tidak berani membuat kode yang mencampuradukkan logika di dalam UI. Perubahan penting yang saya lakukan pada respon awal AI adalah menghapus import `package:flutter/foundation.dart` yang sempat disisipkan AI di layer domain.

### 3. Satu refactor apa yang Anda lakukan pada kode AI?
**Jawaban:**  
Saya merefactor state pencarian dari rancangan awal AI yang tadinya memakai `StateProvider` menjadi kelas `AnnouncementSearchQueryNotifier` turunan `Notifier<String>` dengan `NotifierProvider`. Dengan cara ini, perbaruan state query memiliki method eksplisit (`updateQuery` dan `clear`) yang rapi, sesuai standar idiomatis Riverpod 3 modern, dan mudah dipanggil dari widget maupun diuji lewat widget test.

### 4. Keputusan terima/tolak mana yang paling sulit?
**Jawaban:**  
Keputusan paling sulit adalah saat **menolak saran AI untuk memindahkan pencarian ke query database SQLite (`LIKE '%query%'`)**. Secara teori basis data, melakukan pencarian di level query database terdengar "canggih" dan umum dilakukan di aplikasi web skala besar. Namun, setelah saya analisis secara kritis, data pengumuman di aplikasi kampus ini sudah di-cache di memori Riverpod dalam jumlah puluhan item. Melakukan query I/O ke SQLite setiap kali user mengetikkan satu huruf di keyboard justru akan menimbulkan overhead pembacaan disk yang tidak perlu (*disk thrashing*) dan memperlambat responsivitas UI. Oleh karena itu, saya mantap menolaknya dan memilih in-memory filtering di layer domain.

---
