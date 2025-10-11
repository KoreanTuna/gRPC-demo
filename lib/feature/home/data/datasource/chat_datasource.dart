import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_bidirectional_stream_handler.dart';
import 'package:grpc_study/core/util/grpc/grpc_option.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/environment/api_config.dart';
import 'package:grpc_study/feature/home/data/grpc_mapper/chat_grpc_mapper.dart';
import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';
import 'package:grpc_study/generated/chat/dto/receive_message.pb.dart';
import 'package:grpc_study/generated/chat/dto/send_message.pb.dart';
import 'package:grpc_study/generated/chat/service/chat_service.pbgrpc.dart';
import 'package:injectable/injectable.dart';

class ChatConnection {
  ChatConnection({
    required this.handle,
    required this.channel,
  });

  final GrpcBidirectionalStreamHandle<ReceiveMessage, SendMessage, ChatMessage>
  handle;
  final ClientChannel channel;
}

@singleton
class ChatDatasource {
  ChatDatasource(
    this._mapper,
    this._interceptors,
  );

  final ChatGrpcMapper _mapper;
  final List<ClientInterceptor> _interceptors;

  Future<Result<ChatConnection>> openChatConnection() async {
    final channel = _createChannel();
    final client = ChatServiceClient(
      channel,
      interceptors: _interceptors,
    );

    final result =
        await GrpcBidirectionalStreamHandler.connect<
          ReceiveMessage,
          SendMessage,
          ChatMessage
        >(
          logTag: 'ChatDatasource.openChatConnection',
          clientInvoker: (requestStream) {
            return client.openChatConnection(
              requestStream,
              options: GrpcOptions.streamingCallOptions(
                meta: {ApiConfig.authFlagKey: 'true'},
              ),
            );
          },
          responseMapper: (response) => Result.ok(
            _mapper.toChatMessage(response),
          ),
        );

    if (result
        is Ok<
          GrpcBidirectionalStreamHandle<
            ReceiveMessage,
            SendMessage,
            ChatMessage
          >
        >) {
      logger.d('[ChatDatasource] Bidirectional stream connected');
      return Result.ok(
        ChatConnection(
          handle: result.value,
          channel: channel,
        ),
      );
    }

    await channel.shutdown();
    logger.e('[ChatDatasource] Failed to open chat connection');
    return Result.error((result as Error).error);
  }

  ClientChannel _createChannel() {
    return ClientChannel(
      ApiConfig.baseUrl,
      port: ApiConfig.gRpcPort,
      options: ChannelOptions(
        connectTimeout: const Duration(seconds: 60),
        connectionTimeout: const Duration(seconds: 60),
        codecRegistry: CodecRegistry(
          codecs: [const GzipCodec(), const IdentityCodec()],
        ),
        credentials: ChannelCredentials.secure(
          authority: ApiConfig.baseUrl,
          onBadCertificate: (cert, host) => kDebugMode,
        ),
      ),
    );
  }
}
