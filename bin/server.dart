import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:grpc_study/generated/chat/dto/receive_message.pb.dart';
import 'package:grpc_study/generated/chat/dto/send_message.pb.dart';
import 'package:grpc_study/generated/chat/service/chat_service.pbgrpc.dart';
import 'package:grpc_study/generated/google/protobuf/empty.pb.dart';
import 'package:grpc_study/generated/token/dto/refresh_token_request.pb.dart';
import 'package:grpc_study/generated/token/dto/refresh_token_response.pb.dart';
import 'package:grpc_study/generated/token/service/token_service.pbgrpc.dart';
import 'package:grpc_study/generated/user/dto/user_login_request.pb.dart';
import 'package:grpc_study/generated/user/dto/user_login_response.pb.dart';
import 'package:grpc_study/generated/user/service/user_login_service.pbgrpc.dart';
import 'package:grpc_study/generated/user/service/user_logout_service.pbgrpc.dart';

class UserLoginService extends UserLoginServiceBase {
  @override
  Future<LoginResponse> login(ServiceCall call, LoginRequest request) async {
    /// 이메일이 1234, 비밀번호가 1234인 경우에만 성공
    if (request.email != '1234' || request.password != '1234') {
      throw const GrpcError.unauthenticated('없는 계정 정보입니다.');
    }

    return LoginResponse()
      ..accessToken = 'demo_access_token'
      ..refreshToken = 'demo_refresh_token';
  }
}

class TokenService extends TokenServiceBase {
  @override
  Future<RefreshTokenResponse> refreshToken(
    ServiceCall call,
    RefreshTokenRequest request,
  ) async {
    return RefreshTokenResponse()
      ..accessToken = 'new_demo_access_token'
      ..refreshToken = 'new_demo_refresh_token';
  }
}

class UserLogoutService extends UserLogoutServiceBase {
  @override
  Future<Empty> logout(ServiceCall call, Empty request) async {
    return Empty();
  }
}

class ChatService extends ChatServiceBase {
  @override
  Stream<SendMessage> openChatConnection(
    ServiceCall call,
    Stream<ReceiveMessage> request,
  ) async* {
    await for (final receiveMessage in request) {
      final sendMessage = SendMessage()
        ..id = receiveMessage.id
        ..message = receiveMessage.message
        ..timestamp = receiveMessage.timestamp
        ..type = receiveMessage.type;
      yield sendMessage;
    }
  }
}

Future<void> main(List<String> args) async {
  final certificate = File('certs/server.pem').readAsBytesSync();
  final privateKey = File('certs/server.key').readAsBytesSync();
  final server = Server.create(
    services: [
      UserLoginService(),
      TokenService(),
      UserLogoutService(),
      ChatService(),
    ],
    codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    serverInterceptors: [
      CustomServerInterceptor(),
    ],
  );
  await server.serve(
    port: 50051,
    security: ServerTlsCredentials(
      certificate: certificate,
      privateKey: privateKey,
    ),
  );
  print('Server listening on port ${server.port}...');
}

class CustomServerInterceptor extends ServerInterceptor {
  @override
  Stream<R> intercept<Q, R>(
    ServiceCall call,
    ServiceMethod<Q, R> method,
    Stream<Q> requests,
    ServerStreamingInvoker<Q, R> invoker,
  ) {
    print('''
------------------------------------------------
[요청]: ${method.name},
$requests
------------------------------------------------
''');
    final responseStream = invoker(call, method, requests);
    return responseStream.map((response) {
      print('''
------------------------------------------------
[응답]: ${method.name},
$response
------------------------------------------------\
''');
      return response;
    });
  }
}
