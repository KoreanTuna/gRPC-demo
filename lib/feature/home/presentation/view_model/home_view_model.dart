import 'package:grpc_study/common/domain/usecase/logout_usecase.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeViewModel {
  HomeViewModel(this._logoutUsecase);

  final LogoutUsecase _logoutUsecase;

  Future<Result<void>> logout() {
    return _logoutUsecase.logout();
  }
}
