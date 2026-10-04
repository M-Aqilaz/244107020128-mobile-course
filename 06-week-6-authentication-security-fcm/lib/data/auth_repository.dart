class AuthSession {
  const AuthSession({
    required this.access,
    required this.refresh,
    this.email = '',
  });

  final String access;
  final String refresh;
  final String email;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trimmed = email.trim();
    if (!trimmed.contains('@') || password.length < 6) {
      throw Exception('Email tidak valid atau kata sandi minimal 6 karakter');
    }

    // Simulasi JWT session token
    final now = DateTime.now().millisecondsSinceEpoch;
    return AuthSession(
      access: 'jwt-access-$trimmed-$now',
      refresh: 'jwt-refresh-$trimmed-$now',
      email: trimmed,
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      throw Exception('Refresh token tidak ditemukan atau telah kedaluwarsa');
    }
    return 'jwt-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
