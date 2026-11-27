import 'package:campus_notify/features/tasks/domain/repositories/task_repository.dart';
import 'package:campus_notify/features/tasks/domain/usecases/task_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake Repository sesuai Codelab Minggu 12 (Step 3).
/// Memungkinkan pengujian skenario sukses maupun error tanpa koneksi internet.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({List<String>? tasks, this.error})
    : _tasks = tasks != null ? List<String>.from(tasks) : [];

  final List<String> _tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return List<String>.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(String title) async {
    if (error != null) throw error!;
    _tasks.add(title);
  }

  @override
  Future<void> deleteTask(String title) async {
    if (error != null) throw error!;
    _tasks.remove(title);
  }
}

void main() {
  group(
    'TaskService Async & Dependency Tests with Fake Repository (Step 3)',
    () {
      test(
        'meneruskan data dari repository saat sukses (Arrange-Act-Assert)',
        () async {
          // Arrange
          final fakeRepo = FakeTaskRepository(
            tasks: ['Baca materi', 'Kerjakan kuis'],
          );
          final service = TaskService(fakeRepo);

          // Act
          final result = await service.loadTasks();

          // Assert
          expect(result, equals(['Baca materi', 'Kerjakan kuis']));
        },
      );

      test('meneruskan kegagalan/error saat repository bermasalah', () async {
        // Arrange
        final simulatedException = Exception('Koneksi database lokal terputus');
        final fakeRepo = FakeTaskRepository(error: simulatedException);
        final service = TaskService(fakeRepo);

        // Act & Assert
        expect(
          () async => await service.loadTasks(),
          throwsA(isA<Exception>()),
        );
      });

      test('berhasil menambahkan tugas baru melalui repository', () async {
        // Arrange
        final fakeRepo = FakeTaskRepository(tasks: ['Tugas 1']);
        final service = TaskService(fakeRepo);

        // Act
        await service.addTask('Tugas 2 Praktikum');
        final currentList = await service.loadTasks();

        // Assert
        expect(currentList, contains('Tugas 2 Praktikum'));
        expect(currentList.length, equals(2));
      });

      test(
        'menolak penambahan tugas jika judul tidak valid sebelum ke repository',
        () async {
          // Arrange
          final fakeRepo = FakeTaskRepository();
          final service = TaskService(fakeRepo);

          // Act & Assert
          expect(
            () async => await service.addTask('   '),
            throwsA(isA<ArgumentError>()),
          );
          expect(
            () async => await service.addTask('a'),
            throwsA(isA<ArgumentError>()),
          );

          // Pastikan repository tetap kosong (tidak terpengaruh)
          expect(await service.loadTasks(), isEmpty);
        },
      );

      test('berhasil menghapus tugas yang ada di repository', () async {
        // Arrange
        final fakeRepo = FakeTaskRepository(
          tasks: ['Tugas Lama', 'Tugas Tetap'],
        );
        final service = TaskService(fakeRepo);

        // Act
        await service.removeTask('Tugas Lama');
        final remaining = await service.loadTasks();

        // Assert
        expect(remaining, isNot(contains('Tugas Lama')));
        expect(remaining, equals(['Tugas Tetap']));
      });
    },
  );
}
