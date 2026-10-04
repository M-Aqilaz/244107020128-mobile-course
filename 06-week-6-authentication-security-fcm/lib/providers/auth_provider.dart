import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final tokenStoreProvider = Provider((ref) => TokenStore());
final authRepositoryProvider = Provider((ref) => AuthRepository());

final apiClientProvider = Provider((ref) {
  final store = ref.watch(tokenStoreProvider);
  final auth = ref.watch(authRepositoryProvider);
  return buildApiClient(store, auth);
});

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

    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref.read(tokenStoreProvider).save(
            access: session.access,
            refresh: session.refresh,
            email: session.email,
          );
      return true;
    });
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }

  Future<String> simulateRefresh() async {
    final store = ref.read(tokenStoreProvider);
    final auth = ref.read(authRepositoryProvider);
    final refresh = await store.readRefresh() ?? 'mock-refresh-token';
    final renewed = await auth.refresh(refresh);
    await store.save(access: renewed, refresh: refresh);
    ref.invalidateSelf();
    return renewed;
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
  final email = await ref.watch(tokenStoreProvider).readEmail();
  return email ?? 'mahasiswa@polinema.ac.id';
});
