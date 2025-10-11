import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/exception/custom_exception.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:meta/meta.dart';

typedef GrpcClientBuilder<T> =
    T Function(
      ClientChannel channel, {
      Iterable<ClientInterceptor>? interceptors,
    });

/// gRPC 데이터소스에서 공통적으로 사용하는 채널/인터셉터/에러 처리 유틸리티를 제공한다.
@immutable
abstract class GrpcDatasourceBase {
  GrpcDatasourceBase(this.channel, List<ClientInterceptor> interceptors)
    : interceptors = List.unmodifiable(interceptors);

  /// 기본 gRPC 채널 (HTTP/2 커넥션 재사용)
  final ClientChannel channel;

  /// 공용 gRPC 인터셉터 묶음
  final List<ClientInterceptor> interceptors;

  /// gRPC 서비스 클라이언트를 생성한다.
  @protected
  T createClient<T>(GrpcClientBuilder<T> builder) {
    return builder(channel, interceptors: interceptors);
  }

  /// gRPC unary 호출을 공통 예외 처리와 함께 실행한다.
  @protected
  Future<Result<R>> runUnary<R>(
    Future<R> Function() invoke, {
    CustomException? Function(CustomGrpcException exception)? onGrpcError,
    String? debugLabel,
  }) async {
    try {
      final response = await invoke();
      return Result.ok(response);
    } on GrpcError catch (error, _) {
      final base = CustomGrpcException(
        error.message ?? 'Unknown gRPC error',
        code: error.code,
        rawResponse: error.rawResponse,
        trailers: error.trailers,
        details: error.details,
      );
      final mapped = onGrpcError?.call(base) ?? base;
      if (debugLabel != null) {
        logger.e('[$runtimeType][$debugLabel] gRPC error: ${mapped.message}');
      }
      return Result.error(mapped);
    } catch (error, _) {
      if (debugLabel != null) {
        logger.e('[$runtimeType][$debugLabel] unexpected error: $error');
      }
      return Result.error(CustomNetworkException(error.toString()));
    }
  }
}
