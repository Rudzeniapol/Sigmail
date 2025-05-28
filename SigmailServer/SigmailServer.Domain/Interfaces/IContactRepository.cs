using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Models;

namespace SigmailServer.Domain.Interfaces;

public interface IContactRepository : IRepository<Contact>
{
    Task<Contact?> GetContactRequestAsync(Guid userId, Guid contactUserId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Contact>> GetUserContactsAsync(Guid userId, ContactRequestStatus? status = ContactRequestStatus.Accepted, CancellationToken cancellationToken = default);
    Task<IEnumerable<Contact>> GetPendingContactRequestsForUserAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<bool> AreUsersContactsAsync(Guid userId1, Guid userId2, CancellationToken cancellationToken = default);
}