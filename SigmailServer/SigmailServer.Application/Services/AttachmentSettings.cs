namespace SigmailServer.Application.Services;

public class AttachmentSettings
{
    public long MaxFileSizeMB { get; set; } = 100; // Размер в МБ
    public List<string> AllowedFileExtensions { get; set; } = new List<string>();
    public List<string> AllowedContentTypes { get; set; } = new List<string>();

    public long MaxFileSizeBytes => MaxFileSizeMB * 1024 * 1024;
}