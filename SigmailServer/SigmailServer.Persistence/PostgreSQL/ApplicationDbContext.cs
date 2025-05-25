using Microsoft.EntityFrameworkCore;
using SigmailClient.Domain.Models;
using SigmailClient.Domain.Enums;

namespace SigmailClient.Persistence.PostgreSQL;

 // Убедитесь, что этот using есть, если ChatMemberRole и другие enum в этом namespace

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<Chat> Chats { get; set; }
    public DbSet<ChatMember> ChatMembers { get; set; }
    public DbSet<Contact> Contacts { get; set; }
    // DbSet для Message, Notification, Attachment здесь не нужны, т.к. они в MongoDB

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Ignore<Attachment>();
        modelBuilder.Ignore<MessageReactionEntry>();
        
        // Конфигурация User
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(u => u.Id);
            entity.HasIndex(u => u.Username).IsUnique();
            entity.HasIndex(u => u.Email).IsUnique();
            entity.Property(u => u.PasswordHash).IsRequired();
            entity.HasIndex(u => u.PhoneNumber).IsUnique();
            // Связи с Chat (как Creator) и ChatMember неявные через навигационные свойства
            // Связи с Contact (как User и ContactUser)
        });

        // Конфигурация Chat
        modelBuilder.Entity<Chat>(entity =>
        {
            entity.HasKey(c => c.Id);
            entity.Property(c => c.Type).HasConversion<string>().HasMaxLength(20); // Сохраняем Enum как строку

            entity.HasOne(c => c.Creator)
                  .WithMany() // У User может быть много созданных чатов, но явного свойства коллекции нет в User
                  .HasForeignKey(c => c.CreatorId)
                  .OnDelete(DeleteBehavior.Restrict); // Или Cascade, если хотите удалять чаты при удалении создателя

            // Связь с LastMessage (Message в MongoDB) здесь не настраиваем.
            // Это будет логическая связь, обрабатываемая в коде приложения/сервиса.
            // EF Core не будет знать о Message из MongoDB.
            entity.Ignore(c => c.LastMessage);
            entity.Ignore(c => c.Messages); // Коллекция Messages также игнорируется
        });

        // Конфигурация ChatMember (связующая таблица многие-ко-многим для Chat и User)
        modelBuilder.Entity<ChatMember>(entity =>
        {
            entity.HasKey(cm => new { cm.ChatId, cm.UserId }); // Составной ключ
            entity.Property(cm => cm.Role).HasConversion<string>().HasMaxLength(20);

            entity.HasOne(cm => cm.Chat)
                  .WithMany(c => c.Members)
                  .HasForeignKey(cm => cm.ChatId)
                  .OnDelete(DeleteBehavior.Cascade); // При удалении чата удаляются и записи участников

            entity.HasOne(cm => cm.User)
                  .WithMany() // У User может быть много членств в чатах, но явного свойства коллекции нет
                  .HasForeignKey(cm => cm.UserId)
                  .OnDelete(DeleteBehavior.Cascade); // При удалении пользователя удаляются и его членства
        });

        // Конфигурация Contact
        modelBuilder.Entity<Contact>(entity =>
        {
            entity.HasKey(c => c.Id);
            entity.Property(c => c.Status).HasConversion<string>().HasMaxLength(20);

            entity.HasOne(c => c.User)
                  .WithMany() // У User может быть много записей Contact, где он UserId
                  .HasForeignKey(c => c.UserId)
                  .OnDelete(DeleteBehavior.Restrict); // Избегаем циклического каскадного удаления

            entity.HasOne(c => c.ContactUser)
                  .WithMany() // У User может быть много записей Contact, где он ContactUserId
                  .HasForeignKey(c => c.ContactUserId)
                  .OnDelete(DeleteBehavior.Restrict);

            // Опционально: уникальный индекс для пары UserId и ContactUserId, чтобы не было дубликатов запросов
            entity.HasIndex(c => new { c.UserId, c.ContactUserId }).IsUnique();
        });
    }
}