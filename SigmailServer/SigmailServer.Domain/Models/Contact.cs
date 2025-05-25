using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SigmailClient.Domain.Enums;

namespace SigmailClient.Domain.Models;

public class Contact
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; } // Тот, кто добавил/запросил
    [ForeignKey("UserId")]
    public virtual User User { get; set; }

    public Guid ContactUserId { get; set; } // Тот, кого добавили/кому запрос
    [ForeignKey("ContactUserId")]
    public virtual User ContactUser { get; set; }

    [Required]
    [Column(TypeName = "varchar(20)")]
    public ContactRequestStatus Status { get; set; } = ContactRequestStatus.Pending;

    public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    public DateTime? RespondedAt { get; set; }
}