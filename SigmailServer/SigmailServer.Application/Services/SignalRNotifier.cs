using Microsoft.Extensions.Logging;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
using SigmailClient.Domain.Enums; // Required for ChatMemberRole
using System; // Required for Guid, DateTime
using System.Collections.Generic; // Required for List, IEnumerable
using System.Linq; // Required for Select, Any, ToList
using System.Threading.Tasks; // Required for Task

namespace SigmailServer.Application.Services;

public class SignalRNotifier : IRealTimeNotifier
{
    private readonly IHubContext<SignalRChatHub, IChatHubClient> _hubContext;
    private readonly ILogger<SignalRNotifier> _logger;

    public SignalRNotifier(IHubContext<SignalRChatHub, IChatHubClient> hubContext, ILogger<SignalRNotifier> logger)
    {
        _hubContext = hubContext;
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
            await _hubContext.Clients.User(ToSignalRUser(recipientUserId)).ReceiveMessage(message);
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
        await _hubContext.Clients.Users(users).MessageEdited(message);
    }

    public async Task NotifyMessageDeletedAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about deleted message {MessageId} in chat {ChatId}", users.Length, messageId, chatId);
        await _hubContext.Clients.Users(users).MessageDeleted(messageId, chatId);
    }

    public async Task NotifyMessageReadAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid readerUserId, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about message {MessageId} read by {ReaderUserId} in chat {ChatId}", users.Length, messageId, readerUserId, chatId);
        await _hubContext.Clients.Users(users).MessageRead(messageId, readerUserId, chatId);
    }

    public async Task NotifyMessageReactionAddedAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid reactorUserId, string emoji, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about reaction added to message {MessageId} by {ReactorUserId} in chat {ChatId}", users.Length, messageId, reactorUserId, chatId);
        await _hubContext.Clients.Users(users).MessageReactionAdded(messageId, reactorUserId, emoji, chatId);
    }

    public async Task NotifyMessageReactionRemovedAsync(IEnumerable<Guid> chatMemberUserIds, string messageId, Guid reactorUserId, string emoji, Guid chatId)
    {
        var users = ToSignalRUserList(chatMemberUserIds);
        if (!users.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({UserCount}) about reaction removed from message {MessageId} by {ReactorUserId} in chat {ChatId}", users.Length, messageId, reactorUserId, chatId);
        await _hubContext.Clients.Users(users).MessageReactionRemoved(messageId, reactorUserId, emoji, chatId);
    }

    public async Task NotifyUserStatusChangedAsync(IEnumerable<Guid> observerUserIds, Guid userId, bool isOnline, DateTime lastSeen)
    {
        var observers = ToSignalRUserList(observerUserIds);
        if (!observers.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({ObserverCount}) about status change for user {UserId}: Online={IsOnline}", observers.Length, userId, isOnline);
        await _hubContext.Clients.Users(observers).UserStatusChanged(userId, isOnline, lastSeen);
    }

    public async Task NotifyChatCreatedAsync(IEnumerable<Guid> memberUserIds, ChatDto chat)
    {
        var members = ToSignalRUserList(memberUserIds);
        if (!members.Any()) return;
        _logger.LogDebug("SignalR: Notifying users ({MemberCount}) about new chat {ChatId} ('{ChatName}')", members.Length, chat.Id, chat.Name);
        await _hubContext.Clients.Users(members).ChatCreated(chat);
    }
    public async Task NotifyNewNotificationAsync(Guid recipientUserId, NotificationDto notification)
    {
        _logger.LogDebug("SignalR: Notifying user {RecipientUserId} about new notification {NotificationId} (Type: {NotificationType})", recipientUserId, notification.Id, notification.Type);
         try
        {
            await _hubContext.Clients.User(ToSignalRUser(recipientUserId)).NewNotification(notification);
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
        
        // IChatHubClient.MemberLeftChat(Guid chatId, Guid userId, Guid? removedByUserId = null)
        // Здесь removedByUserId не передается, так как метод NotifyMemberLeftChatAsync его не имеет.
        // Это корректно для сценария "пользователь сам вышел".
        await _hubContext.Clients.Users(usersToNotify).MemberLeftChat(chatDto.Id, leaverUserId, null); 
    }
    
    public async Task NotifyChatDetailsUpdatedAsync(List<Guid> memberIds, ChatDto updatedChatDto)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about chat {ChatId} details updated.", usersToNotify.Length, updatedChatDto.Id);
        await _hubContext.Clients.Users(usersToNotify).ChatDetailsUpdated(updatedChatDto);
    }
    
    public async Task NotifyMemberAddedToChatAsync(List<Guid> memberIds, ChatDto chatDto, UserSimpleDto addedUserDto, Guid addedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about member {AddedUserId} added to chat {ChatId} by {AddedByUserId}.",
            usersToNotify.Length, addedUserDto.Id, chatDto.Id, addedByUserId);
        
        // IChatHubClient.MemberJoinedChat(Guid chatId, UserSimpleDto user, UserSimpleDto? addedBy = null);
        // `addedByUserId` (Guid) не может быть напрямую преобразован в `UserSimpleDto` здесь без доступа к сервису пользователей.
        // В идеале, ChatService должен передавать UserSimpleDto для addedByUserId.
        // Пока передаем null для addedBy.
        _logger.LogWarning("SignalR: NotifyMemberAddedToChatAsync - addedByUserId {AddedByUserId} cannot be resolved to UserSimpleDto within SignalRNotifier. Passing null for 'addedBy' to client.", addedByUserId);
        await _hubContext.Clients.Users(usersToNotify).MemberJoinedChat(chatDto.Id, addedUserDto, null);
    }

    public async Task NotifyMemberRemovedFromChatAsync(List<Guid> memberIds, ChatDto chatDto, Guid removedUserId, Guid removedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about member {RemovedUserId} removed from chat {ChatId} by {RemovedByUserId}.",
            usersToNotify.Length, removedUserId, chatDto.Id, removedByUserId);

        // IChatHubClient.MemberLeftChat(Guid chatId, Guid userId, Guid? removedByUserId = null);
        // Этот метод клиента используется и для "покинул" и для "был удален".
        await _hubContext.Clients.Users(usersToNotify).MemberLeftChat(chatDto.Id, removedUserId, removedByUserId);
    }

    public async Task NotifyChatMemberRoleChangedAsync(List<Guid> memberIds, ChatDto chatDto, Guid targetUserId, ChatMemberRole newRole, Guid changedByUserId)
    {
        var usersToNotify = ToSignalRUserList(memberIds);
        if (!usersToNotify.Any()) return;

        _logger.LogInformation("SignalR: Notifying users ({UserCount}) about role change for member {TargetUserId} to {NewRole} in chat {ChatId} by {ChangedByUserId}.", 
            usersToNotify.Length, targetUserId, newRole, chatDto.Id, changedByUserId);

        // IChatHubClient.MemberRoleChanged(Guid chatId, Guid userId, string newRole);
        // Клиентский метод не принимает changedByUserId.
        _logger.LogWarning("SignalR: NotifyChatMemberRoleChangedAsync - changedByUserId {ChangedByUserId} is not passed to the client as IChatHubClient.MemberRoleChanged does not support it.", changedByUserId);
        await _hubContext.Clients.Users(usersToNotify).MemberRoleChanged(chatDto.Id, targetUserId, newRole.ToString());
    }

    public async Task NotifyChatDeletedAsync(List<Guid> memberIds, Guid chatId, Guid deletedByUserId)
    {
        // IChatHubClient.cs не содержит метода для ChatDeleted.
        // Поэтому мы не можем отправить это уведомление клиентам через SignalR с текущим интерфейсом клиента.
        _logger.LogWarning("SignalR: NotifyChatDeletedAsync called for chat {ChatId}, but IChatHubClient does not have a corresponding method (e.g., ChatDeleted). Notification will not be sent to clients via SignalR.", chatId);
        
        // Если бы метод существовал в IChatHubClient, например: Task ChatDeleted(Guid chatId, Guid deletedByUserId);
        // var usersToNotify = ToSignalRUserList(memberIds);
        // if (!usersToNotify.Any()) return;
        // _logger.LogInformation("SignalR: Notifying users ({UserCount}) about deletion of chat {ChatId} by {DeletedByUserId}.",
        // usersToNotify.Length, chatId, deletedByUserId);
        // await _hubContext.Clients.Users(usersToNotify).ChatDeleted(chatId, deletedByUserId);
        await Task.CompletedTask; // Заглушка остается, так как нет клиентского метода
    }
}