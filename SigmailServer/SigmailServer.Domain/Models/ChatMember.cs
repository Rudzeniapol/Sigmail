﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SigmailServer.Domain.Enums;

// Добавлено

namespace SigmailServer.Domain.Models;

public class ChatMember
{
    // Составной первичный ключ (настраивается в DbContext через HasKey)
    public Guid ChatId { get; set; }
    public Chat Chat { get; set; } = null!;

    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    [Required]
    [Column(TypeName = "varchar(20)")] // Для PostgreSQL
    public ChatMemberRole Role { get; set; } = ChatMemberRole.Member; // Используем enum

    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Навигационные свойства - УДАЛЕНЫ ДУБЛИКАТЫ
    // public virtual Chat Chat { get; set; }
    // public virtual User User { get; set; }
}