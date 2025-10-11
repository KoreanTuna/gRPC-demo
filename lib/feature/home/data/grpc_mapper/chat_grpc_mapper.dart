import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';
import 'package:grpc_study/generated/chat/dto/receive_message.pb.dart';
import 'package:grpc_study/generated/chat/dto/send_message.pb.dart';
import 'package:grpc_study/generated/google/protobuf/timestamp.pb.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatGrpcMapper {
  ChatGrpcMapper();

  ChatMessage toChatMessage(SendMessage response) {
    return ChatMessage(
      id: response.id,
      sender: ChatSender.bot,
      message: response.message,
      timestamp: response.hasTimestamp()
          ? response.timestamp.toDateTime()
          : DateTime.now(),
    );
  }

  ReceiveMessage toReceiveMessage({
    required String id,
    required String message,
    required String userName,
    required DateTime timestamp,
  }) {
    return ReceiveMessage()
      ..id = id
      ..message = message
      ..userName = userName
      ..timestamp = Timestamp.fromDateTime(timestamp)
      ..type = MessageType.TEXT;
  }
}
