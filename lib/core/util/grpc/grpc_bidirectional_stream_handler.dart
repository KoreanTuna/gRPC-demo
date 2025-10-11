import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/exception/custom_exception.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';

/// gRPC 양방향 스트림에서 응답 메시지를 도메인 결과로 변환할 때 사용하는 함수 시그니처
typedef GrpcResponseMapper<Res, Output> = Result<Output> Function(Res response);

/// gRPC 양방향 통신 시 공통으로 필요한 연결/에러 처리 로직을 담당하는 헬퍼
class GrpcBidirectionalStreamHandler {
  const GrpcBidirectionalStreamHandler._();

  /// 클라이언트 스트림을 열고 공통 에러 처리와 리소스 관리를 적용한 핸들 객체를 생성합니다.
  static Future<Result<GrpcBidirectionalStreamHandle<Req, Res, Output>>>
  connect<Req, Res, Output>({
    required String logTag,
    required FutureOr<ResponseStream<Res>> Function(Stream<Req> requestStream)
    clientInvoker,
    required GrpcResponseMapper<Res, Output> responseMapper,
    CustomException Function(GrpcError error)? grpcErrorBuilder,
    CustomException Function(Object error)? unexpectedErrorBuilder,
  }) async {
    final requestController = StreamController<Req>();
    final responseController = StreamController<Result<Output>>();

    late final ResponseStream<Res> responseStream;

    try {
      responseStream = await clientInvoker(requestController.stream);
    } on GrpcError catch (error) {
      await requestController.close();
      await responseController.close();
      return Result.error(
        grpcErrorBuilder?.call(error) ?? _defaultGrpcException(error),
      );
    } catch (error) {
      await requestController.close();
      await responseController.close();
      return Result.error(
        unexpectedErrorBuilder?.call(error) ??
            CustomNetworkException(error.toString()),
      );
    }

    void emit(Result<Output> result) {
      if (!responseController.isClosed) {
        logger.d('[$logTag] emit $result');
        responseController.add(result);
      }
    }

    late final StreamSubscription<Res> subscription;
    subscription = responseStream.listen(
      (response) {
        emit(responseMapper(response));
      },
      onError: (error, stackTrace) {
        if (error is GrpcError) {
          emit(
            Result.error(
              grpcErrorBuilder?.call(error) ?? _defaultGrpcException(error),
            ),
          );
        } else {
          emit(
            Result.error(
              unexpectedErrorBuilder?.call(error) ??
                  CustomNetworkException(error.toString()),
            ),
          );
        }

        if (!responseController.isClosed) {
          responseController.close();
        }
      },
      onDone: () {
        if (!responseController.isClosed) {
          responseController.close();
        }
      },
      cancelOnError: false,
    );

    return Result.ok(
      GrpcBidirectionalStreamHandle._(
        logTag: logTag,
        requestController: requestController,
        responseController: responseController,
        responseStream: responseStream,
        responseSubscription: subscription,
      ),
    );
  }

  static CustomGrpcException _defaultGrpcException(GrpcError error) {
    return CustomGrpcException(
      error.message ?? 'Unknown gRPC error',
      code: error.code,
      rawResponse: error.rawResponse,
      trailers: error.trailers,
      details: error.details,
    );
  }
}

/// 개별 데이터소스가 재사용할 수 있는 공용 스트림 핸들
class GrpcBidirectionalStreamHandle<Req, Res, Output> {
  GrpcBidirectionalStreamHandle._({
    required String logTag,
    required StreamController<Req> requestController,
    required StreamController<Result<Output>> responseController,
    required ResponseStream<Res> responseStream,
    required StreamSubscription<Res> responseSubscription,
  }) : _logTag = logTag,
       _requestController = requestController,
       _responseController = responseController,
       _responseStream = responseStream,
       _responseSubscription = responseSubscription;

  /// 로그 출력 시 사용되는 태그 (통신 맥락 파악용)
  final String _logTag;

  /// 서버로 요청을 전송하는 스트림 컨트롤러
  final StreamController<Req> _requestController;

  /// 서버 응답을 Result 형태로 방출하는 스트림 컨트롤러
  final StreamController<Result<Output>> _responseController;

  /// 서버에서 내려오는 gRPC 응답 스트림
  final ResponseStream<Res> _responseStream;

  /// 응답 스트림 구독 관리 (리소스 정리용)
  final StreamSubscription<Res> _responseSubscription;

  /// 응답(Result)을 UI/도메인 층에서 구독할 수 있는 스트림
  Stream<Result<Output>> get responses => _responseController.stream;

  /// gRPC 서버로 요청을 전송합니다.
  void send(Req request) {
    if (_requestController.isClosed) {
      logger.w('[$_logTag] Ignored request because controller already closed');
      return;
    }

    _requestController.add(request);
  }

  /// 더 이상 통신이 필요 없을 때 호출하여 모든 리소스를 정리합니다.
  Future<void> close() async {
    if (!_requestController.isClosed) {
      await _requestController.close();
    }

    await _responseSubscription.cancel();

    try {
      await _responseStream.cancel();
    } catch (_) {}

    if (!_responseController.isClosed) {
      await _responseController.close();
    }
  }
}
