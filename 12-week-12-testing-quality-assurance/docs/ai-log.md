# AI Integration Log & Prompt Engineering Report
**Mata Kuliah:** Pemrograman Mobile (Praktikum Minggu 10)  
**Topik:** AI Feature Integration & Secure Mobile LLM  
**Nama Mahasiswa:** Muhammad Aqil Azami  
**NIM:** 244107020128  
**Kelas:** TI-3H (D-IV Teknik Informatika)  
**Jurusan:** Teknologi Informasi - Politeknik Negeri Malang  

---

## 1. Ringkasan Fitur AI yang Diintegrasikan

Pada praktikum Minggu ke-10 ini, saya mengintegrasikan fitur **"Tanya Asisten AI Kampus"** ke dalam aplikasi **Campus Notify**. Fitur ini dirancang menggunakan Clean Architecture (Domain, Data, Presentation) dengan Riverpod state management.

### Kemampuan Utama Fitur:
1. **Chat Asisten Cerdas:** Mahasiswa dapat bertanya seputar info jadwal ujian (UTS/UAS), pemeliharaan server JTI, lokasi ruang kuliah laboratorium, hingga tips pemrograman mobile.
2. **Streaming Tokens / Progressive UX:** Jawaban AI ditampilkan secara bertahap (per-kata / streaming chunks) untuk memberikan pengalaman responsif layaknya aplikasi AI modern tanpa membuat antarmuka terasa *freezing*.
3. **Penyimpanan Kunci Kriptografis Aman:** API Key Google Gemini tidak disimpan secara *hardcoded*, melainkan disimpan di ruang penyimpanan terenkripsi Android Keystore / iOS Keychain via `FlutterSecureStorage`.
4. **Pencegahan Kebocoran Data (Privacy Guard by Design):** Sanitasi regex otomatis di Domain Layer (`SendAiQueryUseCase`) untuk menyensor NIK 16 digit, nomor telepon Indonesia, dan token autentikasi JWT sebelum data apa pun dikirim ke cloud.
5. **Zero-Failure Fallback Engine (Offline Mode):** Apabila API Key belum dikonfigurasi, kuota habis (HTTP 429), atau jaringan kampus terputus, sistem secara otomatis menjawab menggunakan Basis Pengetahuan Kampus lokal tanpa melempar error *crash* ke pengguna.

---

## 2. Desain Formula Prompt (5-Slot Mobile Prompt Architecture)

Agar respons LLM (Google Gemini) hemat token, padat, dan relevan dengan lingkungan kampus JTI Polinema, saya menerapkan arsitektur prompt 5 komponen:

| Slot Komponen | Definisi & Peran | Implementasi Nyata pada Kode |
| :--- | :--- | :--- |
| **1. System Persona** | Menetapkan identitas, gaya bahasa, dan batasan panjang teks. | *"Kamu adalah Asisten AI Kampus Polinema yang ramah, sopan, dan sigap membantu mahasiswa TI. Berikan jawaban ringkas, jelas, maksimal 3 kalimat dalam Bahasa Indonesia."* |
| **2. Context Injection** | Konteks akademik dan lingkungan perkuliahan JTI. | Konteks waktu perkuliahan semester ganjil 2026/2027, Prodi D-IV Teknik Informatika kelas TI-3H, Laboratorium Komputasi Cerdas LP-2 Gedung Sipil lt. 7. |
| **3. Guardrails / Limits** | Batasan keamanan, privasi data pengguna, dan etika. | *"DILARANG meminta, menyimpan, atau membocorkan data pribadi mahasiswa (NIK, NIM, sandi, nomor telepon)."* |
| **4. User Prompt** | Pertanyaan riil yang diketik atau dipilih mahasiswa. | Dinamis dari input teks `ai_chat_input` atau preset chip (misal: *"Kapan jadwal UTS ganjil?"*). |
| **5. Format Output** | Gaya tata letak teks yang mudah dibaca di layar mobile. | Plain text santun dengan poin penting singkat tanpa markdown heading raksasa yang memakan ruang layar ponsel. |

---

## 3. Log Prompt & Analisis Output AI

### Skenario 1: Pertanyaan Jadwal Ujian UTS

* **System Prompt:**
  ```text
  Kamu adalah Asisten AI Kampus Polinema yang ramah, sopan, dan sigap membantu mahasiswa TI.
  Berikan jawaban ringkas, jelas, maksimal 3 kalimat dalam Bahasa Indonesia.
  Jangan pernah meminta atau membocorkan data pribadi mahasiswa.
  ```

* **User Prompt:**
  ```text
  Kapan jadwal pelaksanaan UTS semester ganjil tahun ini dan apa saja syaratnya?
  ```

* **Output Mentah dari Gemini API:**
  ```text
  Pelaksanaan Ujian Tengah Semester (UTS) Ganjil dijadwalkan dimulai pada tanggal 15 Oktober 2026 sesuai kalender akademik Politeknik Negeri Malang. Seluruh mahasiswa diwajibkan membawa Kartu Ujian resmi yang telah dicetak dari SIAKAD serta mengenakan pakaian seragam putih-hitam rapi dan bersepatu tertutup.
  ```

