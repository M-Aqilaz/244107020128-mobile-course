import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/pages/notes_page.dart';
import 'package:week5_offline_notes/widgets/note_tile.dart';

class MockNoteRepository extends NoteRepository {
  MockNoteRepository(this.notes)
      : super(openDb: () => throw UnimplementedError());
  final List<Note> notes;

  @override
  Future<List<Note>> fetchNotes() async => notes;

  @override
  Future<int> countDirty() async => notes.where((n) => n.dirty).length;
}

void main() {
  testWidgets('NotesPage menampilkan daftar catatan dan badge dirty',
      (tester) async {
    final mockNotes = [
      Note(
        id: 1,
        title: 'Catatan Pertama',
        body: 'Isi catatan satu',
        updatedAt: DateTime(2026, 9, 20, 10, 0),
        dirty: true,
      ),
      Note(
        id: 2,
        title: 'Catatan Kedua',
        body: 'Isi catatan dua',
        updatedAt: DateTime(2026, 9, 20, 11, 0),
        dirty: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(MockNoteRepository(mockNotes)),
        ],
        child: const MaterialApp(
          home: NotesPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Catatan Pertama'), findsOneWidget);
    expect(find.text('Catatan Kedua'), findsOneWidget);
    expect(find.text('Belum sinkron'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);
    expect(find.byType(NoteTile), findsNWidgets(2));
  });

  testWidgets('NotesPage menampilkan pesan kosong jika tidak ada catatan',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(MockNoteRepository([])),
        ],
        child: const MaterialApp(
          home: NotesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan lokal.'), findsOneWidget);
    expect(find.text('Tambah Catatan'), findsOneWidget);
  });
}
