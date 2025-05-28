using Microsoft.EntityFrameworkCore;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;
using SigmailServer.Persistence.PostgreSQL; // ИЗМЕНЕНО: правильный using для DbContext
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging; // ДОБАВЛЕНО

namespace SigmailServer.Persistence.Repositories;

// УБРАНО: наследование от GenericRepository, так как его нет
public class ContactRepository : IContactRepository 
{
    private readonly ApplicationDbContext _context; // ИЗМЕНЕНО: AppDbContext -> ApplicationDbContext
    private readonly ILogger<ContactRepository> _logger; // Добавлено поле логгера

    public ContactRepository(ApplicationDbContext context, ILogger<ContactRepository> logger)
    {
        _context = context;
        _logger = logger; // Инициализация логгера
    }

    // Методы из IContactRepository
    public async Task<IEnumerable<Contact>> GetContactsByUserIdAsync(Guid userId) // Этот метод уже был, немного переименован для соответствия
    {
        return await _context.Contacts
            .Where(c => c.UserId == userId)
            .Include(c => c.ContactUser) // Предполагается, что есть навигационное свойство ContactUser
            .ToListAsync();
    }

    public async Task<Contact?> GetContactByUserAndContactIdAsync(Guid userId, Guid contactUserId) // Этот метод уже был
    {
        return await _context.Contacts
            .FirstOrDefaultAsync(c => c.UserId == userId && c.ContactUserId == contactUserId);
    }

    public async Task<Contact?> GetContactRequestAsync(Guid userId, Guid contactUserId, CancellationToken cancellationToken = default)
    {
        return await _context.Contacts
            .FirstOrDefaultAsync(c => 
                (c.UserId == userId && c.ContactUserId == contactUserId) || 
                (c.UserId == contactUserId && c.ContactUserId == userId), 
                cancellationToken);
    }

    public async Task<IEnumerable<Contact>> GetUserContactsAsync(Guid userId, ContactRequestStatus? status = ContactRequestStatus.Accepted, CancellationToken cancellationToken = default)
    {
        var query = _context.Contacts
            .Where(c => (c.UserId == userId || c.ContactUserId == userId));

        if (status.HasValue)
        {
            query = query.Where(c => c.Status == status.Value);
        }
        
        // Чтобы получить "друга", а не запись контакта для самого себя
        return await query
            .Include(c => c.User) // Пользователь, который создал запись контакта
            .Include(c => c.ContactUser) // Пользователь, который является контактом
            .Where(c => (c.UserId == userId && c.ContactUser != null) || (c.ContactUserId == userId && c.User != null) )
            .ToListAsync(cancellationToken);
    }
    
    public async Task<IEnumerable<Contact>> GetPendingContactRequestsForUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        // Запросы, где текущий пользователь является ContactUserId и статус PendingApproval
        return await _context.Contacts
            .Where(c => c.ContactUserId == userId && c.Status == ContactRequestStatus.Pending)
            .Include(c => c.User) // Тот, кто отправил запрос
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> AreUsersContactsAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default)
    {
        return await _context.Contacts
            .AnyAsync(c => 
                ((c.UserId == userId1 && c.ContactUserId == userId2) || (c.UserId == userId2 && c.ContactUserId == userId1)) 
                && c.Status == ContactRequestStatus.Accepted, 
                cancellationToken);
    }

    // Методы из IRepository<Contact>
    public Task<Contact?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("GetByIdAsync called on ContactRepository with Guid id, which is not directly supported due to composite key. Returning null.");
        return Task.FromResult<Contact?>(null);
    }

    public async Task<IEnumerable<Contact>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Contacts
            .Include(c => c.User)
            .Include(c => c.ContactUser)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Contact entity, CancellationToken cancellationToken = default)
    {
        await _context.Contacts.AddAsync(entity, cancellationToken);
        // Для сущностей с автогенерируемым ключом SaveChangesAsync обычно вызывается в UnitOfWork.
        // Если ключ не автогенерируемый (как у Contact - составной), то он должен быть установлен до AddAsync.
    }

    public Task UpdateAsync(Contact entity, CancellationToken cancellationToken = default)
    {
        _context.Contacts.Update(entity);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("DeleteAsync called on ContactRepository with Guid id, which is not directly supported due to composite key. Operation skipped.");
        return Task.CompletedTask;
    }
} 