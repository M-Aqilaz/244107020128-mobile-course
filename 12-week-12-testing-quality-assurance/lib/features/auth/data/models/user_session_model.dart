import '../../domain/entities/user_session.dart';

class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.accessToken,
    required super.refreshToken,
    required super.email,
  });

  factory UserSessionModel.fromMap(Map<String, dynamic> map) {
    return UserSessionModel(
      accessToken: map['access_token'] as String? ?? '',
      refreshToken: map['refresh_token'] as String? ?? '',
      email: map['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'email': email,
  };

  UserSession toEntity() => UserSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    email: email,
  );
}
