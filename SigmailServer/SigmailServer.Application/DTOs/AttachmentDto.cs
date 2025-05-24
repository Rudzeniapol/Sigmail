using SigmailClient.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class AttachmentDto {
    public string FileKey { get; set; } = string.Empty; // Ключ файла в S3
    public string FileName { get; set; } = string.Empty; // Оригинальное имя файла
    public string ContentType { get; set; } = string.Empty;
    public string? PresignedUrl { get; set; } // Временный URL для доступа, если нужен клиенту
    public AttachmentType Type { get; set; } // Используем enum
    public long Size { get; set; }
    public string? ThumbnailKey { get; set; }
    public string? ThumbnailPresignedUrl { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
}