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

import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'send_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'send_message.pbenum.dart';

class SendMessage extends $pb.GeneratedMessage {
  factory SendMessage({
    $core.String? id,
    $core.String? message,
    $0.Timestamp? timestamp,
    MessageType? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (message != null) result.message = message;
    if (timestamp != null) result.timestamp = timestamp;
    if (type != null) result.type = type;
    return result;
  }

  SendMessage._();

  factory SendMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SendMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SendMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..e<MessageType>(4, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: MessageType.UNKNOWN,
        valueOf: MessageType.valueOf,
        enumValues: MessageType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessage clone() => SendMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendMessage copyWith(void Function(SendMessage) updates) =>
      super.copyWith((message) => updates(message as SendMessage))
          as SendMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SendMessage create() => SendMessage._();
  @$core.override
  SendMessage createEmptyInstance() => create();
  static $pb.PbList<SendMessage> createRepeated() => $pb.PbList<SendMessage>();
  @$core.pragma('dart2js:noInline')
  static SendMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendMessage>(create);
  static SendMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);

  @$pb.TagNumber(4)
  MessageType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(MessageType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
