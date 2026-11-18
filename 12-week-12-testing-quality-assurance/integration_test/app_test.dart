import 'package:campus_notify/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('pengguna dapat menavigasi ke halaman tugas dan menambahkan tugas baru',
      (tester) async {
    // 1. Jalankan aplikasi utama
    app.main();
    await tester.pumpAndSettle();

    // 2. Dari Home Page, scroll atau cari tombol "Daftar Tugas Kuliah"
    final openTaskButton = find.byKey(const Key('btn_open_task_manager'));
    if (openTaskButton.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        openTaskButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
    }
    expect(openTaskButton, findsOneWidget);
    await tester.tap(openTaskButton);
    await tester.pumpAndSettle();

    // 3. Pastikan sudah berada di halaman Daftar tugas
    expect(find.text('Daftar tugas'), findsOneWidget);
    expect(find.byKey(const Key('task-title-field')), findsOneWidget);

    // 4. Masukkan judul tugas baru: 'Baca materi' (sesuai Codelab Step 5)
    await tester.enterText(
      find.byKey(const Key('task-title-field')),
      'Baca materi',
    );
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pumpAndSettle();

    // 5. Periksa bahwa tugas berhasil tampil di daftar UI
    expect(find.text('Baca materi'), findsOneWidget);
  });
}
