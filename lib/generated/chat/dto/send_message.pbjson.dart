// This is a generated file - do not edit.
//
// Generated from chat/dto/send_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'TEXT', '2': 1},
    {'1': 'IMAGE', '2': 2},
    {'1': 'VIDEO', '2': 3},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRILCgdVTktOT1dOEAASCAoEVEVYVBABEgkKBUlNQUdFEAISCQoFVklERU'
    '8QAw==');

@$core.Deprecated('Use sendMessageDescriptor instead')
const SendMessage$json = {
  '1': 'SendMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.chat.v1.MessageType',
      '10': 'type'
    },
  ],
};

/// Descriptor for `SendMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageDescriptor = $convert.base64Decode(
    'CgtTZW5kTWVzc2FnZRIOCgJpZBgBIAEoCVICaWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZR'
    'I4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3Rh'
    'bXASKAoEdHlwZRgEIAEoDjIULmNoYXQudjEuTWVzc2FnZVR5cGVSBHR5cGU=');
