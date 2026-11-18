import '../../../../core/failures.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/token_store.dart';
import '../models/user_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.tokenStore});

  final TokenStore tokenStore;

  @override
  Future<({UserSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final trimmed = email.trim();

      final now = DateTime.now().millisecondsSinceEpoch;
      final model = UserSessionModel(
        accessToken: 'jwt-access-$trimmed-$now',
        refreshToken: 'jwt-refresh-$trimmed-$now',
        email: trimmed,
      );

      await tokenStore.save(
        access: model.accessToken,
        refresh: model.refreshToken,
        email: model.email,
      );

      return (session: model.toEntity(), failure: null);
    } catch (e) {
      return (
        session: null,
        failure: AuthFailure('Gagal melakukan proses autentikasi: $e'),
      );
    }
  }

  @override
  Future<({String? renewedToken, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      if (refreshToken.isEmpty) {
        return (
          renewedToken: null,
          failure: const AuthFailure(
            'Refresh token tidak ditemukan atau telah kedaluwarsa',
          ),
        );
      }

      final renewed = 'jwt-renewed-${DateTime.now().millisecondsSinceEpoch}';
      await tokenStore.save(access: renewed, refresh: refreshToken);

      return (renewedToken: renewed, failure: null);
    } catch (e) {
      return (
        renewedToken: null,
        failure: AuthFailure('Gagal memperbarui token autentikasi: $e'),
      );
    }
  }

  @override
  Future<void> logout() async {
    await tokenStore.clear();
  }

  @override
  Future<String?> getCachedEmail() async {
    return tokenStore.readEmail();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await tokenStore.readAccess();
    return token != null && token.isNotEmpty;
  }
}
