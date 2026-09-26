# Dokumentasi AI Challenge — Minggu 05: Local Storage & Offline-First

## 1. Prompt yang Digunakan
Sesuai panduan Codelab Minggu 5 (Step 5), saya mengajukan prompt perbandingan storage ke AI assistant:

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift untuk dua kebutuhan ini.
Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream), type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan, beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Output Awal dari AI

AI memberikan perbandingan 4 opsi storage lokal beserta skema dasarnya:

### Tabel Perbandingan AI:
| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat rendah (key-value) | Rendah (filter in-memory) | Tinggi (SQL standar, sorting, where) | Sangat tinggi (type-safe SQL / Dart API) |
| **Kebutuhan Relasi** | Tidak mendukung | Tidak mendukung (manual linking) | Mendukung penuh (Foreign Key) | Mendukung penuh dengan relasi objek |
| **Reaktivitas (Stream)** | Tidak ada bawaan | Mendukung (`watchBox`) | Perlu kombinasi Stream/Riverpod | Mendukung penuh bawaan (`watch()`) |
| **Type-Safety** | Lemah (dynamic parsing) | Sedang (TypeAdapter) | Menengah (Map parsing manual) | Sangat kuat (code generation) |
| **Boilerplate** | Sangat kecil | Kecil - Menengah | Sedang (SQL string & helper) | Besar (build_runner & migrasi) |
| **Kemudahan Testing** | Sangat mudah (mock values) | Mudah (in-memory box) | Mudah (injeksi openDb / mock) | Perlu setup in-memory drift database |

### Rekomendasi Awal AI:
- **Preferensi Tema:** Menggunakan `SharedPreferences`.
- **Daftar Catatan:** AI merekomendasikan `Drift` untuk jangka panjang atau `Hive` untuk kecepatan setup.

---

## 3. Evaluasi & Temuan Kritis (Verification Checklist)

Setelah saya analisis dan sesuaikan dengan kebutuhan materi praktikum:

1. **Apakah AI menempatkan catatan di SharedPreferences?**  
   Tidak. AI dengan tepat menyatakan bahwa menyimpan catatan di SharedPreferences adalah anti-pattern karena data koleksi akan disimpan sebagai satu string JSON besar yang tidak efisien untuk query atau update sebagian.
2. **Apakah skema AI mendukung antrean sync (offline-first)?**  
   Pada output awal, skema AI hanya membuat kolom `id`, `title`, `body`, dan `createdAt`. AI melewatkan kolom penting untuk offline-first:
   - Kolom `dirty` (integer/boolean): untuk menandai catatan mana yang belum di-upload ke server.
   - Kolom `updated_at`: untuk dasar aturan resolusi konflik (*Last-Write-Wins*).  
   Bagian ini saya perbaiki langsung pada skema database project.
3. **Apakah estimasi boilerplate AI realistis?**  
   AI menyarankan Drift karena reaktif, tapi boilerplate Drift memerlukan `build_runner` yang memperlambat build time dan menambah beban dependensi yang berlebihan untuk modul catatan dasar.

---

## 4. Keputusan Final & Alasan Teknis

Untuk aplikasi **Offline Notes** minggu ini, keputusan final yang saya ambil adalah:
1. **Preferensi (Tema & Waktu Terakhir Dibuka): `SharedPreferences`**  
   - Sangat ringan, tidak butuh query rumit, dan membaca nilai boolean/string dengan cepat saat aplikasi dibuka.
2. **Catatan & Cache API: `SQLite (sqflite)`**  
   - Memiliki dukungan pengurutan (`ORDER BY updated_at DESC`), pemfilteran catatan kotor (`WHERE dirty = 1`), dan transaksi batch untuk cache posts tanpa memerlukan code generation yang rumit.
   - Dengan membungkus SQLite di dalam `NoteRepository(openDb: ...)`, kodenya tetap sangat mudah diuji menggunakan `FakeNoteRepository` tanpa database sungguhan saat testing.
