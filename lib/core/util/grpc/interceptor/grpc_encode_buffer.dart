import 'dart:convert';
import 'package:protobuf/protobuf.dart';

String protoJsonWithDefaults(Object? obj) => jsonEncode(_encode(obj));

dynamic _encode(dynamic v) {
  if (v is GeneratedMessage) {
    final out = <String, dynamic>{};
    final fields = v.info_.fieldInfo.values;
    for (final fi in fields) {
      final value = v.getField(fi.tagNumber);
      out[fi.name] = _encode(value);
    }
    return out;
  } else if (v is PbList) {
    return v.map(_encode).toList();
  } else if (v is ProtobufEnum) {
    return v.name; // 혹은 v.value
  } else if (v is List<int>) {
    // bytes는 base64로
    return base64Encode(v);
  } else if (v.runtimeType.toString() == 'Int64') {
    // Int64를 int로 변환 (또는 필요에 따라 string으로)
    return v.toInt();
  } else {
    return v;
  }
}
