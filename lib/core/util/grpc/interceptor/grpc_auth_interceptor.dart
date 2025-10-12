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
    if (_shouldInject(method, options)) {
      logger.d('${method.path} - Auth Token injected');

      final mergedOptions = _mergeWithAuthProvider(options);
      // Completer를 사용해 호출 결과를 지연 전달한다. 재시도 중에도 동일한 Future를 유지하려면 Completer가 필요하다.
      final context = _UnaryCallContext<R>();

      final proxy = _RetryingUnaryResponseFuture<R>(
        context.resultCompleter.future,
        context.headersCompleter,
        context.trailersCompleter,
        () async => context.currentResponse?.cancel() ?? Future.value(),
      );

      _startUnaryCall(
        method: method,
        request: request,
        options: mergedOptions,
        invoker: invoker,
        context: context,
        proxy: proxy,
      );

      return proxy;
    }

    return invoker(method, request, options);
  }

  // gRPC 메타데이터에 인증 토큰을 채워 넣은 CallOptions를 만든다.
  CallOptions _mergeWithAuthProvider(CallOptions options) {
    return options.mergedWith(
      CallOptions(providers: [_attachAccessToken]),
    );
  }

  Future<void> _attachAccessToken(
    Map<String, String> metadata,
    String _,
  ) async {
    final token = await secureStorageUtil.getAccessToken();
    if (token == null || token.isEmpty) {
      // 저장된 토큰이 없으면 인증되지 않은 상태로 간주하고 호출 자체를 막는다.
      throw const GrpcError.unauthenticated('Access token is missing');
    }
    metadata['Authorization'] = 'Bearer $token';
  }

  void _startUnaryCall<Q, R>({
    required ClientMethod<Q, R> method,
    required Q request,
    required CallOptions options,
    required ClientUnaryInvoker<Q, R> invoker,
    required _UnaryCallContext<R> context,
    required _RetryingUnaryResponseFuture<R> proxy,
  }) {
    Future<void> task() => _invokeUnaryWithRetry(
      method: method,
      request: request,
      options: options,
      invoker: invoker,
      context: context,
      proxy: proxy,
    );

    unawaited(task());
  }

  Future<void> _invokeUnaryWithRetry<Q, R>({
    required ClientMethod<Q, R> method,
    required Q request,
    required CallOptions options,
    required ClientUnaryInvoker<Q, R> invoker,
    required _UnaryCallContext<R> context,
    required _RetryingUnaryResponseFuture<R> proxy,
  }) async {
    bool hasRetried = false;

    while (true) {
      final response = invoker(method, request, options);
      context.currentResponse = response;
      proxy.updateCancel(response.cancel);

      try {
        final value = await response;
        await _completeMetadata(
          response,
          context.headersCompleter,
          context.trailersCompleter,
        );
        if (!context.resultCompleter.isCompleted) {
          context.resultCompleter.complete(value);
        }
        return;
      } on Object catch (error, stackTrace) {
        final shouldRetry = await _shouldRetryAfterRefreshingToken(
          error: error,
          hasRetried: hasRetried,
        );

        await _completeMetadata(
          response,
          context.headersCompleter,
          context.trailersCompleter,
        );

        if (shouldRetry) {
          hasRetried = true;
          continue;
        }

        if (!context.resultCompleter.isCompleted) {
          context.resultCompleter.completeError(error, stackTrace);
        }
        return;
      }
    }
  }

  // Unauthenticated 에러가 발생했을 때 토큰 갱신을 시도하고, 재시도 여부를 알려준다.
  Future<bool> _shouldRetryAfterRefreshingToken({
    required Object error,
    required bool hasRetried,
  }) async {
    final unauthenticated =
        error is GrpcError && error.code == StatusCode.unauthenticated;

    if (!unauthenticated || hasRetried) {
      return false;
    }

    logger.d('Unauthenticated - try to refresh token');
    final refreshResult = await _tokenUsecase().refreshToken();

    final refreshed = refreshResult.map(
      ok: (_) => true,
      error: (_) => false,
    );

    if (refreshed) {
      logger.d('Token refreshed - retry the api');
    }

    return refreshed;
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

class _UnaryCallContext<R> {
  _UnaryCallContext()
    : resultCompleter = Completer<R>(),
      headersCompleter = Completer<Map<String, String>>(),
      trailersCompleter = Completer<Map<String, String>>();

  final Completer<R> resultCompleter;
  final Completer<Map<String, String>> headersCompleter;
  final Completer<Map<String, String>> trailersCompleter;
  Response? currentResponse;
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
