import '../entities/announcement.dart';

/// Pure domain use case untuk memfilter daftar pengumuman berdasarkan kata kunci pencarian.
///
/// Aturan bisnis (Business Rules):
/// 1. Query dipotong spasi awal/akhir (trim).
/// 2. Jika query kosong setelah di-trim, kembalikan semua daftar pengumuman tanpa difilter.
/// 3. Pencarian bersifat case-insensitive (mengabaikan huruf besar/kecil).
/// 4. Mencocokkan kata kunci pada judul (`title`), isi (`body`), maupun kategori (`category`).
/// 5. Bersih 100% dari framework Flutter/Dio/SQLite (Dependency Rule).
class SearchAnnouncements {
  const SearchAnnouncements();

  List<Announcement> call({
    required List<Announcement> announcements,
    required String query,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return announcements;
    }

    return announcements.where((item) {
      final titleMatch = item.title.toLowerCase().contains(cleanQuery);
      final bodyMatch = item.body.toLowerCase().contains(cleanQuery);
      final categoryMatch = item.category.toLowerCase().contains(cleanQuery);
      return titleMatch || bodyMatch || categoryMatch;
    }).toList();
  }
}
