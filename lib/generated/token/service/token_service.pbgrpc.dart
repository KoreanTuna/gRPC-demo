// This is a generated file - do not edit.
//
// Generated from token/service/token_service.proto.

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

import '../dto/refresh_token_request.pb.dart' as $0;
import '../dto/refresh_token_response.pb.dart' as $1;

export 'token_service.pb.dart';

@$pb.GrpcServiceName('token.v1.TokenService')
class TokenServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TokenServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.RefreshTokenResponse> refreshToken(
    $0.RefreshTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshToken, request, options: options);
  }

  // method descriptors

  static final _$refreshToken =
      $grpc.ClientMethod<$0.RefreshTokenRequest, $1.RefreshTokenResponse>(
          '/token.v1.TokenService/refreshToken',
          ($0.RefreshTokenRequest value) => value.writeToBuffer(),
          $1.RefreshTokenResponse.fromBuffer);
}

@$pb.GrpcServiceName('token.v1.TokenService')
abstract class TokenServiceBase extends $grpc.Service {
  $core.String get $name => 'token.v1.TokenService';

  TokenServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.RefreshTokenRequest, $1.RefreshTokenResponse>(
            'refreshToken',
            refreshToken_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RefreshTokenRequest.fromBuffer(value),
            ($1.RefreshTokenResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.RefreshTokenResponse> refreshToken_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RefreshTokenRequest> $request) async {
    return refreshToken($call, await $request);
  }

  $async.Future<$1.RefreshTokenResponse> refreshToken(
      $grpc.ServiceCall call, $0.RefreshTokenRequest request);
}
