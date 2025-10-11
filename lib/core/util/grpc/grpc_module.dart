import 'dart:io';
import 'package:flutter/services.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_study/common/domain/usecase/token_usecase.dart';
import 'package:grpc_study/core/util/grpc/interceptor/grpc_auth_interceptor.dart';
import 'package:grpc_study/core/util/grpc/interceptor/grpc_logging_interceptor.dart';
import 'package:grpc_study/core/util/secure_storage_util.dart';
import 'package:grpc_study/environment/api_config.dart';
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
    TokenUsecase tokenUsecase,
  ) => AuthInterceptor(secureStorageUtil, tokenUsecase);

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
    final certificates = await _loadCertificates();
    return _buildSecureChannel(
      certificates: certificates,
      connectTimeout: const Duration(seconds: 5),
      connectionTimeout: const Duration(seconds: 5),
    );
  }

  @preResolve
  @Named('stream_channel')
  @lazySingleton
  Future<ClientChannel> streamChannel() async {
    final certificates = await _loadCertificates();
    return _buildSecureChannel(
      certificates: certificates,
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

  static const String _certificateAssetPath = 'assets/cert/danalpay-chain.pem';

  Future<Uint8List> _loadCertificates() async {
    final bytes = await rootBundle.load(_certificateAssetPath);
    return bytes.buffer.asUint8List();
  }

  ClientChannel _buildSecureChannel({
    required Uint8List certificates,
    required Duration connectTimeout,
    required Duration connectionTimeout,
  }) {
    return ClientChannel(
      ApiConfig.baseUrl,
      port: ApiConfig.gRpcPort,
      options: ChannelOptions(
        connectTimeout: connectTimeout,
        connectionTimeout: connectionTimeout,
        codecRegistry: CodecRegistry(codecs: [GzipCodec(), IdentityCodec()]),
        credentials: ChannelCredentials.secure(
          certificates: certificates,
          authority: ApiConfig.baseUrl,
          onBadCertificate: (X509Certificate cert, String host) => true,
        ),
      ),
    );
  }
}
