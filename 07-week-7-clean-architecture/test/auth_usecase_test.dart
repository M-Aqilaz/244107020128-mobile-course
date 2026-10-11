import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/user_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login_usecase.dart';
import 'package:campus_notify/features/auth/domain/usecases/refresh_token_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false});

  final bool fail;
  bool loggedOut = false;

  @override
  Future<({UserSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (fail) {
      return (
        session: null,
        failure: const AuthFailure('Server autentikasi menolak akses (simulasi)'),
      );
    }
    return (
      session: UserSession(
        accessToken: 'mock-access-$email',
        refreshToken: 'mock-refresh-$email',
        email: email,
      ),
      failure: null,
    );
  }

  @override
  Future<({String? renewedToken, Failure? failure})> refresh(String refreshToken) async {
    if (fail || refreshToken.isEmpty) {
      return (
        renewedToken: null,
        failure: const AuthFailure('Refresh token kedaluwarsa (simulasi)'),
      );
    }
    return (renewedToken: 'mock-renewed-token', failure: null);
  }

  @override
  Future<void> logout() async {
    loggedOut = true;
  }

  @override
  Future<String?> getCachedEmail() async => 'aqil@student.polinema.ac.id';

  @override
  Future<bool> isAuthenticated() async => !loggedOut;
}

void main() {
  group('Auth Use Cases Tests (Domain Layer)', () {
    test('LoginUseCase memvalidasi format email sebelum memanggil repository', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase.call(email: 'invalid-email', password: 'password123');

      expect(result.session, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('Email tidak valid'));
    });

    test('LoginUseCase memvalidasi panjang password minimal 6 karakter', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase.call(email: 'aqil@student.polinema.ac.id', password: '123');

      expect(result.session, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('minimal 6 karakter'));
    });

    test('LoginUseCase berhasil mengembalikan UserSession saat kredensial valid', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase.call(
        email: 'aqil@student.polinema.ac.id',
        password: 'password123',
      );

      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session?.email, 'aqil@student.polinema.ac.id');
      expect(result.session?.accessToken, contains('mock-access'));
    });

    test('RefreshTokenUseCase mengembalikan token baru saat refresh berhasil', () async {
      final repo = FakeAuthRepository();
      final useCase = RefreshTokenUseCase(repo);

      final result = await useCase.call('valid-refresh-token');

      expect(result.failure, isNull);
      expect(result.renewedToken, 'mock-renewed-token');
    });

    test('RefreshTokenUseCase mengembalikan failure saat token kosong', () async {
      final repo = FakeAuthRepository();
      final useCase = RefreshTokenUseCase(repo);

      final result = await useCase.call('');

      expect(result.renewedToken, isNull);
      expect(result.failure, isA<AuthFailure>());
    });
  });
}
