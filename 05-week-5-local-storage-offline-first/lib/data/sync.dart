import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

class CachedPost {
  const CachedPost({
    required this.id,
    required this.title,
    required this.body,
    required this.cachedAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime cachedAt;

  factory CachedPost.fromJson(Map<String, dynamic> json, DateTime cachedAt) {
    return CachedPost(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      cachedAt: cachedAt,
    );
  }
}

class SyncService {
  SyncService({
    Future<Database> Function()? openDb,
    Dio? dio,
  })  : _openDb = openDb ?? openNotesDb,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://jsonplaceholder.typicode.com',
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<int> syncNotes(NoteRepository repo, {bool forceOffline = false}) async {
    final dirtyCount = await repo.countDirty();
    if (dirtyCount == 0) return 0;

    if (forceOffline) {
      throw Exception('Mode offline aktif: tidak dapat menyinkronkan data.');
    }

    // Simulasi pengiriman data tertunda ke server (upload delay)
    await Future.delayed(const Duration(milliseconds: 1000));
    await repo.markAllSynced();
    return dirtyCount;
  }

  Future<List<CachedPost>> loadPostsCacheFirst({bool forceOffline = false}) async {
    final cached = await readCachedPosts();

    // Jika online, lakukan refresh data di background
    if (!forceOffline) {
      refreshPostsInBackground().catchError((_) {});
    }

    return cached;
  }

  Future<List<CachedPost>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((r) {
      final payload = jsonDecode(r['payload'] as String) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(r['cached_at'] as String? ?? '') ??
          DateTime.now();
      return CachedPost.fromJson(payload, cachedAt);
    }).toList();
  }

  Future<void> refreshPostsInBackground() async {
    try {
      final response = await _dio.get<List>('/posts?_limit=10');
      final list = response.data ?? [];
      final db = await _openDb();
      final now = DateTime.now().toIso8601String();

      final batch = db.batch();
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          batch.insert(
            'cached_posts',
            {
              'id': item['id'],
              'payload': jsonEncode(item),
              'cached_at': now,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);
    } catch (_) {
      // Abaikan error background refresh saat offline
    }
  }
}
