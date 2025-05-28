using SigmailServer.Domain.Models;

// Используем правильный namespace для User

namespace SigmailServer.Domain.Interfaces; // Правильный namespace для интерфейса

public interface IUserRepository : IRepository<User>
{
    Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default);
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default); // Опционально, если используется
    Task<User?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default);

    Task<IEnumerable<User>> FindUsersAsync(string searchTerm, int limit, CancellationToken cancellationToken = default); // Для поиска пользователей
    Task<IEnumerable<User>> GetManyByIdsAsync(IEnumerable<Guid> ids, CancellationToken cancellationToken = default);

    Task<bool> IsEmailTakenAsync(string email, Guid? excludeUserId = null, CancellationToken cancellationToken = default);
    Task<bool> IsUsernameTakenAsync(string username, Guid? excludeUserId = null, CancellationToken cancellationToken = default);
    
    Task UpdateLastLoginAsync(Guid userId, CancellationToken cancellationToken = default); // Если отслеживается последний вход
}