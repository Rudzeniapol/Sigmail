using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IUserRepository : IRepository<User> // User использует Guid ID, так что это ок
{
    Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default);
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default); // Если будет поиск по телефону
    Task<bool> ExistsAsync(string username, string email, CancellationToken cancellationToken = default); // Можно проверять и email
    Task UpdateLastLoginAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<User?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default); // Новый
    Task<IEnumerable<User>> FindUsersAsync(string searchTerm, CancellationToken cancellationToken = default); // Новый, для поиска контактов
    Task<IEnumerable<User>> GetManyByIdsAsync(IEnumerable<Guid> ids, CancellationToken cancellationToken = default);
}