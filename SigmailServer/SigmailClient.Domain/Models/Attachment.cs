using SigmailClient.Domain.Enums;

namespace SigmailClient.Domain.Models;

public class Attachment
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid MessageId { get; set; }
    public AttachmentType Type { get; set; }
    public string Url { get; set; }
    public string? ThumbnailUrl { get; set; }
    public int? FileSize { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public MessageMetadata MessageMetadata { get; set; }
}