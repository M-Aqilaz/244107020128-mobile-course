import 'task_validator.dart';
import '../repositories/task_repository.dart';

/// Service logika aplikasi tugas yang memisahkan dependensi repository (Step 3 Codelab Minggu 12).
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }

  Future<void> addTask(String title) async {
    if (!isValidTaskTitle(title)) {
      throw ArgumentError('Judul tugas tidak valid');
    }
    await _repository.addTask(title.trim());
  }

  Future<void> removeTask(String title) async {
    await _repository.deleteTask(title);
  }
}
