using Microsoft.Extensions.Logging;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
// Required for ChatMemberRole
using System; // Required for Guid, DateTime
using System.Collections.Generic; // Required for List, IEnumerable
using System.Linq; // Required for Select, Any, ToList
using System.Threading.Tasks;
using SigmailServer.Domain.Enums; // Required for Task
// Пространство имен для хабов изменено на .Services, где они и находятся
// using SigmailServer.Application.Hubs; // Удаляем этот, так как хабы в .Services

namespace SigmailServer.Application.Services;

public class SignalRNotifier : IRealTimeNotifier
{
    private readonly IHubContext<SignalRChatHub, IChatHubClient> _chatHubContext;
    // UserHub должен быть из правильного namespace, компилятор сам найдет, если он в SigmailServer.Application.Services
    private readonly IHubContext<UserHub, IUserHubClient> _userHubContext; 
    private readonly ILogger<SignalRNotifier> _logger;

    public SignalRNotifier(
        IHubContext<SignalRChatHub, IChatHubClient> chatHubContext, 
        IHubContext<UserHub, IUserHubClient> userHubContext, 
        ILogger<SignalRNotifier> logger)
    {
        _chatHubContext = chatHubContext;
        _userHubContext = userHubContext; // <--- Присваиваем UserHub контекст
        _logger = logger;
    }

    private string[] ToSignalRUserList(IEnumerable<Guid> userIds)
    {
        return userIds.Select(id => id.ToString()).Distinct().ToArray();
    }
    private string ToSignalRUser(Guid userId)
    {
        return userId.ToString();
    }

    public async Task NotifyMessageReceivedAsync(Guid recipientUserId, MessageDto message)
    {
        _logger.LogDebug("SignalR: Notifying user {RecipientUserId} about new message {MessageId} in chat {ChatId}", recipientUserId, message.Id, message.ChatId);
        try
        {
            await _chatHubContext.Clients.User(ToSignalRUser(recipientUserId)).ReceiveMessage(message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error notifying user {RecipientUserId} about new message {MessageId}", recipientUserId, message.Id);
        }
    }

    public async Task NotifyMessageEditedAsync(IEnumerable<Guid> chatMemberUserIds, MessageDto message)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about edited message {MessageId} in chat {ChatId}", users.Length, message.Id, message.ChatId);
        await _chatHubContext.Clients.Users(users).MessageEdited(message);
    }

