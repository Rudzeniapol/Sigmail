namespace SigmailServer.Application.DTOs;

using SigmailClient.Domain.Enums; // Для ChatType

public class CreateChatDto {
    public string? Name { get; set; } // Для групп/каналов
    public ChatType Type { get; set; }
    public List<Guid>? MemberIds { get; set; } // ID пользователей для добавления в чат (кроме создателя)
    public string? Description { get; set; }
}