using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.Services.Interfaces;


public interface IContactService
{
    Task SendContactRequestAsync(Guid requesterId, ContactRequestDto dto);
    Task RespondToContactRequestAsync(Guid responderId, RespondToContactRequestDto dto);
    Task RemoveContactAsync(Guid currentUserId, Guid contactUserIdToRemove);
    Task<IEnumerable<ContactDto>> GetUserContactsAsync(Guid userId, ContactRequestStatus? statusFilter = null);
    Task<IEnumerable<ContactDto>> GetPendingContactRequestsAsync(Guid userId); // Запросы, отправленные пользователю
}