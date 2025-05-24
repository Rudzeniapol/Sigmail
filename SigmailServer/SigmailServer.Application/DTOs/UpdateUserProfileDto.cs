namespace SigmailServer.Application.DTOs;

public class UpdateUserProfileDto // DTO для обновления профиля
{
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? Bio { get; set; }
    // Аватар обновляется через отдельный endpoint
}