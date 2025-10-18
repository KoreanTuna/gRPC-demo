// This is a generated file - do not edit.
//
// Generated from user/dto/user.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.user.v1.User.UserType',
      '10': 'type'
    },
    {'1': 'displayName', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'createdAt',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'roles', '3': 5, '4': 3, '5': 9, '10': 'roles'},
    {'1': 'email', '3': 6, '4': 1, '5': 9, '9': 0, '10': 'email', '17': true},
    {
      '1': 'legacy_field',
      '3': 7,
      '4': 1,
      '5': 9,
      '8': {'3': true},
      '10': 'legacyField',
    },
  ],
  '4': [User_UserType$json],
  '8': [
    {'1': '_email'},
  ],
};

@$core.Deprecated('Use userDescriptor instead')
const User_UserType$json = {
  '1': 'UserType',
  '2': [
    {'1': 'USER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'USER_TYPE_NORMAL', '2': 1},
    {'1': 'USER_TYPE_ADMIN', '2': 2},
    {'1': 'USER_TYPE_GUEST', '2': 3},
    {
      '1': 'ORDER_STATUS_CANCELLED',
      '2': 4,
      '3': {'1': true},
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIqCgR0eXBlGAIgASgOMhYudXNlci52MS5Vc2VyLlVzZX'
    'JUeXBlUgR0eXBlEiAKC2Rpc3BsYXlOYW1lGAMgASgJUgtkaXNwbGF5TmFtZRI4CgljcmVhdGVk'
    'QXQYBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSFAoFcm9sZX'
    'MYBSADKAlSBXJvbGVzEhkKBWVtYWlsGAYgASgJSABSBWVtYWlsiAEBEiUKDGxlZ2FjeV9maWVs'
    'ZBgHIAEoCUICGAFSC2xlZ2FjeUZpZWxkIoUBCghVc2VyVHlwZRIZChVVU0VSX1RZUEVfVU5TUE'
    'VDSUZJRUQQABIUChBVU0VSX1RZUEVfTk9STUFMEAESEwoPVVNFUl9UWVBFX0FETUlOEAISEwoP'
    'VVNFUl9UWVBFX0dVRVNUEAMSHgoWT1JERVJfU1RBVFVTX0NBTkNFTExFRBAEGgIIAUIICgZfZW'
    '1haWw=');
