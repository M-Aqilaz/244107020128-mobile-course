# Laporan Identifikasi Masalah Performa (Profiling Findings)
## Praktikum Pemrograman Mobile - Minggu 11 (Optimasi Performa)

**Identitas Mahasiswa:**
- **Nama:** Muhammad Aqil Azami
- **NIM:** 244107020128
- **Kelas:** TI-3H
- **Program Studi:** D-IV Teknik Informatika
- **Jurusan:** Teknologi Informasi - Politeknik Negeri Malang

---

## 1. Metodologi Baseline Profiling

Sebelum melakukan perbaikan kode, aplikasi `campus_notify` dijalankan pada mode profil (*profile mode*):
```powershell
flutter run --profile
```
Profiling dilakukan menggunakan **Flutter DevTools** dengan skenario uji standar selama 30 detik:
1. Membuka halaman Beranda (`HomePage`).
2. Melakukan *fast scrolling* bolak-balik pada daftar pengumuman kampus.
3. Mengetikkan kata kunci pencarian di *search bar*.
4. Membuka detail pengumuman (`/pengumuman/1`) dan kembali ke beranda sebanyak 5 kali berturut-turut.
5. Membuka fitur *Tanya AI Kampus* (`/ai-chat`) dan kembali ke beranda.

---

## 2. Temuan Bottleneck & Analisis Masalah

Berdasarkan rekaman DevTools pada tab **Performance (CPU Profiling)** dan **Memory**, teridentifikasi 4 (empat) masalah performa utama:

### A. Widget Rebuild Berlebih pada Root Widget (`HomePage`)
- **Gejala pada Flame Chart:** Saat pengguna mengetik di kotak pencarian atau saat token FCM diperbarui, seluruh pohon widget di `HomePage` ikut di-*build* ulang secara berulang (*repetitive build calls*).
- **Akar Masalah:**
  1. Penggunaan `ref.watch(provider)` pada level root `_HomePageState.build()` tanpa seleksi field spesifik (`select`), sehingga perubahan kecil pada status token atau pencarian memicu re-render kartu profil, kartu keystore FCM, dan tombol panel uji.
  2. Deklarasi widget UI statis tidak menggunakan `const constructor`.
- **Dampak:** Terjadi lonjakan frame time hingga **24.8 ms** per frame (melebihi batas aman 16.6 ms untuk 60 FPS), menyebabkan *jank* sebanyak 14 frame saat pengetikan cepat.

### B. Daftar Pengumuman Menggunakan `Column` Tanpa *Lazy Loading*
- **Gejala pada Flame Chart:** Durasi tahapan `Layout` dan `Paint` meningkat drastis saat memuat daftar data pengumuman.
- **Akar Masalah:** Pengumuman di-render menggunakan `Column(children: announcements.map(...).toList())`. Kode ini memaksa Flutter membuat seluruh objek widget elemen pengumuman sekaligus di memori, meskipun item tersebut berada jauh di luar layar (*viewport*).
- **Dampak:** Beban alokasi memori instan melonjak dan raster thread GPU mengalami antrean beban rendering.

### C. Alokasi Memori Kartu Item & Potensi *Memory Leak*
- **Gejala pada Tab Memory:** Grafik Heap Memory menunjukkan akumulasi memori yang bertambah setiap kali pengguna melakukan navigasi bolak-balik dari beranda ke halaman detail pengumuman dan fitur chat AI.
- **Akar Masalah:**
  1. Kontroler input (`TextEditingController`) dan listener asinkron belum dibersihkan secara disiplin pada siklus hidup `dispose()`.
  2. Kartu item pengumuman yang berada di dalam list tidak dibungkus dengan `RepaintBoundary`, sehingga satu perubahan kecil di area kartu memicu pengecatan ulang (*repaint*) seluruh kanvas list.
- **Dampak:** Memori dasar naik dari ~42 MB menjadi ~68 MB setelah beberapa siklus navigasi.

### D. Pengambilan Data Jaringan Berulang Tanpa Strategi Caching
- **Gejala pada Tab Network:** Setiap kali halaman beranda dimuat ulang atau navigasi kembali dari halaman detail, repository memanggil sumber data jaringan secara mentah tanpa validasi cache lokal.
- **Akar Masalah:** `AnnouncementRepositoryImpl` belum mengimplementasikan pola *Stale-While-Revalidate* atau in-memory cache dengan TTL (*Time-To-Live*).
- **Dampak:** Konsumsi kuota data dan latensi jaringan yang tidak perlu, serta aplikasi terasa lambat jika koneksi internet mahasiswa tidak stabil.

---

## 3. Rencana Tindakan Optimasi

| No | Komponen Terdampak | Rencana Optimasi | Target Metrik |
| :---: | :--- | :--- | :--- |
| 1 | `home_page.dart` | Tambahkan `const constructor`, isolasi state dengan Riverpod `select`, dan ekstrak sub-widget. | Frame time turun ke < 10 ms (stabil 60 FPS). |
| 2 | Daftar Pengumuman | Ganti `Column` menjadi `ListView.builder` dan implementasikan *infinite scroll pagination*. | Waktu layout berkurang > 60%, item di luar viewport tidak di-render. |
| 3 | `AnnouncementItemCard` | Ekstrak menjadi `StatelessWidget` terpisah dan bungkus dengan `RepaintBoundary`. | Membatasi repaint hanya pada item yang disentuh/berubah. |
| 4 | `announcement_repository_impl.dart` | Terapkan *Stale-While-Revalidate* in-memory cache. | Cache hit meningkat, panggilan jaringan berulang berkurang 100%. |
| 5 | Siklus Hidup Widget | Pastikan pemanggilan `dispose()` pada semua controller dan subscription. | Heap memory stabil tanpa kebocoran saat navigasi berulang. |
