namespace SigmailServer.Application.DTOs;

public class MessageReactionDto // Для отображения в MessageDto
{
    public Guid UserId { get; set; }
    public string Emoji { get; set; }
    public DateTime ReactedAt { get; set; }
}