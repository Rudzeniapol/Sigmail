using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces; // Для IUserService, IMessageService, IChatService
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

// Интерфейс, определяющий методы, которые сервер может вызвать на клиенте
// (Предполагается, что он у вас уже есть и корректен)
// public interface IChatHubClient { ... }

namespace SigmailServer.Application.Services;

[Authorize]
public class SignalRChatHub : Hub<IChatHubClient>
{
    private readonly ILogger<SignalRChatHub> _logger;
    private readonly IUserService _userService;
    private readonly IMessageService _messageService;
    private readonly IChatService _chatService;

    // Потокобезопасное хранилище для сопоставления UserId (string) с HashSet<string> из ConnectionIds
    private static readonly ConcurrentDictionary<string, HashSet<string>> UserConnectionsMap = new ConcurrentDictionary<string, HashSet<string>>();

    public SignalRChatHub(
        ILogger<SignalRChatHub> logger,
        IUserService userService,
        IMessageService messageService,
        IChatService chatService) // Инжектируем все необходимые сервисы
    {
        _logger = logger;
        _userService = userService;
        _messageService = messageService;
        _chatService = chatService;
    }

    public override async Task OnConnectedAsync()
    {
        var userIdString = Context.UserIdentifier; // Получаем UserId из клеймов JWT (обычно ClaimTypes.NameIdentifier)

        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
        {
            _logger.LogWarning("SignalR: Connection attempt from unauthenticated or invalid user. ConnectionId: {ConnectionId}", Context.ConnectionId);
            Context.Abort(); // Разрываем соединение, если пользователь не аутентифицирован корректно
            return;
        }

        // Добавляем ConnectionId в набор соединений для данного UserId
        var connections = UserConnectionsMap.GetOrAdd(userIdString, _ => new HashSet<string>());
        lock (connections) // HashSet не потокобезопасен для записи
        {
            connections.Add(Context.ConnectionId);
        }

        _logger.LogInformation("SignalR: Client connected. UserId: {UserId}, ConnectionId: {ConnectionId}. Total connections for user: {Count}",
            userIdString, Context.ConnectionId, connections.Count);

        try
        {
            // Обновляем статус пользователя на "онлайн"
            await _userService.UpdateOnlineStatusAsync(userId, true, Context.ConnectionId);
            // Получаем актуальные данные пользователя после обновления статуса
            UserDto? updatedUser = await _userService.GetByIdAsync(userId);

            if (updatedUser != null)
            {
                // Отправляем всем клиентам (или только друзьям/контактам, если есть такая логика)
                // Используем существующий метод UserStatusChanged из IChatHubClient
                await Clients.All.UserStatusChanged(updatedUser.Id, updatedUser.IsOnline, updatedUser.LastSeen ?? DateTime.UtcNow); 
                _logger.LogInformation("SignalR: Sent UserStatusChanged for UserId: {UserId} (Online: true)", userIdString);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SignalR: Error updating user {UserId} status to online and notifying clients.", userIdString);
        }

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userIdString = Context.UserIdentifier;
        UserDto? userToNotify = null; // Для хранения DTO пользователя, чей статус изменился

        if (!string.IsNullOrEmpty(userIdString) && Guid.TryParse(userIdString, out Guid userId))
        {
            if (UserConnectionsMap.TryGetValue(userIdString, out HashSet<string>? connections))
            {
                bool removeUserFromMap = false;
                lock (connections) // HashSet не потокобезопасен
                {
                    connections.Remove(Context.ConnectionId);
                    if (connections.Count == 0)
                    {
                        removeUserFromMap = true;
                    }
                }

                if (removeUserFromMap)
                {
                    UserConnectionsMap.TryRemove(userIdString, out _); // Удаляем пользователя из словаря, если у него больше нет активных соединений
                    _logger.LogInformation("SignalR: User {UserId} has no more active connections. Setting status to offline.", userIdString);
                    try
                    {
                        // Обновляем статус на "офлайн"
                        await _userService.UpdateOnlineStatusAsync(userId, false);
                        // Получаем актуальные данные пользователя после обновления статуса
                        userToNotify = await _userService.GetByIdAsync(userId);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "SignalR: Error updating user {UserId} status to offline.", userIdString);
                    }
                }
            }
            _logger.LogInformation("SignalR: Client disconnected. UserId: {UserId}, ConnectionId: {ConnectionId}. Exception: {ExceptionMessage}",
                userIdString, Context.ConnectionId, exception?.Message ?? "N/A");
        }
        else
        {
            _logger.LogInformation("SignalR: Unidentified client disconnected. ConnectionId: {ConnectionId}. Exception: {ExceptionMessage}",
                Context.ConnectionId, exception?.Message ?? "N/A");
        }

        await base.OnDisconnectedAsync(exception);

        // Отправляем уведомление после вызова base.OnDisconnectedAsync, если статус пользователя изменился на офлайн
        if (userToNotify != null)
        {
             try
            {
                // Используем существующий метод UserStatusChanged из IChatHubClient
                await Clients.All.UserStatusChanged(userToNotify.Id, userToNotify.IsOnline, userToNotify.LastSeen ?? DateTime.UtcNow); 
                _logger.LogInformation("SignalR: Sent UserStatusChanged for UserId: {UserId} (Online: false)", userIdString);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SignalR: Error notifying clients about user {UserId} status offline.", userIdString);
            }
        }
    }

