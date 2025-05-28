using System;
using System.Threading.Tasks;

namespace SigmailServer.Application.Services.Interfaces
{
    /// <summary>
    /// Определяет методы, которые сервер может вызывать на клиентах, подключенных к UserHub.
    /// </summary>
    public interface IUserHubClient
    {
        /// <summary>
        /// Аватар пользователя был обновлен.
        /// </summary>
        /// <param name="userId">ID пользователя (string), чей аватар обновился.</param>
        /// <param name="newAvatarUrl">Новый URL аватара (может быть null или пустым, если аватар удален).</param>
        Task ReceiveUserAvatarUpdate(string userId, string? newAvatarUrl);

        /// <summary>
        /// Статус пользователя изменился (онлайн/оффлайн).
        /// </summary>
        /// <param name="userId">ID пользователя (string), чей статус изменился.</param>
        /// <param name="isOnline">True, если пользователь теперь онлайн, иначе false.</param>
        /// <param name="lastSeen">Время последнего онлайна (актуально, если isOnline = false).</param>
        Task UserStatusChanged(string userId, bool isOnline, DateTime lastSeen);
        // Другие методы, специфичные для UserHub, могут быть добавлены здесь
    }
} 