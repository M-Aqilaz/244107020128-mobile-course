import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl();

  // Data sumber pengumuman kampus Polinema (dapat dihubungkan ke remote API / local db)
  static final List<Map<String, dynamic>> _mockData = [
    {
      'id': '1',
      'title': 'Jadwal Ujian Tengah Semester (UTS) Semester Ganjil',
      'category': 'Akademik',
      'date': '01 Oktober 2026, 08:00 WIB',
      'body':
          'Diberitahukan kepada seluruh mahasiswa Jurusan Teknologi Informasi Polinema bahwa jadwal pelaksanaan Ujian Tengah Semester (UTS) dapat diakses melalui portal SIAKAD. Mahasiswa diwajibkan membawa kartu ujian dan mengenakan seragam sesuai ketentuan.',
      'is_read': 0,
    },
    {
      'id': '2',
      'title': 'Pemeliharaan Server Jaringan Kampus JTI',
      'category': 'Infrastruktur',
      'date': '30 September 2026, 17:30 WIB',
      'body':
          'Akan dilakukan perbaikan berkala pada server lokal lab komputasi dan hotspot area Gedung Sipil & TI pada hari Sabtu pukul 22.00–04.00 WIB. Selama durasi tersebut, akses internet lokal kampus akan offline sementara.',
      'is_read': 0,
    },
    {
      'id': '3',
      'title': 'Perubahan Ruang Kuliah Pemrograman Mobile',
      'category': 'Perkuliahan',
      'date': '29 September 2026, 11:15 WIB',
      'body':
          'Kuliah praktikum Pemrograman Mobile Kelas TI-3H hari ini dipindahkan ke Ruang Lab Komputer 2 (LPR 2) Lantai 7 Gedung Jurusan Teknologi Informasi mulai pukul 13.00 WIB. Harap hadir tepat waktu membawa laptop dan project tugas.',
      'is_read': 0,
    },
  ];

  @override
  Future<({List<Announcement> items, Failure? failure})> getAnnouncements() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final items = _mockData
          .map((data) => AnnouncementModel.fromMap(data).toEntity())
          .toList();
      return (items: items, failure: null);
    } catch (e) {
      return (
        items: const <Announcement>[],
        failure: LocalFailure('Gagal memuat daftar pengumuman: $e'),
      );
    }
  }

  @override
  Future<({Announcement? item, Failure? failure})> getAnnouncementDetail(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      final found = _mockData.firstWhere(
        (data) => data['id'].toString() == id,
        orElse: () => _mockData.first,
      );
      final entity = AnnouncementModel.fromMap(found).toEntity();
      return (item: entity, failure: null);
    } catch (e) {
      return (
        item: null,
        failure: LocalFailure('Pengumuman dengan ID $id tidak ditemukan: $e'),
      );
    }
  }
}
