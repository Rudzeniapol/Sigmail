using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Domain.Models;

public class Attachment
{
    [BsonElement("type")]
    [BsonRepresentation(BsonType.String)] // MongoDB хранит как строку, но в коде используем enum
    public AttachmentType Type { get; set; }

    [BsonElement("url")] // Это должен быть ключ файла в S3, а не полный URL, если используете presigned URLs
    public string FileKey { get; set; } = null!; // Переименовано для ясности

    [BsonElement("fileName")] // Исходное имя файла
    public string FileName { get; set; } = null!;

    [BsonElement("contentType")]
    public string ContentType { get; set; } = null!;

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

    [BsonElement("duration")]
    [BsonIgnoreIfNull]
    public TimeSpan? Duration { get; set; } // Для Video/Audio

    [BsonElement("latitude")]
    [BsonIgnoreIfNull]
    public double? Latitude { get; set; }

    [BsonElement("longitude")]
    [BsonIgnoreIfNull]
    public double? Longitude { get; set; }

    [BsonElement("address")]
    [BsonIgnoreIfNull]
    public string? Address { get; set; } // Опционально, текстовый адрес

    [BsonElement("createdAt")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Публичный конструктор без параметров для инициализаторов объектов и EF Core (если бы он использовался)
    public Attachment() { }

    // Конструктор для создания программно (пример)
    public Attachment(AttachmentType type, string fileKey, long size, string fileName, string contentType)
    {
        Type = type;
        FileKey = fileKey;
        Size = size;
        FileName = fileName;
        ContentType = contentType;
        // Id и CreatedAt устанавливаются по умолчанию
    }
}