import 'package:campus_notify/features/tasks/domain/usecases/task_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isValidTaskTitle - Unit Tests & Edge Cases (Step 2)', () {
    test('menerima judul yang berisi teks valid', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle('Belajar Flutter'), isTrue);
      expect(isValidTaskTitle('Baca materi'), isTrue);
      expect(isValidTaskTitle('Praktikum Mobile TI-3H'), isTrue);
    });

    test('menolak teks kosong atau hanya spasi (kasus tepi)', () {
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle(' '), isFalse);
      expect(isValidTaskTitle('    '), isFalse);
      expect(isValidTaskTitle('\t\n'), isFalse);
    });

    test('menolak judul yang terlalu pendek (kurang dari 3 karakter)', () {
      expect(isValidTaskTitle('a'), isFalse);
      expect(isValidTaskTitle('ab'), isFalse);
      expect(isValidTaskTitle('  ok  '), isFalse); // trim() panjangnya 2
    });

    test(
      'menerima judul dengan spasi di awal/akhir jika panjang isi valid',
      () {
        expect(isValidTaskTitle('   Tugas Jaringan   '), isTrue);
      },
    );

    test('menolak judul yang melebihi batas 100 karakter (kasus batas)', () {
      final longTitle = 'A' * 101;
      expect(isValidTaskTitle(longTitle), isFalse);

      final exactLimit = 'A' * 100;
      expect(isValidTaskTitle(exactLimit), isTrue);
    });
  });

  group('validateTaskTitleInput - Form Validation Helper Tests', () {
    test('mengembalikan null jika input valid', () {
      expect(validateTaskTitleInput('Mengerjakan Laporan'), isNull);
    });

    test('mengembalikan pesan error jika input kosong atau null', () {
      expect(
        validateTaskTitleInput(null),
        equals('Judul tugas tidak boleh kosong'),
      );
      expect(
        validateTaskTitleInput(''),
        equals('Judul tugas tidak boleh kosong'),
      );
      expect(
        validateTaskTitleInput('   '),
        equals('Judul tugas tidak boleh kosong'),
      );
    });

    test('mengembalikan pesan error jika karakter kurang dari 3', () {
      expect(
        validateTaskTitleInput('ab'),
        equals('Judul tugas minimal 3 karakter'),
      );
    });

    test('mengembalikan pesan error jika karakter lebih dari 100', () {
      final longInput = 'B' * 101;
      expect(
        validateTaskTitleInput(longInput),
        equals('Judul tugas maksimal 100 karakter'),
      );
    });
  });
}
