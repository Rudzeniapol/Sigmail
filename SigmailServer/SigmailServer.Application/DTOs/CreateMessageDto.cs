namespace SigmailServer.Application.DTOs;

public class CreateMessageDto {
    public Guid ChatId { get; set; }
    // SenderId будет браться из аутентифицированного пользователя на сервере
    public string? Text { get; set; }
    public List<CreateAttachmentDto>? Attachments { get; set; } // DTO для создания вложения
    public string? ForwardedFromMessageId { get; set; } // Для пересылки
    public string? ClientMessageId { get; set; } // Опционально: ID, сгенерированный клиентом для отслеживания
}