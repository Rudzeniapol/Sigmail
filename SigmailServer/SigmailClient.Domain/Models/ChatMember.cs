using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SigmailClient.Domain.Enums; // Добавлено

namespace SigmailClient.Domain.Models;

public class ChatMember
{
    // Составной первичный ключ (настраивается в DbContext через HasKey)
    public Guid ChatId { get; set; }
    public Guid UserId { get; set; }

    [Required]
    [Column(TypeName = "varchar(20)")] // Для PostgreSQL
    public ChatMemberRole Role { get; set; } = ChatMemberRole.Member; // Используем enum

    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Навигационные свойства
    public virtual Chat Chat { get; set; }
    public virtual User User { get; set; }
}