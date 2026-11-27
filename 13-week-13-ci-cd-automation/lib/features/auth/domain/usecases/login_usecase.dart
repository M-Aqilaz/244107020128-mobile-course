import '../../../../core/failures.dart';
import '../entities/user_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<({UserSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    if (!trimmed.contains('@') || password.length < 6) {
      return (
        session: null,
        failure: const ValidationFailure(
          'Email tidak valid atau kata sandi minimal 6 karakter',
        ),
      );
    }
    return _repository.login(email: trimmed, password: password);
  }
}
