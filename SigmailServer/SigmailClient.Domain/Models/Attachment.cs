using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using SigmailClient.Domain.Enums;

namespace SigmailClient.Domain.Models;

public class Attachment
{
    [BsonElement("type")]
    [BsonRepresentation(BsonType.String)] // MongoDB хранит как строку, но в коде используем enum
    public AttachmentType Type { get; set; }

    [BsonElement("url")] // Это должен быть ключ файла в S3, а не полный URL, если используете presigned URLs
    public string FileKey { get; set; } // Переименовано для ясности

    [BsonElement("fileName")] // Исходное имя файла
    public string FileName { get; set; }

    [BsonElement("contentType")]
    public string ContentType { get; set; }

    [BsonElement("thumbnailKey")]
    [BsonIgnoreIfNull]
    public string? ThumbnailKey { get; set; } // Тоже ключ

    [BsonElement("size")]
    public long Size { get; set; }

    [BsonElement("width")]
    [BsonIgnoreIfNull]
    public int? Width { get; set; }

    [BsonElement("height")]
    [BsonIgnoreIfNull]
    public int? Height { get; set; }
}