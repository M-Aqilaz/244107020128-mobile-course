# Laporan Praktikum Pemrograman Mobile
## Minggu 11: Optimasi Performa Aplikasi (*Performance Optimization*)

**Identitas Mahasiswa:**
- **Nama:** Muhammad Aqil Azami
- **NIM:** 244107020128
- **Kelas:** TI-3H
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Teknologi Informasi - Politeknik Negeri Malang
- **Mata Kuliah:** Praktikum Pemrograman Mobile
- **Semester:** Ganjil 2026/2027

---

## 1. Ringkasan Tugas

Di praktikum Minggu ke-11 ini, saya mempelajari cara menganalisis dan mengoptimalkan performa aplikasi Flutter (`campus_notify`) menggunakan **Flutter DevTools**. Tujuannya agar aplikasi bisa berjalan mulus di 60 FPS (durasi render per frame di bawah 16.6 ms), tidak boros RAM, bebas dari lag (*jank*), dan tidak ada kebocoran memori (*memory leak*).

### Yang Dikerjakan pada Praktikum Ini:
1. **Profiling DevTools (Step 2):** Menjalankan aplikasi di mode profil (`flutter run --profile`) untuk membaca grafik CPU Flame Chart dan Heap Memory.
2. **Mengurangi Rebuild Berlebih (Step 3):** Memasang konstruktor `const` pada widget statis, memecah widget yang kegedean jadi class terpisah (`AnnouncementItemCard`), membungkus kartu dengan `RepaintBoundary`, dan memilah state pakai Riverpod `select`.
3. **Lazy Loading & Infinite Scroll (Step 4):** Mengubah daftar pengumuman yang awalnya pakai `Column` biasa menjadi `ListView.builder` dan menambahkan fitur *infinite scroll* yang otomatis memuat data berikutnya saat scroll mendekati ujung bawah.
4. **Caching Data di Repository (Step 5):** Menerapkan strategi *Stale-While-Revalidate* pada `AnnouncementRepositoryImpl`. Jadi kalau user buka halaman pengumuman lagi, datanya langsung muncul instan dari cache memori tanpa perlu nunggu loading jaringan.
5. **Pembersihan Controller:** Memastikan `ScrollController` dan `TextEditingController` selalu di-`dispose()` agar tidak meninggalkan beban memori yang nyangkut.

---

## 2. Struktur File Proyek

```text
11-week-11-performance-optimization/
├── docs/
│   ├── performance-findings.md                   # Catatan temuan masalah saat awal profiling
│   └── performance-report.md                     # Laporan data perbandingan before vs after
├── lib/
│   └── features/
│       ├── announcements/
│       │   ├── data/repositories/
│       │   │   └── announcement_repository_impl.dart  # Repository dengan cache in-memory
│       │   ├── domain/repositories/
│       │   │   └── announcement_repository.dart       # Interface repository & helper paging
│       │   └── presentation/
│       │       ├── pages/announcement_page.dart       # Halaman detail pengumuman
│       │       ├── providers/announcement_providers.dart # Provider state list & infinite scroll
│       │       └── widgets/
│       │           ├── announcement_item_card.dart    # Widget kartu const berbungkus RepaintBoundary
│       │           └── paginated_announcements_view.dart # Tampilan list dengan ListView.builder
│       └── home/presentation/pages/
│           └── home_page.dart                         # Halaman beranda dengan tab switch & indikator
├── test/
│   ├── performance_optimization_test.dart        # Tes unit & widget untuk validasi cache dan repaint
│   ├── ai_assistant_test.dart                    # Pengujian fitur AI Chat
│   ├── auth_usecase_test.dart                    # Pengujian usecase login & auth
│   ├── get_announcements_test.dart               # Pengujian data pengumuman
│   ├── search_filter_test.dart                   # Pengujian filter pencarian
│   ├── search_widget_test.dart                   # Widget test search bar
│   └── widget_test.dart                          # Widget test beranda & profil mahasiswa
└── screenshots/                                  # Bukti tangkapan layar asli (runtime & DevTools)
```

---

## 3. Hasil Pengukuran Metrik (Sebelum vs Sesudah Optimasi)

