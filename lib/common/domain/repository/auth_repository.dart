import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/common/domain/entities/token_entity.dart';
import 'package:grpc_study/feature/login/domain/entities/login_request_entity.dart';

abstract interface class AuthRepository {
  Future<Result<TokenEntity>> login({
    required LoginRequestEntity loginRequestEntity,
  });

  Future<Result<TokenEntity>> refreshToken({required String refreshToken});
}
