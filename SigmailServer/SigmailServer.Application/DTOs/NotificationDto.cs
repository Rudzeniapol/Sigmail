using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class NotificationDto
{
    public string Id { get; set; } = null!;
    public Guid UserId { get; set; }
    public NotificationType Type { get; set; }
    public string? Title { get; set; }
    public string Message { get; set; } = null!;
    public string? RelatedEntityId { get; set; }
    public string? RelatedEntityType { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}