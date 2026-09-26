import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'local/note.dart';
import 'prefs.dart';
import 'repositories/note_repository.dart';
import 'sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final noteRepositoryProvider = Provider((ref) => NoteRepository());
final syncServiceProvider = Provider((ref) => SyncService());

// Prefs: Dark Mode
class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final uriStr = Uri.base.toString();
    if (uriStr.contains('dark=true')) return true;
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final current = state.value ?? false;
    final next = !current;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

// Prefs: Force Offline Simulation
class ForceOfflineNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final uriStr = Uri.base.toString();
    if (uriStr.contains('offline=true') || uriStr.contains('scenario=dirty')) {
      return true;
    }
    return ref.watch(prefsRepositoryProvider).getForceOffline();
  }

  Future<void> toggle() async {
    final current = state.value ?? false;
    final next = !current;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setForceOffline(next);
      return next;
    });
    ref.invalidate(cachedPostsProvider);
  }
}

final forceOfflineProvider =
    AsyncNotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

// Prefs: Last Opened
final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final uriStr = Uri.base.toString();
  if (uriStr.contains('scenario=') || uriStr.contains('mock_opened=true')) {
    return DateTime.now()
        .subtract(const Duration(minutes: 5))
        .toIso8601String();
  }
  return ref.watch(prefsRepositoryProvider).getLastOpened();
});

// Notes List Provider
class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final uriStr = Uri.base.toString();
    if (uriStr.contains('scenario=empty')) {
      return <Note>[];
    }
    if (uriStr.contains('scenario=dirty')) {
      final now = DateTime.now();
      return [
        Note(
          id: 1,
          title: 'Rencana Tugas Mobile Minggu 5',
          body: 'Menerapkan SQLite dan SharedPreferences untuk offline-first',
          updatedAt: now.subtract(const Duration(minutes: 15)),
          dirty: true,
        ),
        Note(
          id: 2,
          title: 'Belanja Komponen Praktikum',
          body: 'Kabel data USB Type-C dan OTG adaptor',
          updatedAt: now.subtract(const Duration(hours: 3)),
          dirty: false,
        ),
      ];
    }
    if (uriStr.contains('scenario=synced')) {
      final now = DateTime.now();
      return [
        Note(
          id: 1,
          title: 'Rencana Tugas Mobile Minggu 5',
          body: 'Menerapkan SQLite dan SharedPreferences untuk offline-first',
          updatedAt: now,
          dirty: false,
        ),
        Note(
          id: 2,
          title: 'Belanja Komponen Praktikum',
          body: 'Kabel data USB Type-C dan OTG adaptor',
          updatedAt: now.subtract(const Duration(hours: 3)),
          dirty: false,
        ),
      ];
    }
    final repo = ref.watch(noteRepositoryProvider);
    return repo.fetchNotes();
  }

  Future<void> addNote({required String title, String body = ''}) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> updateNote(Note note) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.updateNote(note);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNote(id);
    ref.invalidateSelf();
  }

  Future<int> sync() async {
    final repo = ref.read(noteRepositoryProvider);
    final syncService = ref.read(syncServiceProvider);
    final isOffline = ref.read(forceOfflineProvider).value ?? false;
    final synced = await syncService.syncNotes(repo, forceOffline: isOffline);
    ref.invalidateSelf();
    return synced;
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
  retry: (retryCount, error) => null,
);

// Dirty Count Provider
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final uriStr = Uri.base.toString();
  if (uriStr.contains('scenario=empty')) return 0;
  if (uriStr.contains('scenario=dirty')) return 1;
  if (uriStr.contains('scenario=synced')) return 0;
  ref.watch(notesProvider);
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

// Note Detail Provider
final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final uriStr = Uri.base.toString();
  if (uriStr.contains('scenario=detail') ||
      uriStr.contains('scenario=dirty') ||
      uriStr.contains('scenario=synced')) {
    return Note(
      id: 1,
      title: 'Rencana Tugas Mobile Minggu 5',
      body:
          'Menerapkan SQLite dan SharedPreferences untuk offline-first.\n\nLangkah-langkah yang dikerjakan:\n1. Konfigurasi SharedPreferences untuk tema dan waktu buka.\n2. Membuat tabel SQLite notes dan cached_posts.\n3. Mengimplementasikan dirty flag dan antrean sync.\n4. Menjalankan pengujian linter dan automated tests.',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      dirty: true,
    );
  }
  ref.watch(notesProvider);
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNoteById(id);
});

// Cached Posts Provider
final cachedPostsProvider = FutureProvider<List<CachedPost>>((ref) async {
  final uriStr = Uri.base.toString();
  if (uriStr.contains('scenario=cache') || uriStr.contains('offline=true')) {
    final now = DateTime.now().subtract(const Duration(minutes: 10));
    return [
      CachedPost(
        id: 1,
        title:
            'sunt aut facere repellat provident occaecati excepturi optio reprehenderit',
        body:
            'quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam nostrum rerum est autem sunt rem eveniet architecto',
        cachedAt: now,
      ),
      CachedPost(
        id: 2,
        title: 'qui est esse',
        body:
            'est rerum tempore vitae sequi sint nihil reprehenderit dolor beatae ea dolores neque fugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis',
        cachedAt: now,
      ),
      CachedPost(
        id: 3,
        title:
            'ea molestias quasi exercitationem repellat qui ipsa sit aut',
        body:
            'et iusto sed quo iure voluptatem occaecati omnis eligendi aut ad voluptatem doloribus vel accusantium quis pariatur molestiae porro eius odio et labore',
        cachedAt: now,
      ),
      CachedPost(
        id: 4,
        title: 'eum et est occaecati',
        body:
            'ullam et saepe reiciendis voluptatem adipisci sit amet autem assumenda provident rerum culpa quis hic commodi nesciunt rem tenetur doloremque ipsam iure',
        cachedAt: now,
      ),
    ];
  }
  final syncService = ref.watch(syncServiceProvider);
  final isOffline = ref.watch(forceOfflineProvider).value ?? false;
  return syncService.loadPostsCacheFirst(forceOffline: isOffline);
});
