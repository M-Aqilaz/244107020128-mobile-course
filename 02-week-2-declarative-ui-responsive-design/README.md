# Minggu 02 — Declarative UI & Responsive Design

* **Nama:** Muhammad Aqil Azami
* **NIM:** 244107020128
* **Kelas:** TI-3H
* **Mata Kuliah:** Pemrograman Mobile
* **Repository:** [244107020128-mobile-course](https://github.com/M-Aqilaz/244107020128-mobile-course)

---

## 1. Praktikum: Layout Sederhana (Warm-up)

Praktikum awal mempelajari widget tata letak dasar Flutter: `StatelessWidget`, `Container`, `Row`, `Column`, dan `Expanded` untuk menyusun kartu profil mahasiswa ([`lib/warmup.dart`](lib/warmup.dart)).

| 1. Ukuran Default | 2. Tanpa Expanded |
| :---: | :---: |
| ![Default Size](screenshot/sizeDefault.png) | ![No Expand](screenshot/noExpand.png) |

| 3. Menggunakan Expanded | 4. Penambahan Informasi Email |
| :---: | :---: |
| ![Expand](screenshot/expand.png) | ![Plus Email](screenshot/plusEmail.png) |

---

## 2. Praktikum: Dashboard Responsif

Mengubah dashboard dari `StatelessWidget` menjadi `StatefulWidget` serta menambahkan `CupertinoSwitch` pada `AppBar` untuk mengganti tema (Light/Dark Mode).

### Before & After
| Before (Stateless) | After (Light Mode) | After (Dark Mode) |
| :---: | :---: | :---: |
| ![Before](screenshot/before_dashboard.png) | ![After Light](screenshot/after_light.png) | ![After Dark](screenshot/after_dark.png) |

### 4 Eksperimen Layout
1. **Ubah Breakpoint ke 350:** Layar ponsel otomatis menampilkan 2 kolom karena lebar layar melebihi 350 dp.
   ![Exp 1](screenshot/exp1_breakpoint_2col.png)
2. **Ubah ke ThemeMode.dark:** Menyetel tema gelap secara langsung di `MaterialApp`.
   ![Exp 2](screenshot/exp2_thememode_dark.png)
3. **Uji di Layar Lebar (Landscape):** Tampilan otomatis beralih menjadi 2 kolom saat lebar layar >= 600 dp.
   ![Exp 3](screenshot/exp3_screen_wide.png)
4. **Semantics (Aksesibilitas):** Menambahkan label pembaca layar yang terverifikasi melalui Semantics Debugger.
   ![Exp 4](screenshot/exp4_semantics.png)

---

## 3. Tugas Utama: Academic Overview

Mengembangkan dashboard menjadi halaman **Academic Overview** ([`lib/main.dart`](lib/main.dart)) dengan ketentuan:
* Header profil mahasiswa menggunakan `Row`, `Column`, `Expanded`, dan `Container`.
* 4 kartu informasi akademik (SKS Selesai, IPK Kumulatif, Kehadiran, Status).
* Responsif: 1 kolom pada layar sempit (< 600 dp) dan 2 kolom pada layar lebar (>= 600 dp).
* Toggle tema terang dan gelap menggunakan `CupertinoSwitch`.

| Layar Sempit (Light Mode) | Layar Sempit (Dark Mode) |
| :---: | :---: |
| ![Tugas Sempit Light](screenshot/tugas_narrow_light.png) | ![Tugas Sempit Dark](screenshot/tugas_narrow_dark.png) |

| Layar Lebar (Light Mode) | Layar Lebar (Dark Mode) |
| :---: | :---: |
| ![Tugas Lebar Light](screenshot/tugas_wide_light.png) | ![Tugas Lebar Dark](screenshot/tugas_wide_landscape.png) |

---

## 4. AI Prompt Challenge

Setelah implementasi mandiri selesai, AI digunakan untuk membandingkan dua alternatif tata letak kode, memperdalam konsep, dan melakukan audit mandiri:

### 1. Prompt Desain: Komparasi Alternatif Tata Letak
* **Prompt:**  
  > *"Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off responsif dan aksesibilitasnya."*

* **Hasil Komparasi AI:**

  | Kriteria | Alternatif 1: Versi `GridView` | Alternatif 2: Versi `LayoutBuilder` + `Column` |
  | :--- | :--- | :--- |
  | **Penyusunan Kolom** | Otomatis via `crossAxisCount` | Harus dihitung dan dibagi manual per baris |
  | **Dimensi Kartu** | Terikat rasio aspek (`childAspectRatio`) | Fleksibel mengikuti tinggi konten dinamis |
  | **Risiko Layout Error** | Rawan konflik scroll jika di dalam scrollable parent | Bebas dari konflik scrolling bawaan |
  | **Aksesibilitas** | Terbaca berurutan per baris grid | Urutan traversal screen reader lebih fleksibel diatur |

* **Keputusan Tata Letak yang Dipilih:**  
  Menerapkan **kombinasi keduanya**: menggunakan `LayoutBuilder` untuk mendeteksi breakpoint lebar layar, yang di dalamnya membungkus `GridView.count` dengan `shrinkWrap: true` dan `physics: NeverScrollableScrollPhysics()` di dalam `SingleChildScrollView`.
* **Alasan Teknis:**  
  Karena 4 kartu metrik memiliki dimensi dan struktur seragam, `GridView` memberikan kerapian jarak (*spacing*) yang konsisten tanpa perlu komputasi matematika manual, sementara `LayoutBuilder` memberikan kontrol breakpoint yang responsif.

### 2. Prompt Penguatan Konsep (Expanded di dalam Row)
* **Prompt:**  
  > *"Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan perbaikannya."*
* **Output AI:**  
  `Expanded` membutuhkan batasan lebar (*bounded width*) dari parent-nya. Jika `Row` ditaruh di dalam parent dengan lebar tak terbatas seperti `SingleChildScrollView(scrollDirection: Axis.horizontal)`, `Expanded` memicu runtime error: `BoxConstraints forces an infinite width`.
* **Contoh Kode Gagal:**
  ```dart
  // ERROR: Infinite width
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        Expanded(child: Text('Teks Error')),
      ],
    ),
  )
  ```
* **Contoh Perbaikan:**
  ```dart
  // PERBAIKAN: Beri batas lebar eksplisit atau gunakan Flexible
  SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        SizedBox(
          width: 200,
          child: Text('Teks Aman'),
        ),
      ],
    ),
  )
  ```

### 3. Verification Prompt (Self-Audit AI)
* **Prompt:**  
  > *"Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"*
* **Output AI:**  
  * **Responsivitas (<600px):** Terverifikasi aman. Di bawah 600px layout otomatis beralih ke 1 kolom penuh sehingga kartu tidak berdesakan.
  * **Aksesibilitas:** Terjaga. Pembungkusan `Semantics` pada switch dan kartu memastikan seluruh informasi terbaca jelas oleh screen reader.
  * **Ketersediaan Widget:** Seluruh widget (`LayoutBuilder`, `GridView`, `Card`, `CupertinoSwitch`, `Semantics`) merupakan API resmi Flutter stable.

### 4. Bukti Verifikasi
* **Visual:** Screenshot aplikasi pada layar sempit ([`screenshot/tugas_narrow_light.png`](screenshot/tugas_narrow_light.png)) dan layar lebar ([`screenshot/tugas_wide_light.png`](screenshot/tugas_wide_light.png)).
* **Otomatis:** Lulus widget test responsif pada `test/widget_test.dart`.

---

## 5. Refactoring Challenge

Setelah tugas utama berjalan, kode dirapikan sesuai 4 ketentuan codelab:

1. **Ekstrak Kartu Informasi Menjadi Widget Reusable:**  
   Membuat widget `AcademicInfoCard` yang menerima parameter `title`, `value`, `icon`, dan `badgeColor` untuk menghindari duplikasi kode:
   ```dart
   class AcademicInfoCard extends StatelessWidget {
     const AcademicInfoCard({
       required this.title,
       required this.value,
       required this.icon,
       this.badgeColor,
       super.key,
     });
     final String title;
     final String value;
     final IconData icon;
     final Color? badgeColor;
     // ...
   }
   ```

2. **Ganti Hardcoded Color dengan `Theme.of(context)`:**  
   Warna teks, latar kartu, dan border mengikuti tema terang/gelap secara dinamis:
   ```dart
   color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
   style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
   ```

3. **Pusatkan Breakpoint ke Satu Konstanta Bernama:**  
   Breakpoint didefinisikan satu kali di tingkat atas:
   ```dart
   const double kWideBreakpoint = 600.0;
   ```

4. **Verifikasi Linter (`flutter analyze`):**  
   ```powershell
   flutter analyze
   # Output: No issues found! (ran in 2.1s)
   ```

---

## 6. Testing Dasar (Widget Testing)

Pengujian otomatis perilaku responsif dibuat pada file [`test/widget_test.dart`](test/widget_test.dart):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:we2/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AcademicOverviewApp());

    final width = tester.getSize(find.byType(Card).first).width;
    expect(width, greaterThan(500));
  });
}
```

Jalankan pengujian via terminal:
```powershell
flutter test
```
**Hasil Test (Lulus):**
```text
00:00 +0: loading test/widget_test.dart
00:00 +0: Dashboard satu kolom di layar sempit
00:00 +1: Dashboard dua kolom di layar lebar
00:01 +2: All tests passed!
```

---

## 7. Refleksi

1. **Imperative vs Declarative:** Imperative mengatur UI langkah demi langkah secara manual, sedangkan declarative mendeskripsikan UI berdasarkan state saat ini (`UI = f(state)`).
2. **Kapan Expanded membantu vs error:** Membantu membagi sisa ruang kosong secara fleksibel, tapi menyebabkan error jika parent-nya tidak memiliki batas ukuran (*unbounded constraints*).
3. **Pengaruh Breakpoint & Theme:** Breakpoint menjaga layout tetap rapi di berbagai ukuran layar, sedangkan theme membuat aplikasi nyaman di mata baik di kondisi terang maupun gelap.
4. **Verifikasi AI:** Memastikan rekomendasi AI kompatibel dengan Flutter stable, tidak memicu bug layout di layar kecil, dan strukturnya dapat dijelaskan saat code review.
