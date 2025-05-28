import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_model.freezed.dart';
part 'reaction_model.g.dart';

@freezed
class ReactionModel with _$ReactionModel {
  const factory ReactionModel({
    required String emoji,
    @Default([]) List<String> userIds,
    DateTime? firstReactedAt,
    DateTime? lastReactedAt,
    // Клиент может вычислить count локально, если нужно: userIds.length
    // int? count, // Раскомментировать, если сервер будет присылать count и это нужно хранить
  }) = _ReactionModel;

  factory ReactionModel.fromJson(Map<String, dynamic> json) => _$ReactionModelFromJson(json);

  // Статический конструктор для "пустой" реакции
  static ReactionModel empty() => const ReactionModel(emoji: '', userIds: []);
} 