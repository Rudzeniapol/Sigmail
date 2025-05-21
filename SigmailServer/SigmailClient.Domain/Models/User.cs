namespace SigmailClient.Domain.Models;

public class User
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Username { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? LastLogin { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsOnline { get; set; }
    public ICollection<ChatMember> ChatMemberships { get; set; }
    public ICollection<MessageMetadata> Messages { get; set; }
    public ICollection<Notification> Notifications { get; set; }
}