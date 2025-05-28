using System.ComponentModel.DataAnnotations;

namespace SigmailServer.Application.DTOs;

public class ReactionDto
{
    [Required]
    public string Emoji { get; set; } = null!;

    [Required]
    public List<Guid> UserIds { get; set; } = new();

    // Можно также добавить количество, если это удобно для клиента
    public int Count => UserIds.Count;

    // Даты FirstReactedAt и LastReactedAt, вероятно, не нужны в DTO для клиента,
    // но можно добавить, если потребуется.
    // public DateTime FirstReactedAt { get; set; }
    // public DateTime LastReactedAt { get; set; }
} 