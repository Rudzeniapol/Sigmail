using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.Services.Interfaces;

public interface INotificationService
{
    Task<IEnumerable<NotificationDto>> GetUserNotificationsAsync(Guid userId, bool unreadOnly = false, int page = 1, int pageSize = 20);
    Task MarkNotificationAsReadAsync(string notificationId, Guid userId);
    Task MarkAllUserNotificationsAsReadAsync(Guid userId);
    Task CreateAndSendNotificationAsync( // Внутренний метод для создания и отправки через IRealTimeNotifier
        Guid recipientUserId,
        NotificationType type,
        string message,
        string? title = null,
        string? relatedEntityId = null,
        string? relatedEntityType = null);
    Task DeleteNotificationAsync(string notificationId, Guid userId);
}