# Dokumentasi AI Prompt Challenge — Minggu 04: Networking & REST API

## 1. Prompt Desain & Kode
Prompt yang diajukan ke AI coding assistant sesuai instruksi Codelab Minggu 4:
```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal AI (Boilerplate)
AI menghasilkan rancangan kode awal sebagai berikut:
```dart
class Comment {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] as int, // Rawan crash jika null / double
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

class CommentRepository {
  Future<List<Comment>> fetchComments(int postId) async {
    final dio = Dio(); // Anti-pattern: membuat Dio baru tanpa client terpusat
    final response = await dio.get(
      'https://jsonplaceholder.typicode.com/comments?postId=$postId',
    );
    return (response.data as List).map((e) => Comment.fromJson(e)).toList();
  }
}
```

---

## 3. Checklist Verifikasi & Evaluasi Teknis

| Parameter Verifikasi | Status | Evaluasi & Catatan |
| :--- | :---: | :--- |
| **Pemisahan UI dan Network Client** | **Lolos** | UI tidak memanggil Dio secara langsung; seluruh akses jaringan melalui `CommentRepository` dan `commentsProvider`. |
| **Null-Safety Defensif pada Model** | **Diperbaiki** | Kode awal AI masih menggunakan `as int` dan `as String`. Jika API merespons nilai `null`, aplikasi langsung crash. Diperbaiki dengan defensive cast: `(json['postId'] as num?)?.toInt() ?? 0` dan `json['name'] as String? ?? ''`. |
| **Klien Dio Terpusat** | **Diperbaiki** | AI membuat `Dio()` baru di dalam method repository. Diperbaiki agar `CommentRepository` menerima instance `Dio` dari `dioProvider` yang sudah memiliki `baseUrl`, timeout, dan interceptor terpusat. |
| **Pemetaan Error Ramah Pengguna** | **Lolos** | Menggunakan `friendlyErrorMessage()` dari `network_errors.dart` yang memetakan timeout, koneksi terputus, 404, dan error server 500 ke pesan bahasa Indonesia yang mudah dipahami. |
| **Pengujian Unit Kasus Ekstrem** | **Lolos** | Ditambahkan unit test pada `test/comment_test.dart` yang menguji parsing payload dengan field hilang/kosong, parsing payload valid, dan serialisasi `toJson()`. |
| **Hasil Analisis Linter & Test** | **Lolos** | `flutter analyze` 0 issue (`No issues found!`) dan seluruh pengujian otomatis lulus 100%. |

---

## 4. Perbaikan & Penyesuaian Mandiri

1. **Penerapan Defensive Parsing pada Model `Comment`:**
   Semua casting tipe data pada `Comment.fromJson` diubah agar menggunakan fallback default value, sehingga tidak pernah terjadi error runtime `type 'Null' is not a subtype of type 'String'` maupun cast error numerik.
2. **Injeksi Dependency Dio Terpusat:**
   Konstruktor `CommentRepository(this._dio)` dihubungkan dengan `ref.watch(dioProvider)` agar mewarisi timeout 10 detik, base URL, serta logger interceptor yang seragam.
3. **Integrasi ke Halaman Detail:**
   Fitur komentar ini diintegrasikan langsung ke halaman detail postingan (`PostDetailPage`) menggunakan `commentsProvider.family`, lengkap dengan avatar inisial pengirim dan kartu komentar yang rapi sesuai tema Material 3.
