import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:sigmail_client/data/models/attachment/attachment_model.dart'; // Старый импорт для AttachmentTypeModel
import 'package:sigmail_client/domain/enums/attachment_type.dart'; // <<< НОВЫЙ ИМПОРТ

part 'create_attachment_model.freezed.dart';
part 'create_attachment_model.g.dart';

@freezed
class CreateAttachmentModel with _$CreateAttachmentModel {
  @JsonSerializable(explicitToJson: true) // Добавим на всякий случай
  const factory CreateAttachmentModel({
    required String fileKey, // Ключ файла, который вы получили от сервера после загрузки в S3 (или перед прямой загрузкой)
    required String fileName,
    required String contentType,
    required AttachmentType type, // <<< ИЗМЕНЕН ТИП
    required int size, // Размер файла в байтах
    String? thumbnailUrl, // Если клиент может его предоставить или он был сгенерирован перед отправкой
    // int? durationSeconds, // Для аудио/видео, если клиент это определяет
  }) = _CreateAttachmentModel;

  factory CreateAttachmentModel.fromJson(Map<String, dynamic> json) => _$CreateAttachmentModelFromJson(json);
}