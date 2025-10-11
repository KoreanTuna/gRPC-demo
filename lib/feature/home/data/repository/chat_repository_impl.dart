import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:grpc_study/core/util/grpc/grpc_bidirectional_stream_handler.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/home/data/datasource/chat_datasource.dart';
import 'package:grpc_study/feature/home/data/grpc_mapper/chat_grpc_mapper.dart';
import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';
import 'package:grpc_study/feature/home/domain/repository/chat_repository.dart';
import 'package:grpc_study/generated/chat/dto/receive_message.pb.dart';
import 'package:grpc_study/generated/chat/dto/send_message.pb.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._datasource, this._mapper);

  final ChatDatasource _datasource;
  final ChatGrpcMapper _mapper;

  @override
  Future<Result<ChatSession>> openSession({required String userName}) async {
    final result = await _datasource.openChatConnection();

    if (result is Ok<ChatConnection>) {
      final connection = result.value;
      return Result.ok(
        _ChatSessionImpl(
          connection: connection,
          mapper: _mapper,
          userName: userName,
        ),
      );
    }

    return Result.error((result as Error).error);
  }
}

class _ChatSessionImpl implements ChatSession {
  _ChatSessionImpl({
    required ChatConnection connection,
    required ChatGrpcMapper mapper,
    required String userName,
  }) : _handle = connection.handle,
       _channel = connection.channel,
       _mapper = mapper,
       _userName = userName;

  final GrpcBidirectionalStreamHandle<ReceiveMessage, SendMessage, ChatMessage>
  _handle;
  final ClientChannel _channel;
  final ChatGrpcMapper _mapper;
  final String _userName;
  bool _isClosed = false;

  @override
  Stream<Result<ChatMessage>> get messages => _handle.responses;

  @override
  ChatMessage sendUserMessage(String text) {
    if (_isClosed) {
      throw StateError('Chat session already closed');
    }

    final now = DateTime.now().toUtc();
    final id = now.microsecondsSinceEpoch.toString();

    final request = _mapper.toReceiveMessage(
      id: id,
      message: text,
      userName: _userName,
      timestamp: now,
    );

    _handle.send(request);

    return ChatMessage(
      id: id,
      sender: ChatSender.user,
      message: text,
      timestamp: now,
    );
  }

  @override
  Future<void> close() async {
    if (_isClosed) {
      return;
    }
    _isClosed = true;

    await _handle.close();

    try {
      await _channel.shutdown();
    } catch (error, stackTrace) {
      logger.e(
        'Failed to shutdown chat channel: $error',
        stackTrace: stackTrace,
      );
    }
  }
}
