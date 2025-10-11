import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_message_formatter.dart';
import 'package:grpc_study/core/util/grpc/interceptor/grpc_encode_buffer.dart';
import 'package:grpc_study/core/util/logger.dart';

import 'package:protobuf/protobuf.dart';

class LoggingInterceptor implements ClientInterceptor {
  LoggingInterceptor();

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final merged = options.mergedWith(
      CallOptions(metadata: {'x-language-code': 'KO'}),
    );

    final reqLog = (request is GeneratedMessage)
        ? protoJsonWithDefaults(request)
        : request.toString();

    logger.d('[gRPC REQ] ${method.path} req=$reqLog meta=${merged.metadata}');

    final res = invoker(method, request, merged);

    res
        .then((value) {
          final resLog = (value is GeneratedMessage)
              ? protoJsonWithDefaults(value)
              : value.toString();

          logger.d('[gRPC RES] ${method.path} res=$resLog');
        })
        .catchError((e) async {
          final errorLog = _formatError(e);
          final header = await res.headers;
          logger.e(
            '[gRPC ERROR] : ${method.path} err=$errorLog  HEADER : $header',
          );
        });

    return res;
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final merged = options.mergedWith(
      CallOptions(metadata: {'x-language-code': 'KO'}),
    );

    final response = invoker(method, requests, merged);

    unawaited(
      response.trailers.catchError((error) async {
        final errorLog = _formatError(error);
        if (error is GrpcError) {
          if (error.code == StatusCode.unavailable) {
            logger.e(
              '[gRPC ERROR] : ${method.path} err=$errorLog - 서버 연결이 불안정합니다. 잠시 후 다시 시도해주세요.',
            );
            return <String, String>{};
          }
        }
        try {
          final headers = await response.headers;
          logger.e(
            '[gRPC ERROR] : ${method.path} err=$errorLog HEADER : $headers',
          );
        } catch (_) {
          logger.e('[gRPC ERROR] : ${method.path} err=$errorLog');
        }
        return <String, String>{};
      }),
    );

    return response;
  }
}

String _formatError(Object error) {
  if (error is GrpcError) {
    final message = sanitizeGrpcErrorMessage(
      error.message ?? 'Unknown gRPC error',
      trailers: error.trailers,
    );
    return 'GrpcError(${error.code}): $message';
  }
  return error.toString();
}
