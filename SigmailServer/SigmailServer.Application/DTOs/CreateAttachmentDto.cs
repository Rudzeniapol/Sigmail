using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class CreateAttachmentDto
{
    public string FileKey { get; set; } = null!; // Ключ файла, полученный после загрузки на S3
    public string FileName { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public AttachmentType Type { get; set; }
    public long Size { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public string? ThumbnailKey { get; set; }
}