// This is a generated file - do not edit.
//
// Generated from chat/dto/receive_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use receiveMessageDescriptor instead')
const ReceiveMessage$json = {
  '1': 'ReceiveMessage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'userName', '3': 3, '4': 1, '5': 9, '10': 'userName'},
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.chat.v1.MessageType',
      '10': 'type'
    },
  ],
};

/// Descriptor for `ReceiveMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveMessageDescriptor = $convert.base64Decode(
    'Cg5SZWNlaXZlTWVzc2FnZRIOCgJpZBgBIAEoCVICaWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2'
    'FnZRIaCgh1c2VyTmFtZRgDIAEoCVIIdXNlck5hbWUSOAoJdGltZXN0YW1wGAQgASgLMhouZ29v'
    'Z2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdGltZXN0YW1wEigKBHR5cGUYBSABKA4yFC5jaGF0Ln'
    'YxLk1lc3NhZ2VUeXBlUgR0eXBl');
