using SigmailClient.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class RespondToContactRequestDto {
    public Guid RequestId { get; set; } // ID объекта Contact
    public ContactRequestStatus Response { get; set; } // Accepted или Declined
}
