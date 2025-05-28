namespace SigmailServer.Domain.Interfaces;

public interface ISoftDeletable {
    bool IsDeleted { get; }
    DateTime? DeletedAt { get; }
}