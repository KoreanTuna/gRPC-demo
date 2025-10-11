import 'package:grpc_study/common/domain/usecase/logout_usecase.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:injectable/injectable.dart';

enum SplashNavigationTarget { login, home }

@injectable
class SplashViewModel {
  SplashViewModel(
    this._tokenUsecase,
    this._logoutUsecase,
  );

  final TokenUsecase _tokenUsecase;
  final LogoutUsecase _logoutUsecase;

  Future<SplashNavigationTarget> determineStartDestination() async {
    try {
      final bool hasToken = await _tokenUsecase.hasStoredToken();
      if (!hasToken) {
        return SplashNavigationTarget.login;
      }

      final Result<void> refreshResult = await _tokenUsecase.refreshToken();

      if (refreshResult.isOk) {
        return SplashNavigationTarget.home;
      }

      await _logoutUsecase.logout();
    } catch (error, stackTrace) {
      logger.e('Splash bootstrap 실패: $error', stackTrace: stackTrace);
      await _logoutUsecase.logout();
    }

    return SplashNavigationTarget.login;
  }
}
