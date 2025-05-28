using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.Services.Interfaces;

public interface IRealTimeNotifier {
    Task NotifyMessageReceivedAsync(Guid recipientUserId, MessageDto message);
    Task NotifyMessageEditedAsync(IEnumerable<Guid> chatMemberUserIds, MessageDto message);
    Task NotifyMessageDeletedAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid chatId);
    Task NotifyMessageReadAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid readerUserId, Guid chatId);
    Task NotifyMessageReactionsUpdatedAsync(string chatId, string messageId, IEnumerable<ReactionDto> reactions);
    Task NotifyUserStatusChangedAsync(IEnumerable<Guid> observerUserIds, Guid userId, bool isOnline, DateTime lastSeen);
    Task NotifyChatCreatedAsync(IEnumerable<Guid> memberUserIds, ChatDto chat);
    Task NotifyNewNotificationAsync(Guid recipientUserId, NotificationDto notification);
    Task NotifyMemberLeftChatAsync(List<Guid> memberIds, ChatDto chatDto, Guid leaverUserId);
    Task NotifyChatDetailsUpdatedAsync(List<Guid> memberIds, ChatDto updatedChatDto);
    Task NotifyMemberAddedToChatAsync(List<Guid> memberIds, ChatDto chatDto, UserSimpleDto addedUserDto, Guid addedByUserId);
    Task NotifyMemberRemovedFromChatAsync(List<Guid> memberIds, ChatDto chatDto, Guid removedUserId, Guid removedByUserId);
    Task NotifyChatMemberRoleChangedAsync(List<Guid> memberIds, ChatDto chatDto, Guid targetUserId, ChatMemberRole newRole, Guid changedByUserId);
    Task NotifyChatDeletedAsync(List<Guid> memberIds, Guid chatId, Guid deletedByUserId);
    Task NotifyUserAvatarUpdatedAsync(IEnumerable<Guid> observerUserIds, Guid changedUserId, string newAvatarUrl);
}