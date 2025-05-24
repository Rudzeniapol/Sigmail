using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.Services.Interfaces;

public interface IChatService
{
    Task<ChatDto> CreateChatAsync(Guid creatorId, CreateChatDto dto);
    Task<ChatDto?> GetChatByIdAsync(Guid chatId, Guid currentUserId); 
    Task<IEnumerable<ChatDto>> GetUserChatsAsync(Guid userId, int page = 1, int pageSize = 20);
    Task<ChatDto> UpdateChatDetailsAsync(Guid chatId, Guid currentUserId, UpdateChatDto dto);
    Task<ChatDto> UpdateChatAvatarAsync(Guid chatId, Guid currentUserId, Stream avatarStream, string contentType); // Раскомментировано и добавлено
    Task AddMemberToChatAsync(Guid chatId, Guid currentUserId, Guid userIdToAdd); 
    Task RemoveMemberFromChatAsync(Guid chatId, Guid currentUserId, Guid userIdToRemove);
    Task PromoteMemberToAdminAsync(Guid chatId, Guid currentUserId, Guid userIdToPromote);
    Task DemoteAdminToMemberAsync(Guid chatId, Guid currentUserId, Guid adminUserIdToDemote);
    Task LeaveChatAsync(Guid chatId, Guid currentUserId);
    Task<IEnumerable<UserSimpleDto>> GetChatMembersAsync(Guid chatId); // Сигнатура без currentUserId
    Task<bool> IsUserMemberAsync(Guid chatId, Guid userId); 
    Task DeleteChatAsync(Guid chatId, Guid currentUserId); // Добавлено
}