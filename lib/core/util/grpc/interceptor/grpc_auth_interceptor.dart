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

  // 인터셉터에서 Future를 즉시 반환해야 하므로, 실제 네트워크 호출은 백그라운드에서 시작한다.
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
    // Unauthenticated 에러 발생 후 토큰 갱신에 성공했을 때 한 번만 재시도한다.
    bool hasRetried = false;

    while (true) {
      // 실제 gRPC 호출을 실행하고, 취소 신호를 전달할 수 있도록 context에 저장한다.
      final response = invoker(method, request, options);
      context.currentResponse = response;
      proxy.updateCancel(response.cancel);

      try {
        // 정상 응답이면 헤더/트레일러도 함께 완성하고 결과를 전달한다.
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
        // 인증 실패라면 토큰을 갱신하고 재시도할지 결정한다.
        final shouldRetry = await _shouldRetryAfterRefreshingToken(
          error: error,
          hasRetried: hasRetried,
        );

        // 오류가 발생해도 헤더/트레일러를 받을 수 있도록 시도한다.
        await _completeMetadata(
          response,
          context.headersCompleter,
          context.trailersCompleter,
        );

        if (shouldRetry) {
          // 토큰 갱신이 성공한 경우 한 번만 루프를 반복한다.
          hasRetried = true;
          continue;
        }

        if (!context.resultCompleter.isCompleted) {
          // 재시도 불가라면 원래 오류를 그대로 전달한다.
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
  // 특정 gRPC 호출과 관련된 상태를 묶어둔 컨테이너 역할을 한다.
  _UnaryCallContext()
    : resultCompleter = Completer<R>(),
      headersCompleter = Completer<Map<String, String>>(),
      trailersCompleter = Completer<Map<String, String>>();

  // 재시도 중에도 같은 Future 인스턴스로 응답을 전달하기 위해 Completer를 유지한다.
  final Completer<R> resultCompleter;
  // gRPC 응답 헤더를 외부에 지연 전달하기 위한 Completer.
  final Completer<Map<String, String>> headersCompleter;
  // gRPC 트레일러를 외부에 지연 전달하기 위한 Completer.
  final Completer<Map<String, String>> trailersCompleter;
  // 현재 진행 중인 실제 gRPC Response를 저장해 cancel 동작을 위임한다.
  Response? currentResponse;
}

class _RetryingUnaryResponseFuture<R> extends DelegatingFuture<R>
    implements ResponseFuture<R> {
  // 실제 ResponseFuture 대신 노출할 프록시(대리인) 객체.
  // 내부에서 새로운 Response를 받아도 외부에는 동일한 Future 인터페이스를 제공한다.
  _RetryingUnaryResponseFuture(
    super.future,
    this._headersCompleter,
    this._trailersCompleter,
    Future<void> Function()? cancelCallback,
  ) : _cancelCallback = cancelCallback;

  final Completer<Map<String, String>> _headersCompleter;
  final Completer<Map<String, String>> _trailersCompleter;
  Future<void> Function()? _cancelCallback;

  // 실제 gRPC Response의 cancel 함수를 최신값으로 교체한다.
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
    // cancel이 없다면 아무 일도 하지 않는 Future를 반환해 호출 측에서 예외가 나지 않게 한다.
    return cancel != null ? cancel() : Future.value();
  }
}
