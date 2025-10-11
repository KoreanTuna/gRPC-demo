import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/core/exception/custom_exception.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/core/util/secure_storage_util.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TokenUsecase {
  TokenUsecase(
    this._authRepository,
    this._secureStorageUtil,
  );
  final AuthRepository _authRepository;
  final SecureStorageUtil _secureStorageUtil;

  Future<Result<void>> refreshToken() async {
    final String? refreshToken = await _secureStorageUtil.getAccessToken();

    if (refreshToken == null) {
      return Result.error(CustomNotFoundException('리프래시 토큰 없음'));
    }
    return _authRepository.refreshToken(refreshToken: refreshToken);
  }

  Future<void> _saveAccessToken(String accessToken) async {
    await _secureStorageUtil.saveAccessToken(accessToken);
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    await _secureStorageUtil.saveRefreshToken(refreshToken);
  }

  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _saveAccessToken(accessToken),
      _saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> deleteToken() async {
    await Future.wait([
      _secureStorageUtil.deleteAccessToken(),
      _secureStorageUtil.deleteRefreshToken(),
    ]);
  }
}
