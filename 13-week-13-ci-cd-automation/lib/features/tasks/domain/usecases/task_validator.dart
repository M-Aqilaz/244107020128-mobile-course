/// Fungsi validasi judul tugas sesuai Codelab Minggu 12 (Step 2).
/// Memeriksa apakah teks judul tugas valid setelah spasi awal/akhir diabaikan.
bool isValidTaskTitle(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return false;
  // Batas panjang judul tugas wajar mahasiswa: minimal 3 karakter, maksimal 100 karakter
  if (trimmed.length < 3 || trimmed.length > 100) return false;
  return true;
}

/// Helper untuk validasi form Flutter (mengembalikan pesan error atau null jika valid)
String? validateTaskTitleInput(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Judul tugas tidak boleh kosong';
  }
  final trimmed = value.trim();
  if (trimmed.length < 3) {
    return 'Judul tugas minimal 3 karakter';
  }
  if (trimmed.length > 100) {
    return 'Judul tugas maksimal 100 karakter';
  }
  return null;
}
