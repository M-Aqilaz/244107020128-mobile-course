import 'package:dio/dio.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient(TokenStore store, AuthRepository auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example-campus-api.test',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Tangani 401: Coba refresh token sekali lalu ulangi request
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(e);

          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);

            // Ulangi request asli dengan token baru
            final retryResponse = await dio.fetch(
              e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retryResponse);
          } catch (_) {
            // Refresh token gagal/mati -> bersihkan sesi dan paksa login ulang
            await store.clear();
          }
        }
        handler.next(e);
      },
    ),
  );

  return dio;
}
