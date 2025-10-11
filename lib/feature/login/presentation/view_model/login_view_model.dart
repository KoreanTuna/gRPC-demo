import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/login/domain/login_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginViewModel {
  LoginViewModel(this._loginUsecase);

  final LoginUsecase _loginUsecase;

  Future<Result<void>> login(String username, String password) {
    return _loginUsecase.login(email: username, password: password);
  }
}
