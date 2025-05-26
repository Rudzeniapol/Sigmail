// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ContactModelImpl _$$ContactModelImplFromJson(Map<String, dynamic> json) =>
    _$ContactModelImpl(
      contactEntryId: json['contactEntryId'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      status: $enumDecode(_$ContactStatusModelEnumMap, json['status']),
      requestedAt:
          json['requestedAt'] == null
              ? null
              : DateTime.parse(json['requestedAt'] as String),
      respondedAt:
          json['respondedAt'] == null
              ? null
              : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$$ContactModelImplToJson(_$ContactModelImpl instance) =>
    <String, dynamic>{
      'contactEntryId': instance.contactEntryId,
      'user': instance.user,
      'status': _$ContactStatusModelEnumMap[instance.status]!,
      'requestedAt': instance.requestedAt?.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

const _$ContactStatusModelEnumMap = {
  ContactStatusModel.pending: 'Pending',
  ContactStatusModel.accepted: 'Accepted',
  ContactStatusModel.declined: 'Declined',
  ContactStatusModel.blocked: 'Blocked',
};
