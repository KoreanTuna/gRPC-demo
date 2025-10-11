import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_entity.freezed.dart';
part 'token_entity.g.dart';

@JsonSerializable()
@freezed
class TokenEntity with _$TokenEntity {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  const TokenEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenEntity.fromJson(Map<String, Object?> json) =>
      _$TokenEntityFromJson(json);
  Map<String, dynamic> toJson() => _$TokenEntityToJson(this);
}
