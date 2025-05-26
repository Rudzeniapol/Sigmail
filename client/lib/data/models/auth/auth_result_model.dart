    import 'package:freezed_annotation/freezed_annotation.dart';
    import 'package:sigmail_client/data/models/user/user_model.dart'; // Предполагая, что UserModel уже создан

    part 'auth_result_model.freezed.dart';
    part 'auth_result_model.g.dart';

    @freezed
    class AuthResultModel with _$AuthResultModel {
      const factory AuthResultModel({
        required UserModel user,
        required String accessToken,
        required DateTime accessTokenExpiration,
        required String refreshToken,
      }) = _AuthResultModel;

      factory AuthResultModel.fromJson(Map<String, dynamic> json) => _$AuthResultModelFromJson(json);
    }