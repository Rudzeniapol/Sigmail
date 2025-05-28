// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateUserModelImpl _$$CreateUserModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateUserModelImpl(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$CreateUserModelImplToJson(
        _$CreateUserModelImpl instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
    };
