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
}
