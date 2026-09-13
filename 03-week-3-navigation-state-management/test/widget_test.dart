import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3/main.dart';
import 'package:week3/providers/todo_provider.dart';

void main() {
  test('Unit Test: TodoListNotifier add, toggle, and remove operations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state harus kosong
    expect(container.read(todoListProvider), isEmpty);

    // 1. Add todo
    container.read(todoListProvider.notifier).add('Belajar Riverpod');
    final todosAfterAdd = container.read(todoListProvider);
    expect(todosAfterAdd.length, 1);
    expect(todosAfterAdd.first.title, 'Belajar Riverpod');
    expect(todosAfterAdd.first.done, false);

    final todoId = todosAfterAdd.first.id;

    // 2. Toggle todo
    container.read(todoListProvider.notifier).toggle(todoId);
    final todosAfterToggle = container.read(todoListProvider);
    expect(todosAfterToggle.first.done, true);

    // 3. Remove todo
    container.read(todoListProvider.notifier).remove(todoId);
    expect(container.read(todoListProvider), isEmpty);
  });

  test('Unit Test: Derived filteredTodoListProvider filter logic', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(todoListProvider.notifier).add('Tugas Aktif');
    container.read(todoListProvider.notifier).add('Tugas Selesai');
    final todos = container.read(todoListProvider);
    container.read(todoListProvider.notifier).toggle(todos[1].id);

    // Filter ALL
    expect(container.read(filteredTodoListProvider).length, 2);

    // Filter ACTIVE
    container.read(todoFilterProvider.notifier).setFilter(TodoFilter.active);
    final activeTodos = container.read(filteredTodoListProvider);
    expect(activeTodos.length, 1);
    expect(activeTodos.first.title, 'Tugas Aktif');

    // Filter COMPLETED
    container.read(todoFilterProvider.notifier).setFilter(TodoFilter.completed);
    final completedTodos = container.read(filteredTodoListProvider);
    expect(completedTodos.length, 1);
    expect(completedTodos.first.title, 'Tugas Selesai');
  });

  testWidgets('Widget Test: Menambah tugas baru melalui UI Dialog', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Verifikasi tampilan awal kondisi kosong
    expect(find.text('Belum ada tugas'), findsOneWidget);

    // Tap tombol FAB tugas baru
    await tester.tap(find.text('Tugas Baru'));
    await tester.pumpAndSettle();

    // Input teks di TextField dialog
    await tester.enterText(find.byType(TextField), 'Kerjakan PR Minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    // Verifikasi tugas baru berhasil muncul di list
    expect(find.text('Kerjakan PR Minggu 3'), findsOneWidget);
  });

  testWidgets('Widget Test: Navigasi GoRouter ke halaman detail item', (tester) async {
    final container = ProviderContainer();
    // Pre-populate todo
    container.read(todoListProvider.notifier).add('Tugas Navigasi');
    final todo = container.read(todoListProvider).first;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tugas Navigasi'), findsOneWidget);

    // Tap icon arrow detail
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    // Verifikasi halaman detail terbuka dengan ID yang sesuai
    expect(find.text('Detail Tugas #${todo.id}'), findsOneWidget);
    expect(find.text('Kembali ke Daftar'), findsOneWidget);

    // Kembali ke beranda
    await tester.tap(find.text('Kembali ke Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Tugas ToDo'), findsOneWidget);
  });
}
