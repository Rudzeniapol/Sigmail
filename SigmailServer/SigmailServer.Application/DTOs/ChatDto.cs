using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class ChatDto {
    public Guid Id { get; set; }
    public string? Name { get; set; }
    public ChatType Type { get; set; }
    public string? Description { get; set; }
    public string? AvatarUrl { get; set; }
    public Guid CreatorId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public MessageDto? LastMessage { get; set; } // Последнее сообщение в чате
    public int UnreadCount { get; set; } // Количество непрочитанных сообщений для текущего пользователя
    public List<UserSimpleDto> Members { get; set; } = new(); // Краткая информация о членах
    public int MemberCount { get; set; }
}