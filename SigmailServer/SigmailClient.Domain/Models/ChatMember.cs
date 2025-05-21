namespace SigmailClient.Domain.Models;

public class ChatMember
{
    public Guid ChatId { get; set; }
    public Guid UserId { get; set; }
    public string Role { get; set; } = "member";
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    public Chat Chat { get; set; }
    public User User { get; set; }
}