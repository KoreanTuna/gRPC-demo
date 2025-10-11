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

  final List<ChatMessage> _messages = <ChatMessage>[];
  final StreamController<List<ChatMessage>> _messagesController =
      StreamController<List<ChatMessage>>.broadcast();
  final StreamController<CustomException> _errorController =
      StreamController<CustomException>.broadcast();

  ChatSession? _session;
  StreamSubscription<Result<ChatMessage>>? _sessionSubscription;
  Completer<bool>? _connectionCompleter;

  /// 데모용 채팅 세션에서 사용할 사용자명.
  static const String _defaultUserName = 'DemoUser';

  /// UI가 구독하는 채팅 메시지 스트림.
  Stream<List<ChatMessage>> get messagesStream => _messagesController.stream;

  /// 전송/수신 중 발생한 예외 이벤트 스트림.
  Stream<CustomException> get errorStream => _errorController.stream;

  /// UI에서 전달된 텍스트 메시지를 gRPC 세션으로 전송한다.
  Future<void> sendMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final bool connected = await _ensureSession();

    if (!connected) {
      return;
    }

    final ChatSession? chatSession = _session;
    if (chatSession == null) {
      return;
    }

    try {
      final ChatMessage userMessage = chatSession.sendUserMessage(trimmed);
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

  /// 첫 메시지 전송 시점에만 세션을 열고 이후에는 기존 세션을 재사용한다.
  Future<bool> _ensureSession() async {
    if (_session != null) {
      return true;
    }

    final Completer<bool>? ongoing = _connectionCompleter;
    if (ongoing != null) {
      return ongoing.future;
    }

    final Completer<bool> completer = Completer<bool>();
    _connectionCompleter = completer;

    final Result<ChatSession> result = await _chatUsecase.openSession(
      userName: _defaultUserName,
    );

    if (result is Ok<ChatSession>) {
      final ChatSession session = result.value;
      _session = session;
      _listenToSession(session);
      completer.complete(true);
    } else {
      final CustomException error = (result as Error).error;
      _errorController.add(error);
      completer.complete(false);
    }

    _connectionCompleter = null;
    return completer.future;
  }

  /// 서버에서 수신하는 메시지를 Result 단위로 변환해 전달받는다.
  void _listenToSession(ChatSession session) {
    _sessionSubscription?.cancel();
    _sessionSubscription = session.messages.listen((
      Result<ChatMessage> result,
    ) {
      result.when(
        ok: _addMessage,
        error: _errorController.add,
      );
    });
  }

  /// UI에 즉시 반영하기 위해 메시지 리스트를 관리한다.
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    if (!_messagesController.isClosed) {
      _messagesController.add(List.unmodifiable(_messages));
    }
  }

  /// 화면을 떠날 때 스트림과 채널 자원을 모두 정리한다.
  Future<void> closeChat() async {
    final Completer<bool>? completer = _connectionCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
    _connectionCompleter = null;

    await _sessionSubscription?.cancel();
    _sessionSubscription = null;

    final ChatSession? session = _session;
    _session = null;

    if (session != null) {
      await session.close();
    }

    _messages.clear();

    if (!_messagesController.isClosed) {
      _messagesController.add(const []);
    }
  }

  /// 로그아웃 시 채팅 연결을 종료한 뒤 서버 로그아웃을 수행한다.
  Future<Result<void>> logout() async {
    await closeChat();
    return _logoutUsecase.logout();
  }

  /// ViewModel이 더 이상 사용되지 않을 때 호출된다.
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
