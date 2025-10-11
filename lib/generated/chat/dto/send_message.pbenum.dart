// This is a generated file - do not edit.
//
// Generated from chat/dto/send_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MessageType extends $pb.ProtobufEnum {
  static const MessageType UNKNOWN =
      MessageType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const MessageType TEXT =
      MessageType._(1, _omitEnumNames ? '' : 'TEXT');
  static const MessageType IMAGE =
      MessageType._(2, _omitEnumNames ? '' : 'IMAGE');
  static const MessageType VIDEO =
      MessageType._(3, _omitEnumNames ? '' : 'VIDEO');

  static const $core.List<MessageType> values = <MessageType>[
    UNKNOWN,
    TEXT,
    IMAGE,
    VIDEO,
  ];

  static final $core.List<MessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
