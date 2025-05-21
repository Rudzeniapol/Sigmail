using SigmailClient.Domain.Enums;

namespace SigmailClient.Domain.Models;

public class Chat
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string? Name { get; set; }
    public ChatType Type { get; set; }
    public string? Description { get; set; }
    public Guid? CreatorId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid? LastMessageId { get; set; }
    public User Creator { get; set; }
    public ICollection<ChatMember> Members { get; set; }
    public ICollection<MessageMetadata> Messages { get; set; }
}