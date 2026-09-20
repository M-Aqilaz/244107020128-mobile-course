# Laporan Praktikum — Minggu 04: Networking & REST API

* **Nama:** Muhammad Aqil Azami
* **NIM:** 244107020128
* **Kelas:** TI-3H
* **Mata Kuliah:** Pemrograman Mobile

---

## 1. Praktikum 1: Dio dan Model Data
Menyiapkan dependencies `dio`, `flutter_riverpod`, dan `go_router`. Membuat model `Post` dengan `fromJson` yang aman dari null (`?? ''`, `?? 0`), serta konfigurasi Dio terpusat di `lib/data/api_client.dart` dengan timeout 10 detik.

---

## 2. Praktikum 2: State Management & Error Handling
Mengatur state daftar post menggunakan Riverpod (`AsyncNotifier` & `AsyncValue`). UI menangani 4 kondisi: loading, sukses, data kosong, dan error dengan tombol coba lagi.

| Loading | Sukses (Daftar Posts) |
| :---: | :---: |
| ![Posts Loading](screenshots/01_posts_loading.png) | ![Posts Success](screenshots/02_posts_success.png) |

| Data Kosong | Error & Coba Lagi |
| :---: | :---: |
| ![Posts Empty](screenshots/03_posts_empty.png) | ![Posts Error Retry](screenshots/04_posts_error_retry.png) |

---

## 3. Praktikum 3: Pagination (Infinite Scroll)
Menerapkan pagination 10 item per halaman dengan parameter `_page` dan `_limit`. Menggunakan `ScrollController` untuk memuat data berikutnya saat scroll mendekati bawah.

| Infinite Scroll | Batas Akhir Data |
| :---: | :---: |
| ![Paged Infinite Scroll](screenshots/05_paged_infinite_scroll.png) | ![Paged End of List](screenshots/06_paged_end_of_list.png) |

---

## 4. Refactoring & AI Challenge
- **Refactoring:** Memisahkan widget item ke `lib/widgets/post_tile.dart`, memindahkan fungsi pesan error ke `lib/data/network_errors.dart`, dan membuat halaman detail `/post/:id` lengkap dengan komentar.
- **AI Challenge:** Meminta AI membuat repository komentar (`GET /comments`), lalu memperbaiki kodenya agar pakai null-safety defensif dan Dio terpusat. Detail lengkap ada di [docs/ai_challenge.md](docs/ai_challenge.md).

| Halaman Detail Post & Komentar |
| :---: |
| ![Detail Post Page](screenshots/07_post_detail_page.png) |

---

## 5. Pengujian (Testing)
Pengujian otomatis mencakup unit test model, error mapping, fake repository, dan widget test.

```powershell
flutter analyze
flutter test
```

| Hasil Analyze & Test (10/10 Passed) |
| :---: |
| ![Hasil Analyze dan Test](screenshots/08_flutter_analyze_test.png) |

---

## 6. Refleksi

1. **Kenapa UI dilarang panggil Dio langsung?**  
   Biar kode tampilan nggak kecampur sama urusan jaringan. Kalau ada ganti URL atau format data, cukup ubah di repository tanpa perlu ngacak-ngacak UI.

2. **Kapan pakai pagination client vs server?**  
   Pagination client cukup kalau datanya sedikit (di bawah 50–100 data). Tapi kalau datanya ratusan atau ribuan, wajib pagination server biar hemat kuota dan aplikasi nggak lemot.

3. **Gimana error repository jadi `AsyncError` tanpa try-catch di UI?**  
   Karena method `build()` di `AsyncNotifier` otomatis menangkap exception dari repository dan mengubahnya jadi `AsyncError`. UI tinggal baca lewat `.when(error: ...)`.

4. **Bagian kode AI apa yang diperbaiki?**  
   Model `Comment.fromJson` bawaan AI masih pakai casting langsung tanpa null-safety, jadi rawan crash kalau ada data null. Kodenya saya perbaiki pakai fallback nilai default dan disambungkan ke client Dio terpusat.
