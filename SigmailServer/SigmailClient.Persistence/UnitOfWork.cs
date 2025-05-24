using SigmailClient.Persistence.PostgreSQL;
using SigmailClient.Domain.Interfaces;
using System.Threading.Tasks;
using System;
using System.Threading;

namespace SigmailClient.Persistence;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _dbContext; // Только для PostgreSQL части UoW

    // PostgreSQL репозитории
    public IUserRepository Users { get; }
    public IChatRepository Chats { get; }
    public IContactRepository Contacts { get; }

    // MongoDB репозитории
    public IMessageRepository Messages { get; }
    public INotificationRepository Notifications { get; }
    // AttachmentRepository нам не нужен как отдельное свойство, т.к. Attachment - часть Message

    // S3 репозиторий
    public IFileStorageRepository Files { get; }

    private bool _disposed;

    public UnitOfWork(
        ApplicationDbContext dbContext, // EF Core DbContext
        IUserRepository userRepository,
        IChatRepository chatRepository,
        IContactRepository contactRepository,
        IMessageRepository messageRepository,
        INotificationRepository notificationRepository,
        IFileStorageRepository fileStorageRepository)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));

        // Инициализация PostgreSQL репозиториев
        Users = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        Chats = chatRepository ?? throw new ArgumentNullException(nameof(chatRepository));
        Contacts = contactRepository ?? throw new ArgumentNullException(nameof(contactRepository));

        // Инициализация MongoDB репозиториев
        Messages = messageRepository ?? throw new ArgumentNullException(nameof(messageRepository));
        Notifications = notificationRepository ?? throw new ArgumentNullException(nameof(notificationRepository));

        // Инициализация File Storage репозитория
        Files = fileStorageRepository ?? throw new ArgumentNullException(nameof(fileStorageRepository));
    }

    public async Task<int> CommitAsync(CancellationToken cancellationToken = default)
    {
        // Сохранение изменений для PostgreSQL (EF Core)
        // Для MongoDB и S3 операции сохранения обычно происходят немедленно в методах репозитория.
        return await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task RollbackAsync()
    {
        // EF Core автоматически откатывает транзакцию, если SaveChangesAsync не был вызван,
        // или если SaveChangesAsync выбросил исключение, и DbContext утилизируется.
        // Явный Rollback может быть полезен, если вы управляете транзакциями вручную (BeginTransaction).
        // В простом случае, если вы не начинали транзакцию явно, этот метод может ничего не делать
        // или можно очистить отслеживаемые изменения:
        // _dbContext.ChangeTracker.Clear(); // Это не откатит уже сохраненные данные, а очистит трекер.
        return Task.CompletedTask;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void Dispose(bool disposing)
    {
        if (!_disposed)
        {
            if (disposing)
            {
                // Освобождаем управляемые ресурсы (например, DbContext для EF Core)
                _dbContext.Dispose();
            }
            // Освобождаем неуправляемые ресурсы, если есть
            _disposed = true;
        }
    }
}