import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenUsecase {
  TokenUsecase(this._authRepository);
  final AuthRepository _authRepository;

  Future<Result<void>> refreshToken() async {
    return await _authRepository.refreshToken();
  }
}
