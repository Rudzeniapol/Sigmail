import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_simple_model.freezed.dart';
part 'user_simple_model.g.dart';

@freezed
class UserSimpleModel with _$UserSimpleModel {
  const factory UserSimpleModel({
    required String id,
    required String username,
    String? profileImageUrl,
    // Можно добавить isOnline, если это часто нужно в контексте UserSimpleModel
    // bool? isOnline,
  }) = _UserSimpleModel;

  factory UserSimpleModel.fromJson(Map<String, dynamic> json) => _$UserSimpleModelFromJson(json);
}