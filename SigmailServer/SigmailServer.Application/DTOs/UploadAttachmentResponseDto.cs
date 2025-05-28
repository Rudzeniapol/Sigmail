using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class UploadAttachmentResponseDto
{
    public string FileKey { get; set; } = null!;
    public string FileName { get; set; } = null!;
    public string ContentType { get; set; } = null!;
    public long Size { get; set; }
    public AttachmentType Type { get; set; }
    public string PresignedUploadUrl { get; set; } = null!; // URL для прямой загрузки клиентом в S3
    // Или, если загрузка через сервер:
    // public AttachmentDto Attachment { get; set; }
}