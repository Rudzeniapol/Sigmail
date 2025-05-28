using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class MessageDto {
    public string Id { get; set; } = null!;
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
    public List<Guid> ReadBy { get; set; } = new(); // Оставляем для информации, кто именно прочитал
    public bool IsRead { get; set; } // Прочитано ли ТЕКУЩИМ пользователем
    public List<ReactionDto> Reactions { get; set; } = new();
}