namespace SigmailServer.Application.DTOs;

public class UpdateChatDto
{
    public string? Name { get; set; }
    public string? Description { get; set; }
    // public string? AvatarUrl { get; set; } // Потребует загрузки файла
}