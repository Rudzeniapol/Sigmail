using Microsoft.EntityFrameworkCore;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

namespace SigmailServer.Persistence.PostgreSQL;

public class ContactRepository : Repository<Contact>, IContactRepository
{
    public ContactRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<Contact?> GetContactRequestAsync(Guid userId, Guid contactUserId, CancellationToken cancellationToken = default)
    {
        // Ищет любой запрос между двумя пользователями, независимо от статуса.
        // Например, чтобы проверить, существует ли уже запрос.
        return await _dbSet
            .FirstOrDefaultAsync(c =>
                (c.UserId == userId && c.ContactUserId == contactUserId) ||
                (c.UserId == contactUserId && c.ContactUserId == userId), // Проверяем в обе стороны, если запрос мог быть инициирован другим пользователем
            cancellationToken);
    }
    
    public async Task<IEnumerable<Contact>> GetUserContactsAsync(Guid userId, ContactRequestStatus? status = ContactRequestStatus.Accepted, CancellationToken cancellationToken = default)
    {
        var query = _dbSet
            .Include(c => c.User) // Пользователь, который инициировал/принял запрос
            .Include(c => c.ContactUser) // Пользователь, которому был отправлен/от которого пришел запрос
            .Where(c => (c.UserId == userId || c.ContactUserId == userId));

        if (status.HasValue)
        {
            query = query.Where(c => c.Status == status.Value);
        }

        return await query.ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Contact>> GetPendingContactRequestsForUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        // Запросы, где текущий пользователь является ContactUserId (получателем запроса) и статус Pending
        return await _dbSet
            .Include(c => c.User) // Кто отправил запрос
            .Where(c => c.ContactUserId == userId && c.Status == ContactRequestStatus.Pending)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> AreUsersContactsAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default)
    {
        return await _dbSet.AnyAsync(c =>
            ((c.UserId == userId1 && c.ContactUserId == userId2) || (c.UserId == userId2 && c.ContactUserId == userId1))
            && c.Status == ContactRequestStatus.Accepted,
            cancellationToken);
    }

    // Опционально: можно добавить метод для получения конкретного контакта по Id с включением пользователей
    public override async Task<Contact?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(c => c.User)
            .Include(c => c.ContactUser)
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }
}