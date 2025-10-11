import 'dart:async';

import 'package:async/async.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/secure_storage_util.dart';
import 'package:grpc_study/environment/api_config.dart';

class AuthInterceptor implements ClientInterceptor {
  AuthInterceptor(
    this.secureStorageUtil,
    this._tokenUsecase,
  );

  final SecureStorageUtil secureStorageUtil;
  final TokenUsecase Function() _tokenUsecase;

  bool _shouldInject(ClientMethod method, CallOptions options) {
    // 1) 메타데이터 플래그 우선
    final flag = options.metadata[ApiConfig.authFlagKey];
    if (flag != null) {
      // "true" (대소문자 무시)일 때만 주입
      return flag.toLowerCase() == 'true';
    }

    return false;
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    addToken(Map<String, String> metadata, String _) async {
      final token = await secureStorageUtil.getAccessToken();
      metadata['Authorization'] = 'Bearer $token';
    }

    if (_shouldInject(method, options)) {
      logger.d('${method.path} - Auth Token injected');

      final mergedOptions = options.mergedWith(
        CallOptions(providers: [addToken]),
      );

      final resultCompleter = Completer<R>();
      final headersCompleter = Completer<Map<String, String>>();
      final trailersCompleter = Completer<Map<String, String>>();

      Response? currentResponse;
      bool hasRetried = false;

      final proxy = _RetryingUnaryResponseFuture<R>(
        resultCompleter.future,
        headersCompleter,
        trailersCompleter,
        () async => currentResponse?.cancel() ?? Future.value(),
      );

      Future<void> performCall() async {
        final response = invoker(method, request, mergedOptions);
        currentResponse = response;
        proxy.updateCancel(() => response.cancel());

        try {
          final value = await response;
          await _completeMetadata(
            response,
            headersCompleter,
            trailersCompleter,
          );
          if (!resultCompleter.isCompleted) {
            resultCompleter.complete(value);
          }
        } on Object catch (error, stackTrace) {
          final shouldRetry =
              !hasRetried &&
              error is GrpcError &&
              error.code == StatusCode.unauthenticated;

          if (shouldRetry) {
            hasRetried = true;
            logger.d('Unauthenticated - try to refresh token');
            final refreshResult = await _tokenUsecase().refreshToken();

            final refreshed = refreshResult.map(
              ok: (_) => true,
              error: (_) => false,
            );

            if (refreshed) {
              logger.d('Token refreshed - retry the api');
              await performCall();
              return;
            }
          }

          await _completeMetadata(
            response,
            headersCompleter,
            trailersCompleter,
          );

          if (!resultCompleter.isCompleted) {
            if (shouldRetry) {
              // Refresh failed; propagate original unauthenticated error.
              resultCompleter.completeError(error, stackTrace);
            } else {
              resultCompleter.completeError(error, stackTrace);
            }
          }
        }
      }

      unawaited(performCall());

      return proxy;
    }

    return invoker(method, request, options);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    addToken(Map<String, String> metadata, String _) async {
      final token = await secureStorageUtil.getAccessToken();
      metadata['Authorization'] = 'Bearer $token';
    }

    if (_shouldInject(method, options)) {
      logger.d('${method.path} - Auth Token injected (streaming)');

      final mergedOptions = options.mergedWith(
        CallOptions(providers: [addToken]),
      );

      final response = invoker(method, requests, mergedOptions);

      response.trailers.catchError((error, _) async {
        if (error is GrpcError && error.code == StatusCode.unauthenticated) {
          logger.d('Unauthenticated (streaming) - try to refresh token');
          final result = await _tokenUsecase().refreshToken();
          result.when(
            ok: (_) {
              logger.d('Token refreshed (streaming)');
            },
            error: (e) {
              logger.e('Token refresh failed (streaming): $e');
            },
          );
        }

        throw error;
      }).ignore();

      return response;
    }

    return invoker(method, requests, options);
  }
}

Future<void> _completeMetadata(
  Response response,
  Completer<Map<String, String>> headersCompleter,
  Completer<Map<String, String>> trailersCompleter,
) async {
  if (!headersCompleter.isCompleted) {
    try {
      headersCompleter.complete(await response.headers);
    } catch (error, stackTrace) {
      headersCompleter.completeError(error, stackTrace);
    }
  }

  if (!trailersCompleter.isCompleted) {
    try {
      trailersCompleter.complete(await response.trailers);
    } catch (error, stackTrace) {
      trailersCompleter.completeError(error, stackTrace);
    }
  }
}

class _RetryingUnaryResponseFuture<R> extends DelegatingFuture<R>
    implements ResponseFuture<R> {
  _RetryingUnaryResponseFuture(
    super.future,
    this._headersCompleter,
    this._trailersCompleter,
    Future<void> Function()? cancelCallback,
  ) : _cancelCallback = cancelCallback;

  final Completer<Map<String, String>> _headersCompleter;
  final Completer<Map<String, String>> _trailersCompleter;
  Future<void> Function()? _cancelCallback;

  void updateCancel(Future<void> Function()? cancelCallback) {
    _cancelCallback = cancelCallback;
  }

  @override
  Future<Map<String, String>> get headers => _headersCompleter.future;

  @override
  Future<Map<String, String>> get trailers => _trailersCompleter.future;

  @override
  Future<void> cancel() {
    final cancel = _cancelCallback;
    return cancel != null ? cancel() : Future.value();
  }
}
