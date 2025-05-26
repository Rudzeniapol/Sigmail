import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart'; // Сгенерируется freezed
part 'user_model.g.dart';      // Сгенерируется json_serializable

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id, // В Dart принято camelCase для полей
    required String username,
    required String email,
    String? profileImageUrl,
    String? bio,
    required bool isOnline,
    DateTime? lastSeen,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}