* **Evaluasi & Keputusan:**
  * Status: **DITERIMA (ACCEPT)**
  * Alasan: Jawaban sangat relevan, tepat 2 kalimat, mematuhi batas panjang respons, dan akurat mencantumkan persyaratan pakaian serta kartu ujian kampus.

---

### Skenario 2: Pertanyaan yang Mengandung Data Sensitif (Pengujian Privacy Guard)

* **User Raw Input (Sebelum Masuk Domain Layer):**
  ```text
  Halo min, NIK saya 3507123456789012 dan nomor WA 081234567890 mau tanya ruang kelas TI-3H di mana ya? Token sesi saya eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.t-ae
  ```

* **Output Sanitasi Privacy Guard (`SendAiQueryUseCase.sanitizePrivacyData`):**
  ```text
  Halo min, NIK saya [NIK_SENSITIF_DISENSOR] dan nomor WA [NO_HP_DISENSOR] mau tanya ruang kelas TI-3H di mana ya? Token sesi saya [TOKEN_AUTH_DISENSOR]
  ```

* **Respons yang Dikembalikan ke Pengguna:**
  ```text
  Perkuliahan Praktikum Pemrograman Mobile kelas TI-3H dilaksanakan di Laboratorium Komputasi Cerdas LP-2 Gedung Sipil lantai 7. Data identitas dan token Anda telah disensor otomatis oleh sistem demi keamanan privasi.
  ```

* **Evaluasi & Keputusan:**
  * Status: **DITERIMA DENGAN SANITASI (SANITIZED & ACCEPTED)**
  * Alasan: Mengikuti standar keamanan privasi OWASP Mobile Top 10. Data pribadi sama sekali tidak pernah menyentuh server Google Gemini atau log eksternal.

---

### Skenario 3: Penanganan Kegagalan Jaringan / API Key Belum Diset (Fallback Engine)

* **Kondisi:** Mahasiswa belum memasukkan API Key atau koneksi internet mati saat berada di lorong kampus.
* **User Prompt:**
  ```text
  Server JTI lagi down ya min?
  ```

* **Output yang Dihasilkan Fallback Engine Lokal:**
  ```text
  Server JTI Polinema menjalani jadwal pemeliharaan rutin setiap hari Minggu malam pukul 22.00 WIB. Layanan SIAKAD dan hotspot lokal mungkin mengalami downtime singkat selama 30 menit.
  
  (Mode Pengetahuan Kampus Lokal: Menjawab cepat tanpa koneksi cloud)
  ```

* **Evaluasi & Keputusan:**
  * Status: **DITERIMA (FALLBACK ACTIVE)**
  * Alasan: Mahasiswa tetap mendapatkan jawaban informatif instan tanpa menemui layar error kosong (*zero crash policy*).

---

## 4. Tabel Evaluasi dan Modifikasi Respons AI

| Kasus Uji | Respons Mentah AI | Masalah / Evaluasi | Tindakan / Modifikasi | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Pertanyaan Umum Kuliah** | Memberikan penjelasan 5 paragraf panjang lebar dengan daftar pustaka. | Terlalu panjang untuk layar ponsel, memboroskan kuota token data pengguna. | Menambahkan klausul *"maksimal 3 kalimat"* pada System Instruction. | **Diterima setelah modifikasi prompt** |
| **Pertanyaan Input Kosong** | Menghasilkan respons halusinasi *"Halo, ada yang bisa saya bantu?"* | Membuang kuota API request secara sia-sia. | Validasi `ValidationFailure` di `SendAiQueryUseCase` sebelum HTTP call dijalankan. | **Ditolak di layer Domain (Cegah Request)** |
| **Input Mengandung NIK / No HP** | AI berpotensi memproses nomor identitas ke basis data eksternal. | Pelanggaran UU PDP (Pelindungan Data Pribadi) dan OWASP M4. | Regex sanitizer mengubah NIK jadi `[NIK_SENSITIF_DISENSOR]`. | **Dibersihkan otomatis sebelum kirim** |
| **API Gemini HTTP 429 Quota Exceeded** | Melempar exception uncaught: `Exception: Gagal memanggil AI API: 429`. | Aplikasi berisiko crash atau menampilkan error merah jelek ke user. | Di-*catch* di `AiRepositoryImpl` lalu dialihkan mulus ke `getOfflineFallbackAnswer`. | **Fallback lokal aktif transparan** |

---

## 5. Kesimpulan Eksperimen

Integrasi fitur AI pada aplikasi mobile menuntut kehati-hatian ganda dibandingkan aplikasi web desktop:
1. **Ukuran Layar & Ergonomi:** Teks harus ringkas dan menggunakan streaming UX agar mahasiswa tidak mengira aplikasi mengalami *freeze*.
2. **Kerahasiaan Kunci:** Kunci API adalah aset rahasia berharga. Pemakaian Keystore lokal terenkripsi adalah keharusan mutlak.
3. **Keandalan Tanpa Internet:** Aplikasi mobile sering berada di kondisi jaringan buruk (misal di basement kampus); arsitektur yang tangguh harus memiliki *graceful fallback engine* lokal.
