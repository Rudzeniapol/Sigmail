namespace SigmailClient.Domain.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IUserRepository Users { get; }
    IChatRepository Chats { get; }
    IMessageRepository Messages { get; } // Уже есть
    INotificationRepository Notifications { get; } // Уже есть
    IFileStorageRepository Files { get; } // Уже есть

    IContactRepository Contacts { get; } // НОВЫЙ

    Task<int> CommitAsync(CancellationToken cancellationToken = default); // Для PostgreSQL части
    Task RollbackAsync(); // Для PostgreSQL части

    // Для MongoDB репозиториев сохранение может происходить внутри их методов,
    // либо можно добавить специфичные методы SaveChanges для MongoDB, если это необходимо.
    // Например: Task<bool> CommitMongoDbChangesAsync(CancellationToken cancellationToken = default);
}