    // --- Методы, вызываемые клиентом на сервере ---

    public async Task MarkMessageAsReadOnServer(string messageId, Guid chatId)
    {
        var userIdString = Context.UserIdentifier;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userGuid))
        {
            _logger.LogWarning("MarkMessageAsReadOnServer: Unauthenticated user or invalid UserId. ConnectionId: {ConnectionId}", Context.ConnectionId);
            // await Clients.Caller.ReceiveError("Authentication required to mark message as read."); // Пример отправки ошибки клиенту
            return;
        }

        _logger.LogInformation("SignalR: User {UserId} reports reading message {MessageId} in chat {ChatId} via Hub.", userGuid, messageId, chatId);

        try
        {
            await _messageService.MarkMessageAsReadAsync(messageId, userGuid, chatId);
        }
        catch (KeyNotFoundException knfEx)
        {
            _logger.LogWarning(knfEx, "MarkMessageAsReadOnServer: Resource not found for user {UserId}, message {MessageId}.", userGuid, messageId);
            // await Clients.Caller.ReceiveError($"Failed to mark message as read: {knfEx.Message}");
        }
        catch (UnauthorizedAccessException uaEx)
        {
            _logger.LogWarning(uaEx, "MarkMessageAsReadOnServer: Unauthorized access for user {UserId}, message {MessageId}.", userGuid, messageId);
            // await Clients.Caller.ReceiveError($"Failed to mark message as read: {uaEx.Message}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "MarkMessageAsReadOnServer: Error for user {UserId}, message {MessageId}.", userGuid, messageId);
            // await Clients.Caller.ReceiveError("An unexpected error occurred while marking message as read.");
        }
    }

    public async Task UserIsTyping(Guid chatId)
    {
        var userIdString = Context.UserIdentifier;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid typerUserId))
        {
            _logger.LogWarning("UserIsTyping: Unauthenticated user or invalid UserId. ConnectionId: {ConnectionId}", Context.ConnectionId);
            return;
        }

        try
        {
            var members = await _chatService.GetChatMembersAsync(chatId);
            var typerInfo = await _userService.GetByIdAsync(typerUserId); // Получаем информацию о печатающем

            if (typerInfo == null)
            {
                _logger.LogWarning("UserIsTyping: Typer user {UserId} not found.", typerUserId);
                return;
            }

            var otherMemberIds = members
                .Where(m => m.Id != typerUserId) // Уведомляем всех, КРОМЕ самого печатающего
                .Select(m => m.Id.ToString())
                .ToList();

            if (otherMemberIds.Any())
            {
                _logger.LogDebug("SignalR: User {TyperUsername} ({TyperUserId}) is typing in chat {ChatId}. Notifying {Count} members.",
                    typerInfo.Username, typerUserId, chatId, otherMemberIds.Count);

                // Предполагаем, что в IChatHubClient есть метод:
                // Task UserTypingInChat(Guid chatId, Guid userId, string username);
                await Clients.Users(otherMemberIds).UserTypingInChat(chatId, typerUserId, typerInfo.Username);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "UserIsTyping: Error processing typing event for user {UserId} in chat {ChatId}.", typerUserId, chatId);
        }
    }

    public async Task UserStoppedTyping(Guid chatId)
    {
        var userIdString = Context.UserIdentifier;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid typerUserId))
        {
            _logger.LogWarning("UserStoppedTyping: Unauthenticated user or invalid UserId. ConnectionId: {ConnectionId}", Context.ConnectionId);
            return;
        }

        try
        {
            var members = await _chatService.GetChatMembersAsync(chatId);
            var typerInfo = await _userService.GetByIdAsync(typerUserId);

             if (typerInfo == null)
            {
                _logger.LogWarning("UserStoppedTyping: Typer user {UserId} not found.", typerUserId);
                return;
            }


            var otherMemberIds = members
                .Where(m => m.Id != typerUserId)
                .Select(m => m.Id.ToString())
                .ToList();

            if (otherMemberIds.Any())
            {
                 _logger.LogDebug("SignalR: User {TyperUsername} ({TyperUserId}) stopped typing in chat {ChatId}. Notifying {Count} members.",
                    typerInfo.Username, typerUserId, chatId, otherMemberIds.Count);
                // Предполагаем, что в IChatHubClient есть метод:
                // Task UserStoppedTypingInChat(Guid chatId, Guid userId, string username);
                await Clients.Users(otherMemberIds).UserStoppedTypingInChat(chatId, typerUserId, typerInfo.Username);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "UserStoppedTyping: Error processing stopped typing event for user {UserId} in chat {ChatId}.", typerUserId, chatId);
        }
    }

    // Можно добавить метод для присоединения к "группам" SignalR, соответствующим чатам.
    // Это альтернатива отправке через Clients.Users(...) и может быть эффективнее для частых обновлений в чате.
    public async Task JoinChatGroup(string chatId)
    {
        // Проверка прав пользователя на доступ к этому чату (через _chatService.IsUserMemberAsync)
        var userIdString = Context.UserIdentifier;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userGuid) || !Guid.TryParse(chatId, out Guid chatGuid))
        {
             _logger.LogWarning("JoinChatGroup: Invalid parameters. UserId: {UserId}, ChatId: {ChatId}", userIdString, chatId);
            return;
        }

        bool isMember = await _chatService.IsUserMemberAsync(chatGuid, userGuid); // Предполагается, что IsUserMemberAsync существует в IChatService
        if (isMember)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
            _logger.LogInformation("SignalR: User {UserId} (Connection: {ConnectionId}) joined SignalR group for chat {ChatId}", userGuid, Context.ConnectionId, chatId);
        }
        else
        {
            _logger.LogWarning("SignalR: User {UserId} attempted to join group for chat {ChatId} but is not a member.", userGuid, chatId);
        }
    }

    public async Task LeaveChatGroup(string chatId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, chatId);
        _logger.LogInformation("SignalR: Connection {ConnectionId} left SignalR group for chat {ChatId}", Context.ConnectionId, chatId);
    }

    // Важно: если вы используете Groups.AddToGroupAsync, то при отправке уведомлений в чат,
    // вместо Clients.Users(memberIds).<Method>(...) можно использовать Clients.Group(chatId.ToString()).<Method>(...)
    // Это может быть проще и эффективнее. Но требует от клиента вызова JoinChatGroup при открытии чата.
}