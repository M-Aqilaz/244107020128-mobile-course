# Dokumentasi AI Prompt Challenge — Minggu 03

## 1. Prompt Desain & Kode
Prompt yang diajukan ke AI coding assistant:
```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry), dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI (Boilerplate)
AI menghasilkan struktur dasar berikut:
```dart
class StatsData {
  final int total;
  final int completed;
  final double rate;
  StatsData({required this.total, required this.completed, required this.rate});
}

class StatsNotifier extends AsyncNotifier<StatsData> {
  @override
  Future<StatsData> build() async {
    await Future.delayed(const Duration(seconds: 2));
    if (Random().nextDouble() < 0.3) {
      throw Exception('Network error');
    }
    return StatsData(total: 10, completed: 5, rate: 50.0);
  }
}
```

---

## 3. Checklist Verifikasi & Temuan Teknis

| Parameter Verifikasi | Status | Evaluasi & Temuan |
| :--- | :---: | :--- |
| **Immutability State** | **Lolos** | Model `StatsData` bersifat immutable, tidak ada mutasi langsung pada state objek. |
| **`ref.watch` vs `ref.read`** | **Lolos** | `ref.watch(statsProvider)` hanya digunakan di dalam method `build()`, sedangkan event pemicu (seperti retry / refresh) menggunakan `ref.read` atau `ref.invalidate`. |
| **Penanganan 3 State `AsyncValue`** | **Lolos** | `AsyncValue.when` menangani ketiga kondisi: `loading:`, `error:`, dan `data:` secara lengkap tanpa mengabaikan kondisi error. |
| **Standar Riverpod Modern** | **Lolos** | Menggunakan arsitektur modern Riverpod (`AsyncNotifier` & `AsyncNotifierProvider`) bukan pattern usang (`StateNotifierProvider` atau `StateProvider`). |
| **Type Safety Eksplisit** | **Lolos** | Deklarasi provider memiliki pengetikan tipe lengkap: `AsyncNotifierProvider<StatsNotifier, StatsData>`. |
| **Linter & Test** | **Lolos** | Tidak ada warning linter (`flutter analyze` 0 issue) dan widget test lulus. |

---

## 4. Perbaikan & Penyesuaian Mandiri

1. **Integrasi Nyata dengan State ToDo:**
   * Pada output awal AI, nilai data statistik di-hardcode (`total: 10, completed: 5`).
   * **Perbaikan:** Menghubungkan pembacaan state langsung ke `ref.read(todoListProvider)` agar angka statistik dihitung secara dinamis dan akurat dari daftar ToDo aktif.
2. **Reaktivitas Simulasi Error (`forceErrorProvider`):**
   * Menyediakan provider terpisah `forceErrorProvider` untuk mengendalikan simulasi kegagalan jaringan saat pengujian dan demonstrasi, sehingga state simulasi tidak hilang saat notifier di-rebuild.
3. **Penyempurnaan UI Material 3:**
   * Kartu statistik dirancang ulang menggunakan `Card`, `CircleAvatar` berikon tematik, typography hirarkis, serta tombol "Coba Lagi (Retry)" yang responsif memanggil `ref.invalidate(statsProvider)`.
