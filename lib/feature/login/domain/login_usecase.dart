import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/login/domain/entities/login_request_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LoginUsecase {
  LoginUsecase(
    this._authRepository,
    this._tokenUsecase,
  );

  final AuthRepository _authRepository;
  final TokenUsecase _tokenUsecase;

  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    final loginResult = await _authRepository.login(
      loginRequestEntity: LoginRequestEntity(
        email: email,
        password: password,
      ),
    );

    return loginResult.map(
      ok: (token) async {
        await _tokenUsecase.saveToken(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );

        return const Result.ok(null);
      },
      error: (error) {
        return Result.error(error);
      },
    );
  }
}
