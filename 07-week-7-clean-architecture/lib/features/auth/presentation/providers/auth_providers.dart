import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';

// Data layer: TokenStore & Repository DI
final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(tokenStore: ref.watch(tokenStoreProvider));
});

// Domain layer: Use cases receiving abstractions
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRepositoryProvider));
});

// Presentation layer: State management
class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Dukung URL scenario untuk pengujian visual UI
    final uriStr = Uri.base.toString();
    if (uriStr.contains('auth=false')) {
      return false;
    }
    if (uriStr.contains('auth=true') ||
        uriStr.contains('scenario=home') ||
        uriStr.contains('scenario=notification') ||
        uriStr.contains('scenario=refresh')) {
      return true;
    }

    final repo = ref.watch(authRepositoryProvider);
    return repo.isAuthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase.call(email: email, password: password);

    if (result.failure != null) {
      state = AsyncError(Exception(result.failure!.message), StackTrace.current);
      throw Exception(result.failure!.message);
    }

    state = const AsyncData(true);
  }

  Future<void> logout() async {
    final useCase = ref.read(logoutUseCaseProvider);
    await useCase.call();
    state = const AsyncData(false);
  }

  Future<String> simulateRefresh() async {
    final store = ref.read(tokenStoreProvider);
    final refresh = await store.readRefresh() ?? 'mock-refresh-token';
    final useCase = ref.read(refreshTokenUseCaseProvider);
    final result = await useCase.call(refresh);

    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }

    ref.invalidateSelf();
    return result.renewedToken ?? 'jwt-renewed-token';
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

final userEmailProvider = FutureProvider<String>((ref) async {
  ref.watch(authStateProvider);
  final uriStr = Uri.base.toString();
  if (uriStr.contains('scenario=')) {
    return 'aqil@student.polinema.ac.id';
  }
  final repo = ref.watch(authRepositoryProvider);
  final email = await repo.getCachedEmail();
  return email ?? 'aqil@student.polinema.ac.id';
});
