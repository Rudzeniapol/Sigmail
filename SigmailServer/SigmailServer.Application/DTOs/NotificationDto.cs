using SigmailClient.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class NotificationDto
{
    public string Id { get; set; }
    public Guid UserId { get; set; }
    public NotificationType Type { get; set; }
    public string? Title { get; set; }
    public string Message { get; set; }
    public string? RelatedEntityId { get; set; }
    public string? RelatedEntityType { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}