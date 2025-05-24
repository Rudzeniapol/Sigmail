using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IChatRepository : IRepository<Chat> // Chat использует Guid ID, так что это ок
{
    Task<IEnumerable<Chat>> GetUserChatsAsync(Guid userId, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    Task AddMemberAsync(Guid chatId, Guid userId, ChatMemberRole role, CancellationToken cancellationToken = default); // Добавлен role
    Task RemoveMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default);
    Task UpdateMemberRoleAsync(Guid chatId, Guid userId, ChatMemberRole newRole, CancellationToken cancellationToken = default); // Новый
    Task<IEnumerable<User>> GetChatMembersAsync(Guid chatId, CancellationToken cancellationToken = default);
    Task<ChatMember?> GetChatMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default); // Новый
    Task UpdateLastMessageAsync(Guid chatId, string messageId, CancellationToken cancellationToken = default); // messageId теперь string
    Task<bool> IsUserMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default);
    Task<Chat?> GetPrivateChatByMembersAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default); // Для поиска существующего личного чата
}