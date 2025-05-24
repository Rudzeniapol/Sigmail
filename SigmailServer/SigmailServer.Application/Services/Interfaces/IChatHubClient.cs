using SigmailServer.Application.DTOs;
using System;
using System.Threading.Tasks;

namespace SigmailServer.Application.Services.Interfaces // Или где вы храните интерфейсы
{
    /// <summary>
    /// Определяет методы, которые сервер может вызывать на подключенных клиентах SignalR.
    /// Клиентская часть (например, Flutter) должна реализовать эти методы для обработки входящих событий.
    /// </summary>
    public interface IChatHubClient
    {
        // --- События, связанные с сообщениями ---

        /// <summary>
        /// Клиент получил новое сообщение.
        /// </summary>
        /// <param name="message">DTO полученного сообщения.</param>
        Task ReceiveMessage(MessageDto message);

        /// <summary>
        /// Сообщение было отредактировано.
        /// </summary>
        /// <param name="message">DTO отредактированного сообщения с обновленными данными.</param>
        Task MessageEdited(MessageDto message);

        /// <summary>
        /// Сообщение было удалено (логически).
        /// </summary>
        /// <param name="messageId">ID удаленного сообщения.</param>
        /// <param name="chatId">ID чата, к которому принадлежало сообщение.</param>
        Task MessageDeleted(string messageId, Guid chatId);

        /// <summary>
        /// Сообщение было прочитано пользователем.
        /// </summary>
        /// <param name="messageId">ID прочитанного сообщения.</param>
        /// <param name="readerUserId">ID пользователя, который прочитал сообщение.</param>
        /// <param name="chatId">ID чата, к которому принадлежит сообщение.</param>
        Task MessageRead(string messageId, Guid readerUserId, Guid chatId);

        /// <summary>
        /// К сообщению была добавлена реакция.
        /// </summary>
        /// <param name="messageId">ID сообщения.</param>
        /// <param name="reactorUserId">ID пользователя, добавившего реакцию.</param>
        /// <param name="emoji">Строковое представление emoji.</param>
        /// <param name="chatId">ID чата, к которому принадлежит сообщение.</param>
        Task MessageReactionAdded(string messageId, Guid reactorUserId, string emoji, Guid chatId);

        /// <summary>
        /// Реакция была удалена с сообщения.
        /// </summary>
        /// <param name="messageId">ID сообщения.</param>
        /// <param name="reactorUserId">ID пользователя, чья реакция была удалена.</param>
        /// <param name="emoji">Строковое представление emoji.</param>
        /// <param name="chatId">ID чата, к которому принадлежит сообщение.</param>
        Task MessageReactionRemoved(string messageId, Guid reactorUserId, string emoji, Guid chatId);


        // --- События, связанные с пользователями ---

        /// <summary>
        /// Статус пользователя изменился (онлайн/оффлайн).
        /// </summary>
        /// <param name="userId">ID пользователя, чей статус изменился.</param>
        /// <param name="isOnline">True, если пользователь теперь онлайн, иначе false.</param>
        /// <param name="lastSeen">Время последнего онлайна (актуально, если isOnline = false).</param>
        Task UserStatusChanged(Guid userId, bool isOnline, DateTime lastSeen);

        /// <summary>
        /// Пользователь начал печатать в чате.
        /// </summary>
        /// <param name="chatId">ID чата, в котором пользователь печатает.</param>
        /// <param name="userId">ID пользователя, который печатает.</param>
        /// <param name="username">Имя пользователя, который печатает.</param>
        Task UserTypingInChat(Guid chatId, Guid userId, string username);

        /// <summary>
        /// Пользователь перестал печатать в чате.
        /// </summary>
        /// <param name="chatId">ID чата.</param>
        /// <param name="userId">ID пользователя.</param>
        /// <param name="username">Имя пользователя.</param>
        Task UserStoppedTypingInChat(Guid chatId, Guid userId, string username);


        // --- События, связанные с чатами ---

        /// <summary>
        /// Был создан новый чат, и текущий пользователь является его участником.
        /// </summary>
        /// <param name="chat">DTO созданного чата.</param>
        Task ChatCreated(ChatDto chat);

        /// <summary>
        /// Информация о чате была обновлена (например, имя, описание, аватар).
        /// </summary>
        /// <param name="chat">DTO обновленного чата.</param>
        Task ChatDetailsUpdated(ChatDto chat); // Добавлено для полноты

        /// <summary>
        /// Новый участник был добавлен в чат.
        /// </summary>
        /// <param name="chatId">ID чата.</param>
        /// <param name="user">Информация о добавленном участнике.</param>
        /// <param name="addedBy">Информация о пользователе, который добавил участника (опционально).</param>
        Task MemberJoinedChat(Guid chatId, UserSimpleDto user, UserSimpleDto? addedBy = null); // Добавлено

        /// <summary>
        /// Участник покинул чат или был удален.
        /// </summary>
        /// <param name="chatId">ID чата.</param>
        /// <param name="userId">ID участника, который покинул/был удален.</param>
        /// <param name="removedByUserId">ID пользователя, который удалил участника (если применимо).</param>
        Task MemberLeftChat(Guid chatId, Guid userId, Guid? removedByUserId = null); // Добавлено

        /// <summary>
        /// Роль участника в чате была изменена.
        /// </summary>
        /// <param name="chatId">ID чата.</param>
        /// <param name="userId">ID участника.</param>
        /// <param name="newRole">Новая роль участника (например, Admin, Member).</param>
        Task MemberRoleChanged(Guid chatId, Guid userId, string newRole); // Добавлено


        // --- События, связанные с уведомлениями ---

        /// <summary>
        /// Пользователь получил новое персистентное уведомление.
        /// </summary>
        /// <param name="notification">DTO уведомления.</param>
        Task NewNotification(NotificationDto notification);

        /// <summary>
        /// Уведомление было обновлено (например, помечено как прочитанное).
        /// Это может быть полезно для синхронизации UI на разных устройствах.
        /// </summary>
        /// <param name="notification">DTO обновленного уведомления.</param>
        Task NotificationUpdated(NotificationDto notification); // Добавлено


        // --- Общие/Системные события ---

        /// <summary>
        /// На сервере произошла ошибка, связанная с операцией, инициированной клиентом.
        /// </summary>
        /// <param name="errorMessage">Сообщение об ошибке.</param>
        /// <param name="operation">Операция, во время которой произошла ошибка (опционально).</param>
        Task ReceiveError(string errorMessage, string? operation = null);

        /// <summary>
        /// Принудительное отключение клиента сервером (например, из-за невалидного токена или бана).
        /// </summary>
        /// <param name="reason">Причина отключения.</param>
        Task ForceDisconnect(string reason); // Добавлено
    }
}