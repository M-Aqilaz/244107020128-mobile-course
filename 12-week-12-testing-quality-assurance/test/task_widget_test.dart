import 'package:campus_notify/features/tasks/domain/repositories/task_repository.dart';
import 'package:campus_notify/features/tasks/presentation/pages/task_page.dart';
import 'package:campus_notify/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_service_test.dart';

void main() {
  Widget createTestWidget({TaskRepository? repository}) {
    return ProviderScope(
      overrides: [
        if (repository != null)
          taskRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: TaskPage()),
    );
  }

  group('TaskPage Widget & User Interaction Tests (Step 4)', () {
    testWidgets('menampilkan judul halaman tugas dan form input', (
      tester,
    ) async {
      final fakeRepo = FakeTaskRepository(tasks: ['Tugas A']);

      await tester.pumpWidget(createTestWidget(repository: fakeRepo));
      await tester.pumpAndSettle();

      // Assert elemen UI utama
      expect(find.text('Daftar tugas'), findsOneWidget);
      expect(find.byKey(const Key('task-title-field')), findsOneWidget);
      expect(find.byKey(const Key('save-task-button')), findsOneWidget);
      expect(find.text('Tugas A'), findsOneWidget);
    });

    testWidgets(
      'menampilkan pesan validasi error saat input kosong atau spasi',
      (tester) async {
        final fakeRepo = FakeTaskRepository(tasks: []);

        await tester.pumpWidget(createTestWidget(repository: fakeRepo));
        await tester.pumpAndSettle();

        // Act: Tekan tombol simpan tanpa mengisi judul
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pump();

        // Assert: Muncul pesan error validasi
        expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);

        // Act: Masukkan hanya spasi
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          '    ',
        );
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pump();

        expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);

        // Act: Masukkan hanya 2 karakter (kurang dari batas minimum 3)
        await tester.enterText(find.byKey(const Key('task-title-field')), 'ab');
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pump();

        expect(find.text('Judul tugas minimal 3 karakter'), findsOneWidget);
      },
    );

    testWidgets(
      'pengguna dapat mengetik teks, menekan simpan, dan melihat tugas di daftar',
      (tester) async {
        final fakeRepo = FakeTaskRepository(tasks: []);

        await tester.pumpWidget(createTestWidget(repository: fakeRepo));
        await tester.pumpAndSettle();

        // Pastikan awalnya empty state
        expect(find.text('Belum ada tugas'), findsOneWidget);

        // Act: Isi input dengan 'Baca materi' sesuai contoh di codelab
        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          'Baca materi',
        );
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        // Assert: Tugas muncul di daftar UI
        expect(find.text('Baca materi'), findsOneWidget);
        expect(find.text('Belum ada tugas'), findsNothing);

        // Input field harus kosong kembali setelah simpan
        final textField = tester.widget<TextField>(
          find.byKey(const Key('task-title-field')),
        );
        expect(textField.controller?.text, isEmpty);
      },
    );

    testWidgets('pengguna dapat menghapus tugas dari daftar', (tester) async {
      final fakeRepo = FakeTaskRepository(
        tasks: ['Tugas Dihapus', 'Tugas Tetap'],
      );

      await tester.pumpWidget(createTestWidget(repository: fakeRepo));
      await tester.pumpAndSettle();

      expect(find.text('Tugas Dihapus'), findsOneWidget);
      expect(find.text('Tugas Tetap'), findsOneWidget);

      // Act: Tekan tombol delete pertama
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Assert: Tugas pertama terhapus
      expect(find.text('Tugas Dihapus'), findsNothing);
      expect(find.text('Tugas Tetap'), findsOneWidget);
    });

    testWidgets(
      'menampilkan empty state yang informatif saat daftar tugas kosong',
      (tester) async {
        final fakeRepo = FakeTaskRepository(tasks: []);

        await tester.pumpWidget(createTestWidget(repository: fakeRepo));
        await tester.pumpAndSettle();

        expect(find.text('Belum ada tugas'), findsOneWidget);
        expect(
          find.text('Tambahkan tugas pertama Anda di atas.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.checklist_rtl_rounded), findsOneWidget);
      },
    );
  });
}
