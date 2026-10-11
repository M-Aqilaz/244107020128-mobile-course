import '../../../../core/failures.dart';
import '../entities/user_session.dart';

abstract class AuthRepository {
  Future<({UserSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  Future<({String? renewedToken, Failure? failure})> refresh(String refreshToken);

  Future<void> logout();

  Future<String?> getCachedEmail();

  Future<bool> isAuthenticated();
}
