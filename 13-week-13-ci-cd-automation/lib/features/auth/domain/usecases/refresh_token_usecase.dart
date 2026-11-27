import '../../../../core/failures.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  const RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<({String? renewedToken, Failure? failure})> call(String refreshToken) {
    return _repository.refresh(refreshToken);
  }
}
