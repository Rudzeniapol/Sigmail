using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IMessageRepository // Не наследует IRepository<Message> из-за string ID
{
    Task<Message?> GetByIdAsync(string id, CancellationToken cancellationToken = default);
    Task<IEnumerable<Message>> GetByChatAsync(Guid chatId, int page, int pageSize, CancellationToken cancellationToken = default);
    Task AddAsync(Message message, CancellationToken cancellationToken = default);
    Task UpdateAsync(Message message, CancellationToken cancellationToken = default); // Для общего обновления
    Task DeleteAsync(string id, CancellationToken cancellationToken = default); // Логическое удаление (вызов SoftDelete)
    Task<long> GetCountForChatAsync(Guid chatId, CancellationToken cancellationToken = default);

    // Новые методы для статусов и реакций
    Task AddReactionAsync(string messageId, Guid userId, string emoji, CancellationToken cancellationToken = default);
    Task RemoveReactionAsync(string messageId, Guid userId, string emoji, CancellationToken cancellationToken = default);
    Task MarkMessageAsReadByAsync(string messageId, Guid userId, CancellationToken cancellationToken = default);
    Task MarkMessagesAsDeliveredToAsync(IEnumerable<string> messageIds, Guid userId, CancellationToken cancellationToken = default);
    Task DeleteMessagesByChatIdAsync(Guid chatId, CancellationToken cancellationToken = default);
    Task<long> GetUnreadMessageCountForUserInChatAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default);
    Task<Message?> GetByAttachmentKeyAsync(string fileKey, CancellationToken cancellationToken = default);
}