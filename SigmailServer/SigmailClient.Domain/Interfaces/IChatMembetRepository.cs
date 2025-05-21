using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IChatMemberRepository : IRepository<ChatMember>
{
    Task<bool> IsUserInChatAsync(Guid userId, Guid chatId);
    Task UpdateRoleAsync(Guid chatId, Guid userId, string role);
    Task<int> GetChatMembersCountAsync(Guid chatId);
}