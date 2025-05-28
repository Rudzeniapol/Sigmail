using SigmailServer.Domain.Models;

namespace SigmailServer.Domain.Interfaces;

public interface INotificationRepository
{
    Task<Notification?> GetByIdAsync(string id, CancellationToken cancellationToken = default);
    // Измененный метод с пагинацией
    Task<IEnumerable<Notification>> GetForUserAsync(Guid userId, bool unreadOnly = false, int page = 1, int pageSize = 20, CancellationToken cancellationToken = default);
    Task AddAsync(Notification notification, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(string id, CancellationToken cancellationToken = default);
    Task DeleteOldNotificationsAsync(DateTime cutoffDate, CancellationToken cancellationToken = default);
}