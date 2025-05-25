using Microsoft.EntityFrameworkCore;
using SigmailClient.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace SigmailClient.Persistence.PostgreSQL;

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly ApplicationDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
        _dbSet = _context.Set<T>();
    }

    public virtual async Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id }, cancellationToken);
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.ToListAsync(cancellationToken);
    }

    public virtual async Task AddAsync(T entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
    }

    public virtual Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
    {
        // В EF Core достаточно изменить состояние сущности, если она уже отслеживается,
        // или присоединить и изменить состояние, если не отслеживается.
        // _context.Entry(entity).State = EntityState.Modified; // Можно так
        _dbSet.Update(entity); // Или так, EF Core сам разберется
        return Task.CompletedTask; // Update сам по себе не асинхронный в EF до SaveChangesAsync
    }

    public virtual async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity != null)
        {
            _dbSet.Remove(entity);
        }
        // Если сущность не найдена, можно выбросить исключение или просто ничего не делать,
        // в зависимости от требований.
    }
}