Berikut adalah hasil perbandingan performa yang saya catat saat pengujian berdurasi 30 detik (skenario scroll cepat, buka-tutup halaman detail 5 kali, dan pencarian pengumuman):

| Metrik yang Diukur | Sebelum Dioptimasi (*Before*) | Sesudah Dioptimasi (*After*) | Hasil / Keterangan |
| :--- | :---: | :---: | :---: |
| **Rata-rata Frame Time** | `24.8 ms` *(lewat batas 16.6 ms)* | `7.9 ms` *(aman di bawah 16.6 ms)* | **Jauh lebih enteng (turun ~68%)** |
| **Frame Drop / Jank Merah** | Ada `14 frames` merah | `0 frames` (semua bar hijau) | **100% mulus tanpa stuttering** |
| **FPS Layar** | Sempat drop ke 38–45 FPS | Stabil konsisten di 60 FPS | **Animasi dan scroll lancar** |
| **Waktu Layout List** | `11.4 ms` | `3.1 ms` | **Waktu render berkurang drastis** |
| **Pemakaian Heap Memory** | `58.4 MB` | `39.2 MB` | **Lebih hemat RAM ~32%** |
| **Memory Leak (5x Buka-Tutup Detail)** | Nambah terus `+18.2 MB` | Stabil cuma `+0.4 MB` (dibersihkan GC) | **Controller berhasil di-dispose** |
| **Cache Hit Repository** | `0%` (tiap buka selalu fetch ulang) | `88.5%` (*Stale-While-Revalidate*) | **Buka pengumuman langsung instan** |

---

## 4. Bukti Tangkapan Layar Praktikum

> Seluruh tangkapan layar di bawah ini diambil langsung dari aplikasi Flutter Web yang sedang berjalan dan jendela Flutter DevTools di laptop saya. Tidak ada gambar buatan AI.

| No | File Screenshot | Gambar | Keterangan |
| :---: | :--- | :---: | :--- |
| **1** | `before-profile.png` | ![Before Profile](screenshots/before-profile.png) | **Flame Chart DevTools Sebelum Optimasi:** Terlihat banyak bar merah dan kuning (frame time sampai 24.8 ms) karena widget `HomePage` rebuild dari atas sampai bawah dan list masih pakai `Column`. |
| **2** | `after-profile.png` | ![After Profile](screenshots/after-profile.png) | **Flame Chart DevTools Sesudah Optimasi:** Semua bar frame berwarna hijau stabil di rata-rata 7.9 ms (60 FPS) setelah dipasang `const`, `RepaintBoundary`, dan `ListView.builder`. |
| **3** | `01_paginated_list.png` | ![Tampilan List Teroptimasi](screenshots/01_paginated_list.png) | **Tampilan Beranda Aplikasi:** Ada banner hijau tanda optimasi aktif, tab switch buat nyoba mode *Lazy Loading (Infinite Scroll)*, dan kartu item yang sudah diisolasi repainting-nya. |
| **4** | `02_devtools_memory.png` | ![DevTools Memory](screenshots/02_devtools_memory.png) | **Heap Snapshot di Tab Memory:** Memori stabil di kisaran 39 MB setelah navigasi bolak-balik berulang kali, membuktikan tidak ada objek controller yang bocor. |
| **5** | `03_terminal_verification.png` | ![Terminal Verification](screenshots/03_terminal_verification.png) | **Hasil Pengujian di Terminal:** Perintah `flutter analyze` berhasil dengan 0 issues dan seluruh 34 tes otomatis di `flutter test` lulus semua (hijau). |

---

## 5. Jawaban Refleksi Praktikum (Step 7)

### 1. Optimasi mana yang memberikan dampak terbesar dan mengapa?
Menurut saya setelah mencoba langsung di praktikum ini, optimasi yang paling besar pengaruhnya ke kenyamanan aplikasi adalah **mengganti `Column` biasa menjadi `ListView.builder` yang dipadukan dengan `RepaintBoundary` di tiap kartu pengumuman**.

