// This is a generated file - do not edit.
//
// Generated from user/dto/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'user.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'user.pbenum.dart';

class User extends $pb.GeneratedMessage {
  factory User({
    $core.String? id,
    User_UserType? type,
    $core.String? displayName,
    $0.Timestamp? createdAt,
    $core.Iterable<$core.String>? roles,
    $core.String? email,
    @$core.Deprecated('This field is deprecated.') $core.String? legacyField,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (displayName != null) result.displayName = displayName;
    if (createdAt != null) result.createdAt = createdAt;
    if (roles != null) result.roles.addAll(roles);
    if (email != null) result.email = email;
    if (legacyField != null) result.legacyField = legacyField;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'user.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..e<User_UserType>(2, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: User_UserType.USER_TYPE_UNSPECIFIED,
        valueOf: User_UserType.valueOf,
        enumValues: User_UserType.values)
    ..aOS(3, _omitFieldNames ? '' : 'displayName', protoName: 'displayName')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createdAt',
        protoName: 'createdAt', subBuilder: $0.Timestamp.create)
    ..pPS(5, _omitFieldNames ? '' : 'roles')
    ..aOS(6, _omitFieldNames ? '' : 'email')
    ..aOS(7, _omitFieldNames ? '' : 'legacyField')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => User()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) =>
      super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  static $pb.PbList<User> createRepeated() => $pb.PbList<User>();
  @$core.pragma('dart2js:noInline')
  static User getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  User_UserType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(User_UserType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get displayName => $_getSZ(2);
  @$pb.TagNumber(3)
  set displayName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDisplayName() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisplayName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createdAt => $_getN(3);
  @$pb.TagNumber(4)
  set createdAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreatedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get roles => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get email => $_getSZ(5);
  @$pb.TagNumber(6)
  set email($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEmail() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmail() => $_clearField(6);

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(7)
  $core.String get legacyField => $_getSZ(6);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(7)
  set legacyField($core.String value) => $_setString(6, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(7)
  $core.bool hasLegacyField() => $_has(6);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(7)
  void clearLegacyField() => $_clearField(7);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
