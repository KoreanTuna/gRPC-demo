import 'dart:async';

import 'package:grpc_study/common/domain/usecase/logout_usecase.dart';
import 'package:grpc_study/core/exception/custom_exception.dart';
import 'package:grpc_study/core/util/logger.dart';
import 'package:grpc_study/core/util/result.dart';
import 'package:grpc_study/feature/home/domain/entities/chat_message.dart';
import 'package:grpc_study/feature/home/domain/repository/chat_repository.dart';
import 'package:grpc_study/feature/home/domain/usecase/chat_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeViewModel {
  HomeViewModel(
    this._logoutUsecase,
    this._chatUsecase,
  );

  final LogoutUsecase _logoutUsecase;
  final ChatUsecase _chatUsecase;

  final List<ChatMessage> _messages = [];
  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<CustomException> _errorController =
      StreamController<CustomException>.broadcast();

  ChatSession? _session;
  StreamSubscription<Result<ChatMessage>>? _sessionSubscription;
  Completer<bool>? _connectionCompleter;

  static const String _defaultUserName = 'DemoUser';

  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  Stream<CustomException> get errorStream => _errorController.stream;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final connected = await _ensureSession();

    if (!connected) {
      return;
    }

    final chatSession = _session;
    if (chatSession == null) {
      return;
    }

    try {
      final userMessage = chatSession.sendUserMessage(trimmed);
      _addMessage(userMessage);
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to send chat message: $error',
        stackTrace: stackTrace,
      );
      _errorController.add(
        CustomNetworkException('메시지를 전송할 수 없습니다.'),
      );
    }
  }

  Future<bool> _ensureSession() async {
    if (_session != null) {
      return true;
    }

    final ongoing = _connectionCompleter;
    if (ongoing != null) {
      return ongoing.future;
    }

    final completer = Completer<bool>();
    _connectionCompleter = completer;

    final result = await _chatUsecase.openSession(userName: _defaultUserName);

    if (result is Ok<ChatSession>) {
      final session = result.value;
      _session = session;
      _listenToSession(session);
      completer.complete(true);
    } else {
      final error = (result as Error).error;
      _errorController.add(error);
      completer.complete(false);
    }

    _connectionCompleter = null;
    return completer.future;
  }

  void _listenToSession(ChatSession session) {
    _sessionSubscription?.cancel();
    _sessionSubscription = session.messages.listen((result) {
      result.when(
        ok: _addMessage,
        error: _errorController.add,
      );
    });
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    if (!_messagesController.isClosed) {
      _messagesController.add(List.unmodifiable(_messages));
    }
  }

  Future<void> closeChat() async {
    final completer = _connectionCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    _connectionCompleter = null;

    await _sessionSubscription?.cancel();
    _sessionSubscription = null;

    final session = _session;
    _session = null;

    if (session != null) {
      await session.close();
    }

    _messages.clear();

    if (!_messagesController.isClosed) {
      _messagesController.add(const []);
    }
  }

  Future<Result<void>> logout() async {
    await closeChat();
    return _logoutUsecase.logout();
  }

  void dispose() {
    unawaited(closeChat());

    if (!_messagesController.isClosed) {
      _messagesController.close();
    }

    if (!_errorController.isClosed) {
      _errorController.close();
    }
  }
}
