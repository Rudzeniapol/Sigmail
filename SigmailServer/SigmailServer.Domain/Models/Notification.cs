using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using SigmailClient.Domain.Enums;

namespace SigmailClient.Domain.Models;

public class Notification
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

    [BsonRepresentation(BsonType.String)]
    public Guid UserId { get; set; } // Кому уведомление

    [BsonElement("type")]
    [BsonRepresentation(BsonType.String)]
    public NotificationType Type { get; set; }

    [BsonElement("title")] // Добавлено для лучшего отображения
    public string? Title { get; set; }

    [BsonElement("message")]
    public string Message { get; set; } // Текст уведомления

    [BsonElement("relatedEntityId")] // Может быть ChatId (Guid) или MessageId (string)
    public string? RelatedEntityId { get; set; } // Сделаем строкой для универсальности

    [BsonElement("relatedEntityType")] // Чтобы знать, к чему относится RelatedEntityId
    public string? RelatedEntityType { get; set; } // "Chat", "Message"

    [BsonElement("isRead")]
    public bool IsRead { get; set; }

    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}