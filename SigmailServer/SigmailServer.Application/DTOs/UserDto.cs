namespace SigmailServer.Application.DTOs;

public class UserDto { // Полная информация о пользователе
    public Guid Id { get; set; }
    public string Username { get; set; }
    public string Email { get; set; } // Может быть скрыто для не-контактов
    public string? ProfileImageUrl { get; set; }
    public string? Bio { get; set; }
    public bool IsOnline { get; set; }
    public DateTime? LastSeen { get; set; }
}