using Microsoft.EntityFrameworkCore;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SigmailClient.Persistence.PostgreSQL;

public class UserRepository : Repository<User>, IUserRepository
{
    public UserRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<User?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FirstOrDefaultAsync(u => u.Username == username, cancellationToken);
    }

    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    }

    public async Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(phone))
            return null;
            
        return await _dbSet.FirstOrDefaultAsync(u => u.PhoneNumber == phone, cancellationToken);
    }

    public async Task<bool> ExistsAsync(string username, string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet.AnyAsync(u => u.Username == username || u.Email == email, cancellationToken);
    }

    public async Task UpdateLastLoginAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await GetByIdAsync(userId, cancellationToken);
        if (user != null)
        {
            user.UpdateLastSeen(); // Предполагается, что этот метод обновляет и LastLogin или аналогичное поле
            // _context.Users.Update(user); // Можно и так, если Repository.UpdateAsync не подходит
            await UpdateAsync(user, cancellationToken); // Используем базовый UpdateAsync
        }
    }

    public async Task<User?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        // Убедитесь, что RefreshToken не пустой и не null
        if (string.IsNullOrWhiteSpace(refreshToken))
            return null;

        return await _dbSet.FirstOrDefaultAsync(u => u.RefreshToken == refreshToken && u.RefreshTokenExpiryTime > DateTime.UtcNow, cancellationToken);
    }

    public async Task<IEnumerable<User>> FindUsersAsync(string searchTerm, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            return Enumerable.Empty<User>();
        }

        var lowerSearchTerm = searchTerm.ToLower();
        return await _dbSet
            .Where(u => u.Username.ToLower().Contains(lowerSearchTerm) || 
                        u.Email.ToLower().Contains(lowerSearchTerm) ||
                        (u.PhoneNumber != null && u.PhoneNumber.Contains(searchTerm)))
            .ToListAsync(cancellationToken);
    }
    
    public async Task<IEnumerable<User>> GetManyByIdsAsync(IEnumerable<Guid> ids, CancellationToken cancellationToken = default)
    {
        if (ids == null || !ids.Any())
        {
            return Enumerable.Empty<User>();
        }
        // Используем EF.Functions.Contains для оптимизированного запроса (если ваш провайдер это поддерживает)
        // Для простоты и универсальности используем .Where(u => ids.Contains(u.Id))
        // Это может быть не так эффективно для очень больших списков ids на некоторых БД.
        return await _dbSet.Where(u => ids.Contains(u.Id)).ToListAsync(cancellationToken);
    }
}