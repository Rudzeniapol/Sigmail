using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging; // Для [Authorize]
using SigmailServer.Application.Services.Interfaces; // Для IRealTimeUserNotifier (если будем использовать)
using System;

namespace SigmailServer.Application.Services // Используем то же пространство имен, что и SignalRChatHub
{
    [Authorize] // Требуем авторизацию для доступа к этому хабу
    public class UserHub : Hub<IUserHubClient>
    {
        private readonly ILogger<UserHub> _logger;
        private readonly IUserService _userService;

        // Пример использования IRealTimeUserNotifier, если он будет отвечать за логику оповещений
        // private readonly IRealTimeUserNotifier _userNotifier;

        public UserHub(ILogger<UserHub> logger, IUserService userService /*, IRealTimeUserNotifier userNotifier */)
        {
            _logger = logger;
            _userService = userService;
            // _userNotifier = userNotifier;
        }

        public override async Task OnConnectedAsync()
        {
            var userIdString = Context.UserIdentifier;
            if (!string.IsNullOrEmpty(userIdString) && Guid.TryParse(userIdString, out Guid userId))
            {
                _logger.LogInformation($"User {userId} connected to UserHub. ConnectionId: {Context.ConnectionId}");
                await _userService.UpdateOnlineStatusAsync(userId, true, Context.ConnectionId);
                await Groups.AddToGroupAsync(Context.ConnectionId, userIdString); // Добавляем в группу с ID пользователя
            }
            else
            {
                _logger.LogWarning("UserHub: Connection without valid UserIdentifier or failed Guid.TryParse. ConnectionId: {ConnectionId}", Context.ConnectionId);
            }
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userIdString = Context.UserIdentifier;
            if (!string.IsNullOrEmpty(userIdString) && Guid.TryParse(userIdString, out Guid userId))
            {
                if (exception != null)
                {
                    _logger.LogWarning($"User {userId} disconnected from UserHub with error: {exception.Message}. ConnectionId: {Context.ConnectionId}");
                }
                else
                {
                    _logger.LogInformation($"User {userId} disconnected from UserHub. ConnectionId: {Context.ConnectionId}");
                }
                await _userService.UpdateOnlineStatusAsync(userId, false);
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, userIdString);
            }
            else
            {
                _logger.LogWarning("UserHub: Disconnection without valid UserIdentifier or failed Guid.TryParse. ConnectionId: {ConnectionId}. Exception: {ExceptionMessage}", 
                    Context.ConnectionId, exception?.Message);
            }
            await base.OnDisconnectedAsync(exception);
        }

        // Клиент UserRealtimeDataSourceImpl ожидает метод 'UserStatusChanged' и 'ReceiveUserAvatarUpdate'
        // Сервер должен ИНИЦИИРОВАТЬ эти вызовы клиентам, когда происходят соответствующие события.
        // Эти методы НЕ вызываются клиентом. Клиент просто слушает их.

        // Пример того, как сервер мог бы отправить обновление статуса (этот метод НЕ вызывается клиентом):
        // Этот метод должен вызываться из ваших сервисов, когда меняется статус пользователя или его аватар.
        // public async Task BroadcastUserStatusUpdate(string userId, bool isOnline, DateTime lastSeen)
        // {
        //     await Clients.All.SendAsync("UserStatusChanged", userId, isOnline, lastSeen);
        // }

        // public async Task BroadcastAvatarUpdate(string userId, string newAvatarUrl)
        // {
        //     await Clients.All.SendAsync("ReceiveUserAvatarUpdate", userId, newAvatarUrl);
        // }
    }
} 