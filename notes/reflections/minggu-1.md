# Refleksi Minggu 1 — Mobile Development Ecosystem & Flutter Refresh

NIM: 244107020128
Nama: Muhammad Aqil Azami
Mata kuliah: Pemrograman Mobile — Minggu 1

---

## 1. Kapan native lebih tepat dipilih daripada cross-platform?

Native (Kotlin/Java untuk Android, Swift/Objective-C untuk iOS) lebih tepat
ketika aplikasi sangat bergantung pada kemampuan perangkat keras tingkat rendah
atau performa maksimal. Contohnya: game berat dengan rendering 3D, aplikasi
augmented reality, edit video, atau fitur yang butuh akses langsung ke API
sistem operasi terbaru secepat mungkin setelah rilis.

Cross-platform seperti Flutter menambahkan satu lapisan abstraksi (engine
rendering sendiri), sehingga ada jeda saat mengikuti fitur OS terbaru dan
sedikit overhead performa dibanding native murni. Untuk aplikasi bisnis, CRUD,
dashboard, atau MVP, cross-platform jauh lebih hemat waktu dan biaya karena
satu basis kode untuk dua platform. Tapi kalau per device capability atau
performance kritis adalah inti produk, native menang.

Singkatnya: pilih native bila fitur hardware-specific atau performa ekstrem
adalah syarat utama; pilih cross-platform bila kecepatan pengembangan dan
cakupan dua platform dengan tim kecil lebih penting.

---

## 2. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?

Flutter menggunakan UI deklaratif: kita mendeskripsikan UI sebagai fungsi dari
state. Widget tree adalah struktur hierarki widget yang merepresentasikan
tampilan saat ini.

Ketika state berubah (misal variabel counter bertambah), Flutter tidak
memodifikasi widget lama secara langsung. Ia memanggil `build()` lagi,
membuat deskripsi widget tree yang baru, lalu melakukan diff dengan tree
sebelumnya. Hanya widget yang berubah yang di-rebuild/replace secara efisien
(berkat `Key` dan perbandingan runtimeType + key). Inilah mengapa kita pakai
`StatefulWidget` + `setState()` untuk state yang berubah: `setState()`
menandai bahwa ada perubahan sehingga framework menjadwalkan rebuild.

Dalam aplikasi profil ini state statis (StatelessWidget cukup) karena tidak
ada interaksi yang mengubah tampilan. Tapi pola yang sama berlaku: UI selalu
cermin dari state, bukan hasil mutasi manual widget.

---

## 3. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?

Commit kecil dengan pesan jelas memberi beberapa keuntungan:

- **Review lebih mudah**: reviewer paham satu perubahan fokus per commit,
  bukan ratusan baris campur aduk.
- **Git bisect & rollback presisi**: kalau ada bug, kita bisa telusuri commit
  mana yang memicunya dan revert hanya bagian itu tanpa merusak fitur lain.
- **Sejarah terbaca**: pesan seperti `feat: add NIM & extra info` langsung
  jelaskan maksud tanpa buka diff.
- **Portfolio**: penguji (dosen/recruiter) melihat proses berpikir yang rapi
  lewat riwayat commit, bukan sekadar hasil akhir. Ini sinyal disiplin
  engineering, bukan cuma "kerja beres".

Konvensi seperti Conventional Commits (`feat:`, `fix:`, `docs:`) membuat
riwayat konsisten dan bisa diotomatisasi (changelog, release notes).
