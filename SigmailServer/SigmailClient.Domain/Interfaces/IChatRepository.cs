using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IChatRepository : IRepository<Chat>
{
    Task<IEnumerable<Chat>> GetUserChatsAsync(Guid userId, CancellationToken cancellationToken = default);
    Task AddUserToChatAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default);
    Task RemoveUserFromChatAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default);
    Task<IEnumerable<User>> GetChatMembersAsync(Guid chatId, CancellationToken cancellationToken = default);
    Task UpdateLastMessageAsync(Guid chatId, Guid messageId, CancellationToken cancellationToken = default);
}