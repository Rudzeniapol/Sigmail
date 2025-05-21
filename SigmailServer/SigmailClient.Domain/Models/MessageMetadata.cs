namespace SigmailClient.Domain.Models;

public class MessageMetadata
{
    public Guid MessageId { get; set; } = Guid.NewGuid();
    public Guid ChatId { get; set; }
    public Guid? SenderId { get; set; }
    public DateTime SentAt { get; set; } = DateTime.UtcNow;
    public bool IsEdited { get; set; }
    public bool IsDeleted { get; set; }
    public Chat Chat { get; set; }
    public User Sender { get; set; }
    public ICollection<Attachment> Attachments { get; set; }
}