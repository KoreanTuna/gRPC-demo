import 'package:grpc_study/common/data/datasource/auth_datasource.dart';
import 'package:grpc_study/common/data/grpc_mapper/auth_grpc_mapper.dart';
import 'package:grpc_study/common/domain/entities/token_entity.dart';
import 'package:grpc_study/common/domain/repository/auth_repository.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/login/domain/entities/login_request_entity.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authDatasource,
    this._authGrpcMapper,
  );
  final AuthDatasource _authDatasource;
  final AuthGrpcMapper _authGrpcMapper;

  @override
  Future<Result<TokenEntity>> login({
    required LoginRequestEntity loginRequestEntity,
  }) async {
    final loginRequest = _authGrpcMapper.toGrpcLoginRequest(
      loginRequestEntity,
    );

    final result = await _authDatasource.signIn(request: loginRequest);

    return result.map(
      ok: (response) {
        return Result.ok(_authGrpcMapper.toTokenEntity(response: response));
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<TokenEntity>> refreshToken({
    required String refreshToken,
  }) async {
    final result = await _authDatasource.refreshToken(
      refreshToken: refreshToken,
    );

    return result.map(
      ok: (response) {
        return Result.ok(
          _authGrpcMapper.toTokenEntityFromRefresh(response: response),
        );
      },
      error: Result.error,
    );
  }
}
