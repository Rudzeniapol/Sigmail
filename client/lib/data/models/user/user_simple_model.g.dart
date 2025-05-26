// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_simple_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSimpleModelImpl _$$UserSimpleModelImplFromJson(
  Map<String, dynamic> json,
) => _$UserSimpleModelImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$$UserSimpleModelImplToJson(
  _$UserSimpleModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'profileImageUrl': instance.profileImageUrl,
};
