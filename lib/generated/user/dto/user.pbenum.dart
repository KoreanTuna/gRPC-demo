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

class User_UserType extends $pb.ProtobufEnum {
  static const User_UserType USER_TYPE_UNSPECIFIED =
      User_UserType._(0, _omitEnumNames ? '' : 'USER_TYPE_UNSPECIFIED');
  static const User_UserType USER_TYPE_NORMAL =
      User_UserType._(1, _omitEnumNames ? '' : 'USER_TYPE_NORMAL');
  static const User_UserType USER_TYPE_ADMIN =
      User_UserType._(2, _omitEnumNames ? '' : 'USER_TYPE_ADMIN');
  static const User_UserType USER_TYPE_GUEST =
      User_UserType._(3, _omitEnumNames ? '' : 'USER_TYPE_GUEST');
  @$core.Deprecated('This enum value is deprecated')
  static const User_UserType ORDER_STATUS_CANCELLED =
      User_UserType._(4, _omitEnumNames ? '' : 'ORDER_STATUS_CANCELLED');

  static const $core.List<User_UserType> values = <User_UserType>[
    USER_TYPE_UNSPECIFIED,
    USER_TYPE_NORMAL,
    USER_TYPE_ADMIN,
    USER_TYPE_GUEST,
    ORDER_STATUS_CANCELLED,
  ];

  static final $core.List<User_UserType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static User_UserType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const User_UserType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
