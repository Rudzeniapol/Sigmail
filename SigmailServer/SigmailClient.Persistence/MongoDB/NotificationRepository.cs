using MongoDB.Bson;
using MongoDB.Driver;

namespace SigmailClient.Persistence.MongoDB;

using MongoDB;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

public class NotificationRepository : INotificationRepository
{
    private readonly MongoDbContext _mongoDbContext;

    public NotificationRepository(MongoDbContext mongoDbContext)
    {
        _mongoDbContext = mongoDbContext ?? throw new ArgumentNullException(nameof(mongoDbContext));
    }

    public async Task<Notification?> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(id, out _)) return null;
        return await _mongoDbContext.Notifications.Find(n => n.Id == id).FirstOrDefaultAsync(cancellationToken);
    }

    public async Task AddAsync(Notification notification, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(notification.Id) || !ObjectId.TryParse(notification.Id, out _))
        {
            notification.Id = ObjectId.GenerateNewId().ToString();
        }
        await _mongoDbContext.Notifications.InsertOneAsync(notification, cancellationToken: cancellationToken);
    }

    public async Task MarkAsReadAsync(string id, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(id, out _)) throw new ArgumentException("Invalid notification ID format.", nameof(id));

        var filter = Builders<Notification>.Filter.Eq(n => n.Id, id);
        var update = Builders<Notification>.Update.Set(n => n.IsRead, true);
        
        await _mongoDbContext.Notifications.UpdateOneAsync(filter, update, cancellationToken: cancellationToken);
    }

    public async Task DeleteOldNotificationsAsync(DateTime cutoffDate, CancellationToken cancellationToken = default)
    {
        // Удаляет старые прочитанные уведомления (или все старые, если IsRead не учитывать)
        var filter = Builders<Notification>.Filter.Lt(n => n.CreatedAt, cutoffDate) &
                     Builders<Notification>.Filter.Eq(n => n.IsRead, true); // Опционально: только прочитанные
        
        await _mongoDbContext.Notifications.DeleteManyAsync(filter, cancellationToken);
    }
    
    public async Task<IEnumerable<Notification>> GetForUserAsync(
        Guid userId, 
        bool unreadOnly = false, 
        int page = 1, // Добавлен параметр
        int pageSize = 20, // Добавлен параметр
        CancellationToken cancellationToken = default)
    {
        var filterBuilder = Builders<Notification>.Filter;
        var filter = filterBuilder.Eq(n => n.UserId, userId);

        if (unreadOnly)
        {
            filter &= filterBuilder.Eq(n => n.IsRead, false);
        }

        // Применяем пагинацию
        // Убедимся, что page и pageSize корректны
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20; // или другое значение по умолчанию

        return await _mongoDbContext.Notifications
            .Find(filter)
            .SortByDescending(n => n.CreatedAt)
            .Skip((page - 1) * pageSize) // Добавлено
            .Limit(pageSize)             // Добавлено
            .ToListAsync(cancellationToken);
    }
}