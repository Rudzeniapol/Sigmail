// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResultModelImpl _$$AuthResultModelImplFromJson(
  Map<String, dynamic> json,
) => _$AuthResultModelImpl(
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['accessToken'] as String,
  accessTokenExpiration: DateTime.parse(
    json['accessTokenExpiration'] as String,
  ),
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$$AuthResultModelImplToJson(
  _$AuthResultModelImpl instance,
) => <String, dynamic>{
  'user': instance.user,
  'accessToken': instance.accessToken,
  'accessTokenExpiration': instance.accessTokenExpiration.toIso8601String(),
  'refreshToken': instance.refreshToken,
};
