import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_bidirectional_stream_handler.dart';
import 'package:grpc_study/core/util/grpc/grpc_datasource_base.dart';
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
  });

  final GrpcBidirectionalStreamHandle<ReceiveMessage, SendMessage, ChatMessage>
  handle;
}

@singleton
class ChatDatasource extends GrpcDatasourceBase {
  ChatDatasource(
    this._mapper,
    @Named('stream_channel') ClientChannel channel,
    List<ClientInterceptor> interceptors,
  ) : super(channel, interceptors);
  final ChatGrpcMapper _mapper;

  Future<Result<ChatConnection>> openChatConnection() async {
    final ChatServiceClient client = createClient(ChatServiceClient.new);

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
        ),
      );
    }

    logger.e('[ChatDatasource] Failed to open chat connection');
    return Result.error((result as Error).error);
  }
}
