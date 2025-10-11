import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/grpc/interceptor/grpc_auth_interceptor.dart';
import 'package:grpc_study/core/util/grpc/interceptor/grpc_logging_interceptor.dart';
import 'package:grpc_study/core/util/secure_storage_util.dart';
import 'package:grpc_study/environment/api_config.dart';
import 'package:grpc_study/environment/di/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_grpc_logger/talker_grpc_logger.dart';

@module
abstract class GrpcModule {
  @lazySingleton
  LoggingInterceptor loggingInterceptor() => LoggingInterceptor();

  @lazySingleton
  AuthInterceptor authInterceptor(
    SecureStorageUtil secureStorageUtil,
  ) => AuthInterceptor(
    secureStorageUtil,
    () => locator<TokenUsecase>(),
  );

  @lazySingleton
  TalkerGrpcLogger talkerGrpcLogger() {
    final talker = TalkerFlutter.init(
      logger: TalkerLogger(settings: TalkerLoggerSettings()),
      settings: TalkerSettings(),
    );
    return TalkerGrpcLogger(talker: talker);
  }

  @preResolve
  @Named('default_channel')
  @lazySingleton
  Future<ClientChannel> defaultChannel() async {
    return _buildSecureChannel(
      connectTimeout: const Duration(seconds: 5),
      connectionTimeout: const Duration(seconds: 5),
    );
  }

  @preResolve
  @Named('stream_channel')
  @lazySingleton
  Future<ClientChannel> streamChannel() async {
    return _buildSecureChannel(
      connectTimeout: const Duration(seconds: 60),
      connectionTimeout: const Duration(seconds: 60),
    );
  }

  // 공통 인터셉터 리스트
  @singleton
  List<ClientInterceptor> interceptors(
    LoggingInterceptor log,
    AuthInterceptor auth,
    TalkerGrpcLogger _,
  ) => List<ClientInterceptor>.unmodifiable([auth, log]);

  ClientChannel _buildSecureChannel({
    required Duration connectTimeout,
    required Duration connectionTimeout,
  }) {
    return ClientChannel(
      ApiConfig.baseUrl,
      port: ApiConfig.gRpcPort,
      options: ChannelOptions(
        connectTimeout: connectTimeout,
        connectionTimeout: connectionTimeout,

        codecRegistry: CodecRegistry(
          codecs: [const GzipCodec(), const IdentityCodec()],
        ),
        credentials: ChannelCredentials.secure(
          authority: ApiConfig.baseUrl,
          onBadCertificate: (X509Certificate cert, String host) => kDebugMode,
        ),
      ),
    );
  }
}
