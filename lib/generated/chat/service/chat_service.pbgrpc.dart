// This is a generated file - do not edit.
//
// Generated from chat/service/chat_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import '../dto/receive_message.pb.dart' as $0;
import '../dto/send_message.pb.dart' as $1;

export 'chat_service.pb.dart';

@$pb.GrpcServiceName('chat.v1.ChatService')
class ChatServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  ChatServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$1.SendMessage> openChatConnection(
    $async.Stream<$0.ReceiveMessage> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$openChatConnection, request,
        options: options);
  }

  // method descriptors

  static final _$openChatConnection =
      $grpc.ClientMethod<$0.ReceiveMessage, $1.SendMessage>(
          '/chat.v1.ChatService/openChatConnection',
          ($0.ReceiveMessage value) => value.writeToBuffer(),
          $1.SendMessage.fromBuffer);
}

@$pb.GrpcServiceName('chat.v1.ChatService')
abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'chat.v1.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ReceiveMessage, $1.SendMessage>(
        'openChatConnection',
        openChatConnection,
        true,
        true,
        ($core.List<$core.int> value) => $0.ReceiveMessage.fromBuffer(value),
        ($1.SendMessage value) => value.writeToBuffer()));
  }

  $async.Stream<$1.SendMessage> openChatConnection(
      $grpc.ServiceCall call, $async.Stream<$0.ReceiveMessage> request);
}
