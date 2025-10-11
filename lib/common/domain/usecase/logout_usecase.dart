import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LogoutUsecase {
  LogoutUsecase(
    this._authRepository,
    this._tokenUsecase,
  );

  final TokenUsecase _tokenUsecase;

  final AuthRepository _authRepository;

  Future<Result<void>> logout() async {
    await _authRepository.logout();
    await _tokenUsecase.deleteToken();

    return const Result.ok(null);
  }
}
