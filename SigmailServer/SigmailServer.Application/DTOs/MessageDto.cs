using SigmailClient.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class MessageDto {
    public string Id { get; set; }
    public Guid ChatId { get; set; }
    public Guid SenderId { get; set; }
    public UserSimpleDto? Sender { get; set; } // Информация об отправителе
    public string? Text { get; set; }
    public List<AttachmentDto> Attachments { get; set; } = new();
    public DateTime Timestamp { get; set; }
    public bool IsEdited { get; set; }
    public DateTime? EditedAt { get; set; }
    public string? ForwardedFromMessageId { get; set; }
    public Guid? ForwardedFromUserId { get; set; }
    public MessageStatus Status { get; set; }
    public List<Guid> ReadBy { get; set; } = new();
    public List<MessageReactionDto> Reactions { get; set; } = new();
}