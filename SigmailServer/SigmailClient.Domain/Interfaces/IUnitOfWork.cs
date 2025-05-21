namespace SigmailClient.Domain.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IUserRepository Users { get; }
    IChatRepository Chats { get; }
    IMessageRepository Messages { get; }
    IAttachmentRepository Attachments { get; }
    IChatMemberRepository ChatMembers { get; }
    INotificationRepository Notifications { get; }

    Task<int> CommitAsync();
    Task RollbackAsync();
}