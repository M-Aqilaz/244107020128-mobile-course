# Dokumentasi AI Challenge — Minggu 04: Networking & REST API

## 1. Prompt yang Digunakan
Sesuai tugas AI Challenge di Codelab Minggu 4, saya meminta bantuan AI untuk merancang repository komentar:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id} dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError) dan fungsi pesan error ramah pengguna.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

---

## 2. Output Awal dari AI
Kode yang pertama kali dihasilkan oleh AI:

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
      postId: json['postId'] as int, // Rawan crash jika null
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

class CommentRepository {
  Future<List<Comment>> fetchComments(int postId) async {
    final dio = Dio(); // Membuat Dio baru sendiri tanpa client terpusat
    final response = await dio.get(
      'https://jsonplaceholder.typicode.com/comments?postId=$postId',
    );
    return (response.data as List).map((e) => Comment.fromJson(e)).toList();
  }
}
```

---

## 3. Analisis & Masalah pada Kode AI
Setelah saya pelajari dan uji, ada 2 masalah utama pada kode buatan AI:
1. **Rawan Crash karena Null:**  
   AI menggunakan casting langsung (`as int` dan `as String`). Kalau server API mengembalikan data null atau ada field yang hilang, aplikasi langsung error `type 'Null' is not a subtype of type 'String'`.
2. **Tidak Menggunakan Client Dio Terpusat:**  
   AI membuat instance `Dio()` baru di dalam fungsi `fetchComments`. Hal ini tidak sesuai materi praktikum, karena konfigurasi `baseUrl`, timeout 10 detik, dan logging interceptor yang sudah kita atur di `api_client.dart` jadi terabaikan.

---

## 4. Perbaikan yang Saya Lakukan
1. **Menambahkan Parsing Defensif pada Model `Comment`:**  
   Semua casting tipe data diubah agar memiliki nilai bawaan (fallback):
   ```dart
   factory Comment.fromJson(Map<String, dynamic> json) {
     return Comment(
       postId: (json['postId'] as num?)?.toInt() ?? 0,
       id: (json['id'] as num?)?.toInt() ?? 0,
       name: json['name'] as String? ?? '',
       email: json['email'] as String? ?? '',
       body: json['body'] as String? ?? '',
     );
   }
   ```
2. **Menghubungkan ke Dio Terpusat:**  
   Konstruktor repository diubah menjadi `CommentRepository(this._dio)` dan dihubungkan ke `dioProvider`. Dengan begitu, pemanggilan endpoint komentar tetap memanfaatkan timeout dan interceptor yang seragam.
3. **Membuat Pengujian Unit:**  
   Saya menambahkan unit test di `test/comment_test.dart` untuk memastikan model `Comment` tetap aman dan tidak error saat menerima payload JSON kosong `{}`. Test tersebut berhasil lulus 100%.