Alasannya, pas masih pakai `Column`, Flutter dipaksa merender dan menghitung ukuran seluruh kartu pengumuman dari data pertama sampai terakhir sekaligus, padahal di layar HP paling cuma muat 2 atau 3 kartu saja. Begitu diganti jadi `ListView.builder`, widget yang dibikin cuma yang sedang kelihatan di layar (*viewport*). Ditambah lagi dengan `RepaintBoundary`, pas user menyentuh satu kartu, GPU cuma mengecat ulang kartu itu saja tanpa harus mengecat ulang seluruh halaman beranda. Hasilnya pas di-scroll cepat layarnya terasa enteng banget dan waktu layout di DevTools langsung turun drastis dari 11.4 ms ke 3.1 ms.

---

### 2. Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?
Saya memverifikasinya pakai angka dan data nyata dari **Flutter DevTools di mode profil (`flutter run --profile`)** dan pengujian otomatis di terminal, bukan cuma modal perasaan:
1. **Dari Grafik Frame Bar:** Di tab Performance DevTools, sebelum dioptimasi ada 14 frame merah yang durasinya sampai 24.8 ms. Setelah kodenya diperbaiki, semua frame bar berubah jadi hijau dan rata-rata cuma makan waktu 7.9 ms (jauh di bawah batas 16.6 ms).
2. **Dari Trace Flame Chart:** Durasi fungsi `build` dan `layout` di UI Thread kelihatan menyusut banyak.
3. **Dari Tab Memory:** Saya ambil *Heap Snapshot* sebelum dan sesudah buka-tutup halaman detail berkali-kali. Memorinya terbukti balik turun normal setelah *Garbage Collection*, beda dengan versi sebelum optimasi yang memorinya naik terus.
4. **Dari Unit Test:** Di file `test/performance_optimization_test.dart`, saya bikin tes khusus buat memastikan pemanggilan repository kedua kalinya langsung menghasilkan `cacheHitCount == 1` tanpa ada request jaringan tambahan.

---

### 3. Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?
Trade-off yang paling berasa adalah **kodenya jadi lebih banyak dan strukturnya jadi lebih terpecah-pecah**:
1. **File Jadi Bertambah:** Dulu pas belum dioptimasi, semua tampilan pengumuman saya tumpuk jadi satu di dalam file `home_page.dart`. Tapi biar bisa dipasangi `const` dan `RepaintBoundary`, saya harus memecahnya jadi sub-widget terpisah (`AnnouncementItemCard` dan `PaginatedAnnouncementsView`).
2. **Harus Teliti Mengurus Lifecycle:** Penggunaan `ScrollController` untuk fitur pagination menuntut kita buat selalu ingat pasang `dispose()` dan `removeListener()`. Kalau lupa sedikit saja, niatnya mau bikin cepat malah bisa bikin aplikasi kena *memory leak*.
3. **Logika Caching:** Dengan menerapkan *Stale-While-Revalidate*, kita harus memikirkan durasi kedaluwarsa data (TTL) agar user tidak melihat data pengumuman yang sudah basi terlalu lama.

---

### 4. Kapan sebaiknya optimasi premature dihindari?
Menurut saya, optimasi yang dilakukan terlalu dini (*premature optimization*) sebaiknya dihindari saat:
1. **Fitur Masih Tahap Eksplorasi / Desain Masih Sering Berubah:** Kalau alur fitur atau desain UI-nya masih belum pasti dari dosen atau tim, langsung menerapkan caching yang ribet atau memecah widget jadi kecil-kecil malah bikin repot kalau ada revisi besar di kemudian hari.
2. **Aplikasi Masih Berjalan Sangat Lancar:** Kalau halamannya cuma menampilkan beberapa teks statis dan waktu render per framenya masih di kisaran 4–6 ms (sangat aman di bawah 16.6 ms), kita tidak perlu pusing-pusing nambahin logika performa yang berlebihan.
3. **Prinsip Praktis:** Cukup ikuti kebiasaan ngoding yang baik dari awal (seperti pasang kata kunci `const` secara wajar dan pakai `ListView.builder` buat data yang dinamis). Optimasi yang rumit baru kita lakukan kalau memang terbukti ada lag atau masalah pas dicek pakai DevTools (*ukur dulu, baru optimasi*).
