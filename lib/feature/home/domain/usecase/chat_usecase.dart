import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/home/domain/repository/chat_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ChatUsecase {
  ChatUsecase(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<Result<ChatSession>> openSession({required String userName}) {
    return _chatRepository.openSession(userName: userName);
  }
}
