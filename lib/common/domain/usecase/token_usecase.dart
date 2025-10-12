import 'dart:async';

import 'package:grpc_study/common/domain/entities/token_entity.dart';
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

  // 현재 진행 중인 refresh 작업이 있다면 여기에 담아 모든 호출이 같은 Future를 await 하게 함
  Completer<Result<void>>? _refreshCompleter;

  /// 동시 호출 폭주를 막는 refreshToken
  /// - 진행 중이면: 같은 Future를 반환 (새 네트워크 호출 없음)
  /// - 진행 중이 아니면: 실제로 한 번만 호출
  Future<Result<void>> refreshToken({bool force = false}) {
    // 이미 진행 중이면 그 Future를 그대로 반환
    if (!force && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<Result<void>>();
    _refreshCompleter = completer;

    () async {
      try {
        final String? refreshToken = await _secureStorageUtil.getRefreshToken();
        if (refreshToken == null) {
          completer.complete(
            Result.error(CustomNotFoundException('리프래시 토큰 없음')),
          );
          return;
        }

        final Result<TokenEntity> result = await _authRepository.refreshToken(
          refreshToken: refreshToken,
        );

        if (result is Ok<TokenEntity>) {
          final TokenEntity token = result.value;
          await saveToken(
            accessToken: token.accessToken,
            refreshToken: token.refreshToken,
          );
          completer.complete(const Result.ok(null));
        } else {
          final Error<TokenEntity> error = result as Error<TokenEntity>;
          completer.complete(Result.error(error.error));
        }
      } catch (e) {
        // 예외도 Result.error로 통일
        completer.complete(Result.error(CustomNetworkException('토큰 갱신 실패')));
      } finally {
        // 다음 호출에서 새로 시도할 수 있도록 해제
        _refreshCompleter = null;
      }
    }();

    return completer.future;
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

  Future<bool> hasStoredToken() async {
    final String? accessToken = await _secureStorageUtil.getAccessToken();
    final String? refreshToken = await _secureStorageUtil.getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}
