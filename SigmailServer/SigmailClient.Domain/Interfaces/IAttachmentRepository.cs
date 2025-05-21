using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IAttachmentRepository : IRepository<Attachment>
{
    Task<IEnumerable<Attachment>> GetByMessageAsync(Guid messageId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Attachment>> GetByTypeAsync(Guid chatId, AttachmentType type, CancellationToken cancellationToken = default);
    Task DeleteAllForMessageAsync(Guid messageId, CancellationToken cancellationToken = default);
}