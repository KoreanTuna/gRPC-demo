import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_entity.freezed.dart';
part 'login_request_entity.g.dart';

@JsonSerializable()
@freezed
class LoginRequestEntity with _$LoginRequestEntity {
  @override
  final String email;
  @override
  final String password;
  const LoginRequestEntity({
    required this.email,
    required this.password,
  });

  factory LoginRequestEntity.fromJson(Map<String, Object?> json) =>
      _$LoginRequestEntityFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestEntityToJson(this);
}
