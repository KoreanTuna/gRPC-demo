// This is a generated file - do not edit.
//
// Generated from chat/dto/receive_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'send_message.pbenum.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class ReceiveMessage extends $pb.GeneratedMessage {
  factory ReceiveMessage({
    $core.String? id,
    $core.String? message,
    $core.String? userName,
    $0.Timestamp? timestamp,
    $1.MessageType? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (message != null) result.message = message;
    if (userName != null) result.userName = userName;
    if (timestamp != null) result.timestamp = timestamp;
    if (type != null) result.type = type;
    return result;
  }

  ReceiveMessage._();

  factory ReceiveMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReceiveMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReceiveMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'userName', protoName: 'userName')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..e<$1.MessageType>(5, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: $1.MessageType.UNKNOWN,
        valueOf: $1.MessageType.valueOf,
        enumValues: $1.MessageType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveMessage clone() => ReceiveMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveMessage copyWith(void Function(ReceiveMessage) updates) =>
      super.copyWith((message) => updates(message as ReceiveMessage))
          as ReceiveMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReceiveMessage create() => ReceiveMessage._();
  @$core.override
  ReceiveMessage createEmptyInstance() => create();
  static $pb.PbList<ReceiveMessage> createRepeated() =>
      $pb.PbList<ReceiveMessage>();
  @$core.pragma('dart2js:noInline')
  static ReceiveMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReceiveMessage>(create);
  static ReceiveMessage? _defaultInstance;

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
  $core.String get userName => $_getSZ(2);
  @$pb.TagNumber(3)
  set userName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserName() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.MessageType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type($1.MessageType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
