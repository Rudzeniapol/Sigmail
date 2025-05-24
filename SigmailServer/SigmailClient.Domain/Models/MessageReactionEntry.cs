using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace SigmailClient.Domain.Models;

public class MessageReactionEntry
{
    [BsonRepresentation(BsonType.String)]
    public Guid UserId { get; set; }
    public string Emoji { get; set; } // Например, "👍", "❤️"
    [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
    public DateTime ReactedAt { get; set; } = DateTime.UtcNow;
}