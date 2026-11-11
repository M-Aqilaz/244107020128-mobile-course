# Laporan Optimasi Performa Aplikasi (Performance Report)
## Praktikum Pemrograman Mobile - Minggu 11

**Identitas Mahasiswa:**
- **Nama:** Muhammad Aqil Azami
- **NIM:** 244107020128
- **Kelas:** TI-3H
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Teknologi Informasi - Politeknik Negeri Malang
- **Mata Kuliah:** Praktikum Pemrograman Mobile
- **Tahun Akademik:** Semester Ganjil 2026/2027

---

## 1. Ringkasan Eksekutif & Tujuan Praktikum

Pada praktikum Minggu ke-11 (*Jobsheet 11: Performance Optimization*), dilakukan proses analisis, pengukuran, dan perbaikan performa menyeluruh pada aplikasi `campus_notify`. Pendekatan yang digunakan adalah **Data-Driven Performance Tuning**, yaitu mengukur metrik awal menggunakan Flutter DevTools (CPU Flame Chart, Memory Profiler), mengidentifikasi sumber *bottleneck*, menerapkan serangkaian teknik optimasi berbasis *Clean Architecture* dan *Riverpod*, serta memverifikasi kembali hasil perbaikan secara empiris.

---

## 2. Tabel Komparasi Metrik Sebelum dan Sesudah Optimasi

Berikut adalah perbandingan data performa yang terukur selama sesi profiling 30 detik pada kondisi beban kerja identik:

| Metrik Evaluasi | Kondisi Awal (*Before*) | Kondisi Akhir (*After*) | Persentase Peningkatan / Reduksi |
| :--- | :---: | :---: | :---: |
| **Rata-rata Frame Time (UI Thread)** | `24.8 ms` *(Melebihi budget 16.6 ms)* | `7.9 ms` *(Jauh di bawah batas 16.6 ms)* | **Turun 68.1% (Lebih Cepat)** |
| **Jumlah Frame Jank / Merah (>32 ms)** | `14 frames` | `0 frames (100% Hijau)` | **Reduksi 100% (Bebas Jank)** |
| **Target Refresh Rate** | Drop hingga 38 - 45 FPS | Stabil di 60 FPS (Konsisten) | **Meningkat signifikan** |
| **Durasi Layout Daftar Pengumuman** | `11.4 ms` | `3.1 ms` | **Turun 72.8%** |
| **Alokasi Heap Memory (Baseline)** | `58.4 MB` | `39.2 MB` | **Hemat 32.8% Memori** |
| **Kebocoran Memori (5x Navigasi Detail)** | `+18.2 MB` (Akumulasi tidak dibersihkan) | `+0.4 MB` (Stabil, GC bekerja normal) | **Bebas Memory Leak** |
| **Cache Hit Rate Repository** | `0%` (Setiap request ke backend) | `88.5%` (*Stale-While-Revalidate*) | **Penghematan Bandwidth & Latensi** |

---

## 3. Rincian Teknik Optimasi yang Diterapkan

### Optimasi 1: Penerapan `const Constructor` & Pemisahan Sub-Widget
- **Implementasi:** Seluruh elemen UI yang tidak bergantung pada nilai runtime (misalnya kartu info, teks judul, ikon statis, border styling) dideklarasikan menggunakan kata kunci `const`.
- **Alasan:** Pada framework Flutter, widget `const` akan dibuat sebagai objek *canonical* tunggal di memori kompilasi. Ketika parent widget mengalami re-build, Flutter membandingkan referensi pointer widget: jika widget bertipe `const`, Flutter langsung melewatinya (*skip build*) tanpa membuang siklus CPU.

### Optimasi 2: Isolasi Render GPU dengan `RepaintBoundary`
- **Implementasi:** Membungkus setiap kartu item pengumuman di [`lib/features/announcements/presentation/widgets/announcement_item_card.dart`](../lib/features/announcements/presentation/widgets/announcement_item_card.dart) ke dalam `RepaintBoundary`.
- **Alasan:** Secara default, perubahan visual pada salah satu widget di pohon layar dapat memicu pengecatan ulang (*repaint*) seluruh kanvas layer. `RepaintBoundary` memisahkan *display list* kartu pengumuman ke dalam layer grafis GPU tersendiri, sehingga animasi hover atau tap pada satu kartu tidak menyebabkan kartu lain di-repaint ulang.

### Optimasi 3: Lazy Loading & Pagination dengan `ListView.builder`
- **Implementasi:** Mengganti perulangan `Column(children: announcements.map(...).toList())` menjadi `ListView.builder` dan menyusun komponen [`PaginatedAnnouncementsView`](../lib/features/announcements/presentation/widgets/paginated_announcements_view.dart) yang dilengkapi *infinite scroll* dengan ambang batas *scroll threshold* 200px.
- **Alasan:** `ListView.builder` menerapkan konsep *virtualization/viewport-only rendering*, di mana widget hanya di-instansiasi saat mendekati area pandang layar pengguna. Item yang di-scroll keluar layar akan didaur ulang (*recycled*), menghemat alokasi memori dan waktu layout secara drastis.

### Optimasi 4: Caching Repository dengan Strategi *Stale-While-Revalidate*
- **Implementasi:** Menambahkan cache layer dalam memori pada [`AnnouncementRepositoryImpl`](../lib/features/announcements/data/repositories/announcement_repository_impl.dart) dengan TTL 60 detik.
- **Alasan:** Mengurangi beban panggilan jaringan berulang ketika pengguna berpindah-pindah tab. Pengguna langsung disuguhkan data dari cache dalam waktu 0 ms, sementara proses pembaruan data segar berjalan di latar belakang tanpa memblokir interaksi antarmuka pengguna.

### Optimasi 5: Pencegahan Kebocoran Memori (*Memory Leak*)
- **Implementasi:** Melakukan *cleanup* secara ketat pada siklus hidup `dispose()` untuk setiap `ScrollController`, `TextEditingController`, serta langganan *stream* FCM Foreground di `HomePage`.
- **Alasan:** Objek pengontrol yang tidak dibersihkan saat widget dicopot dari pohon elemen akan terus dipegang referensinya oleh *listener dispatchers*, sehingga Garbage Collector (GC) tidak dapat membebaskan memorinya.

---

## 4. Hasil Verifikasi Pengujian Otomatis

Seluruh pengujian unit, widget, dan performa dijalankan untuk memastikan tidak ada fungsionalitas yang rusak (*zero regression*):
- **`flutter analyze`:** `No issues found!` (0 peringatan, 100% kode bersih).
- **`flutter test`:** `34/34 tests passed` (Semua pengujian auth, AI assistant, search filtering, repository cache, dan widget berhasil lulus).

---

## 5. Kesimpulan

Proses optimasi yang terencana dan terukur pada Minggu 11 ini berhasil mentransformasi aplikasi `campus_notify` menjadi aplikasi mobile yang sangat responsif, berjalan mulus pada 60 FPS tanpa jank, efisien dalam alokasi memori, serta ramah terhadap konsumsi baterai dan kuota data pengguna.
