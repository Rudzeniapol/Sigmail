using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Domain.Models;

public class Contact
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid UserId { get; set; } // ID пользователя, который инициировал или к которому относится контакт
    [ForeignKey("UserId")]
    public virtual User User { get; set; } = null!;

    public Guid ContactUserId { get; set; } // ID пользователя, который является контактом
    [ForeignKey("ContactUserId")]
    public virtual User ContactUser { get; set; } = null!;

    [Required]
    [Column(TypeName = "varchar(20)")]
    public ContactRequestStatus Status { get; set; } = ContactRequestStatus.Pending;

    public DateTime RequestedAt { get; set; } = DateTime.UtcNow;
    public DateTime? RespondedAt { get; set; }
}