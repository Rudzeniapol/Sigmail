using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace SigmailServer.Domain.Models;

public class Reaction
{
    [BsonElement("emoji")]
    public string Emoji { get; set; } = null!;

    [BsonElement("userIds")]
    [BsonRepresentation(BsonType.String)] // Предполагая, что User.Id это Guid, и мы храним его как строку Guid
    public List<Guid> UserIds { get; set; } = new();

    [BsonElement("firstReactedAt")]
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime FirstReactedAt { get; set; } = DateTime.UtcNow;

    [BsonElement("lastReactedAt")]
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime LastReactedAt { get; set; } = DateTime.UtcNow;

    // Приватный конструктор для MongoDB/десериализации
    private Reaction() {}

    public Reaction(string emoji, Guid userId)
    {
        Emoji = emoji;
        UserIds.Add(userId);
        FirstReactedAt = DateTime.UtcNow;
        LastReactedAt = DateTime.UtcNow;
    }
} 