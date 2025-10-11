import 'package:grpc_study/common/domain/entities/token_entity.dart';
import 'package:grpc_study/feature/login/domain/entities/login_request_entity.dart';
import 'package:grpc_study/generated/token/dto/refresh_token_response.pb.dart';
import 'package:grpc_study/generated/user/dto/user_login_request.pb.dart';
import 'package:grpc_study/generated/user/dto/user_login_response.pb.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthGrpcMapper {
  AuthGrpcMapper();

  LoginRequest toGrpcLoginRequest(LoginRequestEntity entity) {
    return LoginRequest()
      ..email = entity.email
      ..password = entity.password;
  }

  TokenEntity toTokenEntity({
    required LoginResponse response,
  }) {
    return TokenEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  TokenEntity toTokenEntityFromRefresh({
    required RefreshTokenResponse response,
  }) {
    return TokenEntity(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
