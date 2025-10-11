// This is a generated file - do not edit.
//
// Generated from user/service/user_login_service.proto.

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

import '../dto/user_login_request.pb.dart' as $0;
import '../dto/user_login_response.pb.dart' as $1;

export 'user_login_service.pb.dart';

@$pb.GrpcServiceName('user.v1.UserLoginService')
class UserLoginServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UserLoginServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.LoginResponse> login(
    $0.LoginRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$login, request, options: options);
  }

  // method descriptors

  static final _$login = $grpc.ClientMethod<$0.LoginRequest, $1.LoginResponse>(
      '/user.v1.UserLoginService/Login',
      ($0.LoginRequest value) => value.writeToBuffer(),
      $1.LoginResponse.fromBuffer);
}

@$pb.GrpcServiceName('user.v1.UserLoginService')
abstract class UserLoginServiceBase extends $grpc.Service {
  $core.String get $name => 'user.v1.UserLoginService';

  UserLoginServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LoginRequest, $1.LoginResponse>(
        'Login',
        login_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LoginRequest.fromBuffer(value),
        ($1.LoginResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.LoginResponse> login_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoginRequest> $request) async {
    return login($call, await $request);
  }

  $async.Future<$1.LoginResponse> login(
      $grpc.ServiceCall call, $0.LoginRequest request);
}
