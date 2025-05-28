using System.ComponentModel.DataAnnotations;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

namespace SigmailServer.Domain.Models;

public class Message : ISoftDeletable // Реализуем интерфейс
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

    [Required]
    [BsonRepresentation(BsonType.String)]
    public Guid ChatId { get; set; }

    [Required]
    [BsonRepresentation(BsonType.String)]
    public Guid SenderId { get; set; }

    [BsonElement("text")]
    [BsonIgnoreIfNull]
    [MaxLength(4096)] // Увеличил лимит
    public string? Text { get; set; }

    [BsonElement("attachments")]
    public List<Attachment> Attachments { get; set; } = new(); // Attachment теперь содержит FileKey

    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [BsonElement("isEdited")]
    public bool IsEdited { get; set; }

    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    [BsonIgnoreIfNull]
    public DateTime? EditedAt { get; set; } // Добавлено

    [BsonElement("forwardedFromMessageId")] // ID оригинального сообщения
    [BsonRepresentation(BsonType.ObjectId)]
    [BsonIgnoreIfNull]
    public string? ForwardedFromMessageId { get; set; }

    [BsonElement("forwardedFromUserId")] // ID пользователя, от которого переслано (если это чужое сообщение)
    [BsonRepresentation(BsonType.String)]
    [BsonIgnoreIfNull]
    public Guid? ForwardedFromUserId { get; set; }


    [BsonElement("status")]
    [BsonRepresentation(BsonType.String)]
    public MessageStatus Status { get; set; } = MessageStatus.Sending; // Изменено на Sending

    [BsonElement("readBy")] // Список Guid пользователей, прочитавших сообщение (для групп)
    public List<Guid> ReadBy { get; set; } = new();

    [BsonElement("deliveredTo")] // Список Guid пользователей, которым доставлено (для групп)
    public List<Guid> DeliveredTo { get; set; } = new();


    [BsonElement("reactions")] // Список реакций
    public List<Reaction> Reactions { get; set; } = new();

    // ISoftDeletable
    [BsonElement("isDeleted")]
    public bool IsDeleted { get; private set; } = false;

    [BsonElement("deletedAt")]
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    [BsonIgnoreIfNull]
    public DateTime? DeletedAt { get; private set; }

    public void MarkAsReadBy(Guid userId) {
        if (!ReadBy.Contains(userId))
        {
            ReadBy.Add(userId);
            // Здесь можно обновить Status, если это личный чат и userId - получатель
        }
    }
    public void MarkAsDeliveredTo(Guid userId)
    {
        if (!DeliveredTo.Contains(userId))
        {
            DeliveredTo.Add(userId);
        }
    }

    public void Edit(string newText) {
        Text = newText;
        IsEdited = true;
        EditedAt = DateTime.UtcNow;
        Status = MessageStatus.Edited;
    }

    public void SoftDelete() {
        IsDeleted = true;
        DeletedAt = DateTime.UtcNow;
        Text = null; // Можно очищать текст при удалении
        Attachments = new(); // и вложения
        Status = MessageStatus.Deleted;
    }
}