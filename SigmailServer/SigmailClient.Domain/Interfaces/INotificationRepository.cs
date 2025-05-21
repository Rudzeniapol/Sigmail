using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface INotificationRepository : IRepository<Notification>
{
    Task<IEnumerable<Notification>> GetUnreadForUserAsync(Guid userId);
    Task MarkAllAsReadAsync(Guid userId);
    Task DeleteOldNotificationsAsync(DateTime cutoffDate);
}