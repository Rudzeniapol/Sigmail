using MongoDB.Bson;
using MongoDB.Driver;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

// Добавлено для полноты, хотя для CountDocumentsAsync с лямбдой обычно достаточно MongoDB.Driver
// Стандартный LINQ

namespace SigmailServer.Persistence.MongoDB;

public class MessageRepository : IMessageRepository
{
    private readonly IMongoCollection<Message> _messagesCollection; // Изменил имя для ясности

    public MessageRepository(MongoDbContext mongoDbContext)
    {
        if (mongoDbContext == null) throw new ArgumentNullException(nameof(mongoDbContext));
        _messagesCollection = mongoDbContext.Messages; // Прямое присвоение коллекции
    }

    public async Task<Message?> GetByIdAsync(string id, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(id, out var objectId)) return null;
        // Явно создаем фильтр
        var filter = Builders<Message>.Filter.Eq(m => m.Id, objectId.ToString()) & Builders<Message>.Filter.Eq(m => m.IsDeleted, false);
        return await _messagesCollection.Find(filter).FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IEnumerable<Message>> GetByChatAsync(Guid chatId, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Message>.Filter.Eq(m => m.ChatId, chatId) & Builders<Message>.Filter.Eq(m => m.IsDeleted, false);
        return await _messagesCollection
            .Find(filter)
            .SortByDescending(m => m.Timestamp)
            .Skip((page - 1) * pageSize)
            .Limit(pageSize)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Message message, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(message.Id) || !ObjectId.TryParse(message.Id, out _))
        {
            message.Id = ObjectId.GenerateNewId().ToString();
        }
        await _messagesCollection.InsertOneAsync(message, cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(Message message, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(message.Id, out _)) throw new ArgumentException("Invalid message ID format.", nameof(message.Id));
        var filter = Builders<Message>.Filter.Eq(m => m.Id, message.Id);
        var result = await _messagesCollection.ReplaceOneAsync(filter, message, cancellationToken: cancellationToken);
        // Можно добавить проверку result.ModifiedCount
    }

    public async Task DeleteAsync(string id, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(id, out var objectId)) return; // Если ID невалидный, ничего не делаем

        var filter = Builders<Message>.Filter.Eq(m => m.Id, objectId.ToString());
        var update = Builders<Message>.Update
            .Set(m => m.IsDeleted, true)
            .Set(m => m.DeletedAt, DateTime.UtcNow)
            .Set(m => m.Text, null) // Очищаем текст, как в SoftDelete
            .Set(m => m.Attachments, new List<Attachment>()); // Очищаем вложения

        // Вместо извлечения и вызова SoftDelete, делаем атомарный update
        await _messagesCollection.UpdateOneAsync(filter, update, cancellationToken: cancellationToken);
    }

    public async Task<long> GetCountForChatAsync(Guid chatId, CancellationToken cancellationToken = default)
    {
        // Попробуем явно типизировать фильтр, если лямбда вызывает проблемы
        var filter = Builders<Message>.Filter.And(
            Builders<Message>.Filter.Eq(m => m.ChatId, chatId),
            Builders<Message>.Filter.Eq(m => m.IsDeleted, false)
        );
        return await _messagesCollection.CountDocumentsAsync(filter, cancellationToken: cancellationToken);
        // Предыдущий вариант: return await _messagesCollection.CountDocumentsAsync(m => m.ChatId == chatId && !m.IsDeleted, cancellationToken);
    }

    public async Task MarkMessageAsReadByAsync(string messageId, Guid userId, CancellationToken cancellationToken = default)
    {
        if (!ObjectId.TryParse(messageId, out _)) throw new ArgumentException("Invalid message ID format.", nameof(messageId));

        var filter = Builders<Message>.Filter.Eq(m => m.Id, messageId);
        var update = Builders<Message>.Update.AddToSet(m => m.ReadBy, userId);
        
        await _messagesCollection.UpdateOneAsync(filter, update, cancellationToken: cancellationToken);
    }

    public async Task MarkMessagesAsDeliveredToAsync(IEnumerable<string> messageIds, Guid userId, CancellationToken cancellationToken = default)
    {
        var validObjectIds = messageIds.Where(id => ObjectId.TryParse(id, out _)).Select(ObjectId.Parse).Select(o => o.ToString()).ToList();
        if (!validObjectIds.Any()) return;

        var filter = Builders<Message>.Filter.In(m => m.Id, validObjectIds);
        var update = Builders<Message>.Update.AddToSet(m => m.DeliveredTo, userId);
        
        await _messagesCollection.UpdateManyAsync(filter, update, cancellationToken: cancellationToken);
    }
    
    public async Task DeleteMessagesByChatIdAsync(Guid chatId, CancellationToken cancellationToken = default)
    {
        // Физическое удаление сообщений или логическое, если SoftDelete предпочтительнее
        // Для примера - физическое удаление
        var filter = Builders<Message>.Filter.Eq(m => m.ChatId, chatId);
        await _messagesCollection.DeleteManyAsync(filter, cancellationToken);
    }
    
    public async Task<long> GetUnreadMessageCountForUserInChatAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default)
    {
        var filter = Builders<Message>.Filter.And(
            Builders<Message>.Filter.Eq(m => m.ChatId, chatId),
            Builders<Message>.Filter.Eq(m => m.IsDeleted, false),
            Builders<Message>.Filter.Not(Builders<Message>.Filter.AnyEq(m => m.ReadBy, userId)) // Сообщения, где userId НЕ в списке ReadBy
        );
        // Используем перегрузку CountDocumentsAsync(FilterDefinition<Message>, CountOptions, CancellationToken)
        // Передаем null для CountOptions, если специальные опции не нужны.
        return await _messagesCollection.CountDocumentsAsync(filter, options: null, cancellationToken: cancellationToken);
    }
    
    public async Task<Message?> GetByAttachmentKeyAsync(string fileKey, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(fileKey))
        {
            return null;
        }

        // Фильтр для поиска сообщения, у которого в списке Attachments есть элемент с указанным FileKey
        // и сообщение не удалено логически.
        var filter = Builders<Message>.Filter.And(
            Builders<Message>.Filter.ElemMatch(m => m.Attachments, Builders<Attachment>.Filter.Eq(a => a.FileKey, fileKey)),
            Builders<Message>.Filter.Eq(m => m.IsDeleted, false) 
        );
        
        return await _messagesCollection.Find(filter).FirstOrDefaultAsync(cancellationToken);
    }
}