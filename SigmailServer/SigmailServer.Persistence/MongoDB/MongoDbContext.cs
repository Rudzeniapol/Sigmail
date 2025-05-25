using MongoDB.Driver;

namespace SigmailClient.Persistence.MongoDB;

using Microsoft.Extensions.Options;
using MongoDB;
using SigmailClient.Domain.Models; // Убедитесь, что этот using есть

public class MongoDbContext
{
    private readonly IMongoDatabase _database;

    public MongoDbContext(IOptions<MongoDbSettings> settings)
    {
        var client = new MongoClient(settings.Value.ConnectionString);
        _database = client.GetDatabase(settings.Value.DatabaseName);

        // Конвенции для именования и сериализации (опционально, но полезно)
        // BsonClassMap.RegisterClassMap<Message>(cm => { cm.AutoMap(); cm.SetIgnoreExtraElements(true); });
        // BsonClassMap.RegisterClassMap<Notification>(cm => { cm.AutoMap(); cm.SetIgnoreExtraElements(true); });
        // BsonClassMap.RegisterClassMap<Attachment>(cm => { cm.AutoMap(); cm.SetIgnoreExtraElements(true); });
        // Можно также настроить сериализацию Guid как string, если нужно, или использовать стандартную binary.
    }

    // Коллекции для ваших MongoDB сущностей
    public IMongoCollection<Message> Messages => _database.GetCollection<Message>("Messages");
    public IMongoCollection<Notification> Notifications => _database.GetCollection<Notification>("Notifications");
    public IMongoCollection<Attachment> Attachments => _database.GetCollection<Attachment>("Attachments");
}