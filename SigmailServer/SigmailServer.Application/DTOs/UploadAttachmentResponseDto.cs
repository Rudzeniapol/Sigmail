namespace SigmailServer.Application.DTOs;

public class UploadAttachmentResponseDto
{
    public string FileKey { get; set; }
    public string FileName { get; set; }
    public string ContentType { get; set; }
    public long Size { get; set; }
    public SigmailClient.Domain.Enums.AttachmentType Type { get; set; }
    public string PresignedUploadUrl { get; set; } // URL для прямой загрузки клиентом в S3
    // Или, если загрузка через сервер:
    // public AttachmentDto Attachment { get; set; }
}