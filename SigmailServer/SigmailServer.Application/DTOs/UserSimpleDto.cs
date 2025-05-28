namespace SigmailServer.Application.DTOs;

public class UserSimpleDto { // Для вложенных объектов, как отправитель сообщения
    public Guid Id { get; set; }
    public string Username { get; set; } = null!;
    public string? ProfileImageUrl { get; set; }
}