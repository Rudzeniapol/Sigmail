using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.Services.Interfaces;

public interface IMessageService {
    // SenderId будет браться из контекста аутентифицированного пользователя
    Task<MessageDto?> SendMessageAsync(Guid senderId, CreateMessageDto dto);
    Task<IEnumerable<MessageDto>> GetMessagesAsync(Guid chatId, Guid currentUserId, int page = 1, int pageSize = 20); // Добавлен currentUserId для определения ReadBy и т.д.
    Task<MessageDto?> GetMessageByIdAsync(string id, Guid currentUserId);
    Task EditMessageAsync(string messageId, Guid editorUserId, string newText);
    Task DeleteMessageAsync(string messageId, Guid deleterUserId); // "Мягкое" удаление
    Task MarkMessageAsReadAsync(string messageId, Guid readerUserId, Guid chatId);

    Task<MessageDto?> CreateMessageWithAttachmentAsync(Guid senderId, CreateMessageWithAttachmentDto dto);

    Task MarkMessagesAsDeliveredAsync(IEnumerable<string> messageIds, Guid recipientUserId);
}