namespace SigmailServer.Application.DTOs;

public class CreateAttachmentDto
{
    public string FileKey { get; set; } // Ключ файла, полученный после загрузки на S3
    public string FileName { get; set; }
    public string ContentType { get; set; }
    public SigmailClient.Domain.Enums.AttachmentType Type { get; set; }
    public long Size { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public string? ThumbnailKey { get; set; }
}