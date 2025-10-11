import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';

abstract interface class ChatSession {
  Stream<Result<ChatMessage>> get messages;

  ChatMessage sendUserMessage(String text);

  Future<void> close();
}

abstract interface class ChatRepository {
  Future<Result<ChatSession>> openSession({required String userName});
}
