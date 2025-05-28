using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Domain.Models;

public class Chat
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [MaxLength(100)]
    public string? Name { get; set; } // Для групп и каналов

    [Required]
    [Column(TypeName = "varchar(20)")] // Для PostgreSQL
    public ChatType Type { get; set; }

    public string? Description { get; set; }
    public string? AvatarUrl { get; set; } // URL или ключ к аватару чата

    [ForeignKey("Creator")]
    public Guid CreatorId { get; set; }
    public User Creator { get; set; } = null!; // EF Core свяжет это навигационное свойство

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow; // Полезно для отслеживания изменений

    // ForeignKey для LastMessage можно сделать опциональным и строковым, если Message.Id - строка
    [ForeignKey("LastMessage")]
    public string? LastMessageId { get; set; } // Изменено на string для ObjectId
    public virtual Message? LastMessage { get; set; } // Помечено virtual

    public virtual ICollection<ChatMember> Members { get; set; } = new List<ChatMember>();
    public virtual ICollection<Message> Messages { get; set; } = new List<Message>(); // Если хотите навигацию от Chat к Message (может быть избыточно, если сообщения в MongoDB)
}