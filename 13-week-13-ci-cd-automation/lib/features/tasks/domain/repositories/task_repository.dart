/// Kontrak abstraksi sumber data tugas (Step 3 Codelab Minggu 12).
abstract interface class TaskRepository {
  Future<List<String>> getTasks();
  Future<void> addTask(String title);
  Future<void> deleteTask(String title);
}
