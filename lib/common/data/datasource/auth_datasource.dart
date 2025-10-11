import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_datasource_base.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@singleton
class AuthDatasource extends GrpcDatasourceBase {
  AuthDatasource(
    @Named('default_channel') super.defaultChannel,
    super.interceptors,
  );

  late final MemberLoginServiceClient _memberLoginClient = createClient(
    MemberLoginServiceClient.new,
  );

  @visibleForTesting
  ClientChannel get debugChannel => channel;

  /// 로그인
  Future<Result<MemberLoginResponse>> signIn({
    required MemberLoginRequest request,
  }) async {
    return runUnary(
      () => _memberLoginClient.memberLogin(request, options: CallOptions()),
      onGrpcError: (exception) {
        if (exception.hasCustomErrorCode()) {
          return KondaSignInException(
            exception.message,
            code: exception.code,
            rawResponse: exception.rawResponse,
            trailers: exception.trailers,
            details: exception.details,
          );
        }
        return null;
      },
      debugLabel: 'signIn',
    );
  }
}
