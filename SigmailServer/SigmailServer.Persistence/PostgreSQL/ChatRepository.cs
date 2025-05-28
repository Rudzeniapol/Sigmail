using Microsoft.EntityFrameworkCore;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

namespace SigmailServer.Persistence.PostgreSQL;

public class ChatRepository : Repository<Chat>, IChatRepository
{
    public ChatRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task AddMemberAsync(Guid chatId, Guid userId, ChatMemberRole role, CancellationToken cancellationToken = default)
    {
        var chatExists = await _dbSet.AnyAsync(c => c.Id == chatId, cancellationToken);
        if (!chatExists)
        {
            // Обработка случая, когда чат не найден (например, выбросить исключение)
            throw new KeyNotFoundException($"Chat with ID {chatId} not found.");
        }

        var userExists = await _context.Users.AnyAsync(u => u.Id == userId, cancellationToken);
        if (!userExists)
        {
            // Обработка случая, когда пользователь не найден
            throw new KeyNotFoundException($"User with ID {userId} not found.");
        }
        
        var existingMember = await _context.ChatMembers
            .FirstOrDefaultAsync(cm => cm.ChatId == chatId && cm.UserId == userId, cancellationToken);

        if (existingMember == null)
        {
            var member = new ChatMember
            {
                ChatId = chatId,
                UserId = userId,
                Role = role,
                JoinedAt = DateTime.UtcNow
            };
            await _context.ChatMembers.AddAsync(member, cancellationToken);
            // SaveChangesAsync будет вызван через UnitOfWork
        }
        else if (existingMember.Role != role) // Если участник уже есть, но роль другая - обновим роль
        {
            existingMember.Role = role;
            _context.ChatMembers.Update(existingMember);
        }
    }

    public async Task RemoveMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default)
    {
        var member = await _context.ChatMembers
            .FirstOrDefaultAsync(cm => cm.ChatId == chatId && cm.UserId == userId, cancellationToken);

        if (member != null)
        {
            _context.ChatMembers.Remove(member);
            // SaveChangesAsync будет вызван через UnitOfWork
        }
    }

    public async Task UpdateMemberRoleAsync(Guid chatId, Guid userId, ChatMemberRole newRole, CancellationToken cancellationToken = default)
    {
        var member = await _context.ChatMembers
            .FirstOrDefaultAsync(cm => cm.ChatId == chatId && cm.UserId == userId, cancellationToken);

        if (member != null)
        {
            member.Role = newRole;
            _context.ChatMembers.Update(member);
            // SaveChangesAsync будет вызван через UnitOfWork
        }
        else
        {
            // Обработка: участник не найден
            throw new KeyNotFoundException($"Member with User ID {userId} in Chat ID {chatId} not found.");
        }
    }

    public async Task<IEnumerable<User>> GetChatMembersAsync(Guid chatId, CancellationToken cancellationToken = default)
    {
        return await _context.ChatMembers
            .Where(cm => cm.ChatId == chatId)
            .Include(cm => cm.User) // Включаем данные пользователя
            .Select(cm => cm.User)
            .ToListAsync(cancellationToken);
    }
    
    public async Task<ChatMember?> GetChatMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.ChatMembers
            .Include(cm => cm.User) // Опционально, если нужны данные User
            .FirstOrDefaultAsync(cm => cm.ChatId == chatId && cm.UserId == userId, cancellationToken);
    }

    public async Task UpdateLastMessageAsync(Guid chatId, string messageId, CancellationToken cancellationToken = default)
    {
        // messageId - это ObjectId из MongoDB. Мы просто сохраняем его как строку.
        var chat = await GetByIdAsync(chatId, cancellationToken);
        if (chat != null)
        {
            chat.LastMessageId = messageId;
            chat.UpdatedAt = DateTime.UtcNow; // Обновляем время последнего изменения чата
            // _dbSet.Update(chat); // Можно и так
            await UpdateAsync(chat, cancellationToken); // Используем базовый UpdateAsync
        }
    }

    public async Task<bool> IsUserMemberAsync(Guid chatId, Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.ChatMembers.AnyAsync(cm => cm.ChatId == chatId && cm.UserId == userId, cancellationToken);
    }

    public async Task<Chat?> GetPrivateChatByMembersAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default)
    {
        // Ищем личный чат (Type == ChatType.Private)
        // где оба пользователя являются участниками,
        // и количество участников равно 2.
        return await _context.Chats
            .Include(c => c.Members)
            .Where(c => c.Type == ChatType.Private &&
                        c.Members.Count() == 2 && // Убеждаемся, что в чате только два участника
                        c.Members.Any(m => m.UserId == userId1) &&
                        c.Members.Any(m => m.UserId == userId2))
            .FirstOrDefaultAsync(cancellationToken);
    }

    // Переопределяем GetByIdAsync, чтобы включать участников по умолчанию, если это часто нужно
    public override async Task<Chat?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(c => c.Members)
            .ThenInclude(cm => cm.User) // Включить пользователей-участников
            .Include(c => c.Creator)
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }
    
    public async Task<IEnumerable<Chat>> GetUserChatsAsync(
        Guid userId, 
        int page = 1, 
        int pageSize = 20, 
        CancellationToken cancellationToken = default)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;

        return await _context.Chats
            .Include(c => c.Members)
            .Include(c => c.Creator)
            .Where(c => c.Members.Any(m => m.UserId == userId))
            .OrderByDescending(c => c.UpdatedAt) 
            .Skip((page - 1) * pageSize)
            .Take(pageSize)             // Изменено с Limit на Take
            .ToListAsync(cancellationToken);
    }
}