    public async Task NotifyMessageDeletedAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about deleted message {MessageId} in chat {ChatId}", users.Length, messageId, chatId);
        await _chatHubContext.Clients.Users(users).MessageDeleted(messageId, chatId);
    }

    public async Task NotifyMessageReadAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid readerUserId, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about message {MessageId} read by {ReaderUserId} in chat {ChatId}", users.Length, messageId, readerUserId, chatId);
        await _chatHubContext.Clients.Users(users).MessageRead(messageId, readerUserId, chatId);
    }

    public async Task NotifyMessageReactionsUpdatedAsync(string chatId, string messageId, IEnumerable<ReactionDto> reactions)
    {
        _logger.LogDebug("SignalR: Notifying group {ChatId} about reaction update for message {MessageId}. Reaction count: {ReactionCount}", chatId, messageId, reactions.Count());
        try
        {
            await _chatHubContext.Clients.Group(chatId).ReceiveMessageReactionsUpdate(chatId, messageId, reactions);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error notifying group {ChatId} about reaction update for message {MessageId}", chatId, messageId);
        }
    }

    public async Task NotifyUserStatusChangedAsync(IEnumerable<Guid> observerUserIds, Guid userId, bool isOnline, DateTime lastSeen)
    {
        var observers = ToSignalRUserList(observerUserIds);
        if (!observers.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({ObserverCount}) about status change for user {UserId}: Online={IsOnline}", observers.Length, userId, isOnline);
        string userIdString = ToSignalRUser(userId);
        await _userHubContext.Clients.Users(observers).UserStatusChanged(userIdString, isOnline, lastSeen);
    }

    public async Task NotifyChatCreatedAsync(IEnumerable<Guid> memberUserIds, ChatDto chat)
    {
        var members = ToSignalRUserList(memberUserIds);
        if (!members.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({MemberCount}) about new chat {ChatId} ('{ChatName}')", members.Length, chat.Id, chat.Name);
        await _chatHubContext.Clients.Users(members).ChatCreated(chat);
    }
    public async Task NotifyNewNotificationAsync(Guid recipientUserId, NotificationDto notification)
    {
        _logger.LogDebug("SignalR: Notifying user {RecipientUserId} about new notification {NotificationId} (Type: {NotificationType})", recipientUserId, notification.Id, notification.Type);
         try
        {
            await _chatHubContext.Clients.User(ToSignalRUser(recipientUserId)).NewNotification(notification);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error notifying user {RecipientUserId} about new notification {NotificationId}", recipientUserId, notification.Id);
        }
    }
    
    public async Task NotifyMemberLeftChatAsync(List<Guid> memberIds, ChatDto chatDto, Guid leaverUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) 
        {
            _logger.LogInformation("SignalR: No users to notify about member {LeaverUserId} leaving chat {ChatId}", leaverUserId, chatDto.Id);
            return;
        }

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) that member {LeaverUserId} left chat {ChatId} ('{ChatName}')", 
            usersToNotify.Length, leaverUserId, chatDto.Id, chatDto.Name);
        
        await _chatHubContext.Clients.Users(usersToNotify).MemberLeftChat(chatDto.Id, leaverUserId, null); 
    }
    
    public async Task NotifyChatDetailsUpdatedAsync(List<Guid> memberIds, ChatDto updatedChatDto)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about chat {ChatId} details updated.", usersToNotify.Length, updatedChatDto.Id);
        
        if (updatedChatDto.Members != null)
        {
            _logger.LogInformation("SignalR: ChatDetailsUpdated: Sending ChatDto for ChatID {ChatId} with {MemberCount} members. First member if any: {FirstMemberName}", 
                updatedChatDto.Id, 
                updatedChatDto.Members.Count, 
                updatedChatDto.Members.FirstOrDefault()?.Username ?? "N/A");
        }
        else
        {
            _logger.LogWarning("SignalR: ChatDetailsUpdated: Sending ChatDto for ChatID {ChatId} but updatedChatDto.Members is NULL.", updatedChatDto.Id);
        }

        await _chatHubContext.Clients.Users(usersToNotify).ChatDetailsUpdated(updatedChatDto);
    }
    
    public async Task NotifyMemberAddedToChatAsync(List<Guid> memberIds, ChatDto chatDto, UserSimpleDto addedUserDto, Guid addedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about member {AddedUserId} added to chat {ChatId} by {AddedByUserId}.",
            usersToNotify.Length, addedUserDto.Id, chatDto.Id, addedByUserId);
        
        _logger.LogWarning("SignalR: NotifyMemberAddedToChatAsync - addedByUserId {AddedByUserId} cannot be resolved to UserSimpleDto within SignalRNotifier. Passing null for 'addedBy' to client.", addedByUserId);
        await _chatHubContext.Clients.Users(usersToNotify).MemberJoinedChat(chatDto.Id, addedUserDto, null);
    }

    public async Task NotifyMemberRemovedFromChatAsync(List<Guid> memberIds, ChatDto chatDto, Guid removedUserId, Guid removedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about member {RemovedUserId} removed from chat {ChatId} by {RemovedByUserId}.",
            usersToNotify.Length, removedUserId, chatDto.Id, removedByUserId);

        await _chatHubContext.Clients.Users(usersToNotify).MemberLeftChat(chatDto.Id, removedUserId, removedByUserId);
    }

    public async Task NotifyChatMemberRoleChangedAsync(List<Guid> memberIds, ChatDto chatDto, Guid targetUserId, ChatMemberRole newRole, Guid changedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about role change for member {TargetUserId} to {NewRole} in chat {ChatId} by {ChangedByUserId}.", 
            usersToNotify.Length, targetUserId, newRole, chatDto.Id, changedByUserId);
        
        _logger.LogWarning("SignalR: NotifyChatMemberRoleChangedAsync - changedByUserId {ChangedByUserId} is not passed to the client as IChatHubClient.MemberRoleChanged does not support it.", changedByUserId);
        await _chatHubContext.Clients.Users(usersToNotify).MemberRoleChanged(chatDto.Id, targetUserId, newRole.ToString());
    }

    public async Task NotifyChatDeletedAsync(List<Guid> memberIds, Guid chatId, Guid deletedByUserId)
    {
        _logger.LogInformation("SignalR: Notifying {Count} members about deletion of chat {ChatId} by user {DeletedByUserId}", memberIds.Count, chatId, deletedByUserId);
        try
        {
            await _chatHubContext.Clients.Users(ToSignalRUserList(memberIds)).ReceiveChatDeleted(chatId, deletedByUserId);
        }
        catch(Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error notifying about chat deletion {ChatId}", chatId);
        }
    }

    public async Task NotifyUserAvatarUpdatedAsync(IEnumerable<Guid> observerUserIds, Guid changedUserId, string newAvatarUrl)
    {
        _logger.LogInformation("SignalR: Notifying {ObserverCount} observers about avatar update for user {ChangedUserId}", observerUserIds.Count(), changedUserId);
        try
        {
            await _userHubContext.Clients.Users(ToSignalRUserList(observerUserIds)).ReceiveUserAvatarUpdate(changedUserId.ToString(), newAvatarUrl);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error notifying observers about avatar update for user {ChangedUserId}", changedUserId);
        }
    }
}