import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/login/domain/entities/login_request_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LoginUsecase {
  LoginUsecase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    return _authRepository.login(
      loginRequestEntity: LoginRequestEntity(
        email: email,
        password: password,
      ),
    );
  }
}
