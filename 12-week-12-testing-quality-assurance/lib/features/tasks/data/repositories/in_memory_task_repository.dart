import '../../domain/repositories/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository({List<String>? initialTasks})
    : _tasks = initialTasks != null
          ? List<String>.from(initialTasks)
          : [
              'Belajar Pengujian Unit Flutter',
              'Menyiapkan Fake Repository',
              'Menulis Widget Test & Integration Test',
            ];

  final List<String> _tasks;

  @override
  Future<List<String>> getTasks() async {
    // Simulasi delay asinkron realistis
    await Future.delayed(const Duration(milliseconds: 50));
    return List<String>.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(String title) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _tasks.add(title);
  }

  @override
  Future<void> deleteTask(String title) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _tasks.remove(title);
  }
}
