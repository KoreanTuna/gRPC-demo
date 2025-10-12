import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_datasource_base.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/core/util/grpc/grpc_option.dart';
import 'package:grpc_study/environment/api_config.dart';
import 'package:grpc_study/generated/google/protobuf/empty.pb.dart';
import 'package:grpc_study/generated/token/dto/refresh_token_request.pb.dart';
import 'package:grpc_study/generated/token/dto/refresh_token_response.pb.dart';
import 'package:grpc_study/generated/token/service/token_service.pbgrpc.dart';
import 'package:grpc_study/generated/user/dto/user_login_request.pb.dart';
import 'package:grpc_study/generated/user/dto/user_login_response.pb.dart';
import 'package:grpc_study/generated/user/service/user_login_service.pbgrpc.dart';
import 'package:grpc_study/generated/user/service/user_logout_service.pbgrpc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@singleton
class AuthDatasource extends GrpcDatasourceBase {
  AuthDatasource(
    @Named('default_channel') super.defaultChannel,
    super.interceptors,
  );

  late final UserLoginServiceClient _userLoginClient = createClient(
    UserLoginServiceClient.new,
  );

  late final TokenServiceClient _tokenClient = createClient(
    TokenServiceClient.new,
  );

  late final UserLogoutServiceClient userLogoutClient = createClient(
    UserLogoutServiceClient.new,
  );

  @visibleForTesting
  ClientChannel get debugChannel => channel;

  /// 로그인
  Future<Result<LoginResponse>> signIn({
    required LoginRequest request,
  }) async {
    return runUnary(
      () => _userLoginClient.login(
        request,
        options: GrpcOptions.defaultCallOptions(
          meta: {ApiConfig.authFlagKey: 'true'},
        ),
      ),
      debugLabel: 'signIn',
    );
  }

  /// 토큰 리프레시
  Future<Result<RefreshTokenResponse>> refreshToken({
    required String refreshToken,
  }) async {
    final request = RefreshTokenRequest()..refreshToken = refreshToken;
    return runUnary(
      () => _tokenClient.refreshToken(
        request,
        options: GrpcOptions.defaultCallOptions(),
      ),
      debugLabel: 'refreshToken',
    );
  }

  /// 로그아웃
  Future<Result<void>> logout() async {
    return runUnary(
      () => userLogoutClient.logout(
        Empty(),
        options: GrpcOptions.defaultCallOptions(
          meta: {ApiConfig.authFlagKey: 'true'},
        ),
      ),
      debugLabel: 'logout',
    );
  }
}
