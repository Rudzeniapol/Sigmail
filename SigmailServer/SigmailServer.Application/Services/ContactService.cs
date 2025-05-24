using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class ContactService : IContactService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly ILogger<ContactService> _logger;
    private readonly INotificationService _notificationService; // Для создания уведомлений

    public ContactService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        ILogger<ContactService> logger,
        INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _logger = logger;
        _notificationService = notificationService;
    }

    public async Task SendContactRequestAsync(Guid requesterId, ContactRequestDto dto)
    {
        _logger.LogInformation("User {RequesterId} sending contact request to user {TargetUserId}", requesterId, dto.TargetUserId);
        if (requesterId == dto.TargetUserId)
        {
            throw new ArgumentException("Cannot send contact request to yourself.");
        }

        var targetUser = await _unitOfWork.Users.GetByIdAsync(dto.TargetUserId);
        if (targetUser == null)
        {
            throw new KeyNotFoundException("Target user not found.");
        }

        // Проверяем существующие запросы в любом направлении
        var existingRequest = await _unitOfWork.Contacts.GetContactRequestAsync(requesterId, dto.TargetUserId) ??
                              await _unitOfWork.Contacts.GetContactRequestAsync(dto.TargetUserId, requesterId);

        if (existingRequest != null)
        {
            switch(existingRequest.Status)
            {
                case ContactRequestStatus.Accepted:
                    throw new InvalidOperationException("Users are already contacts.");
                case ContactRequestStatus.Pending:
                    if (existingRequest.UserId == requesterId) // Запрос уже отправлен этим пользователем
                        throw new InvalidOperationException("Contact request already sent and is pending.");
                    else // Запрос ожидает ответа от текущего requesterId
                        throw new InvalidOperationException($"There is a pending request from user {targetUser.Username}. Please respond to it.");
                case ContactRequestStatus.Declined:
                    // Можно разрешить повторный запрос после Decline, или требовать удаления старой записи
                    // Пока просто создадим новую, если Decline был от другого пользователя.
                    // Если Decline был от targetUser на запрос requesterId, то можно дать отправить снова.
                    // Если Decline был от requesterId на запрос targetUser, то targetUser должен отправить снова.
                    // Для простоты: если есть Declined, предполагаем, что можно отправить новый, старый будет проигнорирован или перезаписан при принятии.
                    // Или, лучше, если запись Declined существует, то ее нужно сначала "снять" или удалить.
                    // Пока что, если Declined, разрешим отправить новый.
                    _logger.LogInformation("Previous request between {User1} and {User2} was declined. Allowing new request.", requesterId, dto.TargetUserId);
                    break; // Позволяем создать новый запрос поверх Declined
                case ContactRequestStatus.Blocked:
                     throw new InvalidOperationException("Cannot send request, one of the users is blocked.");
            }
        }

        var contactRequest = new Contact
        {
            UserId = requesterId, // Тот, кто отправил запрос
            ContactUserId = dto.TargetUserId, // Кому запрос
            Status = ContactRequestStatus.Pending,
            RequestedAt = DateTime.UtcNow
        };
        await _unitOfWork.Contacts.AddAsync(contactRequest);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Contact request from {RequesterId} to {TargetUserId} sent successfully. ID: {ContactRequestId}", requesterId, dto.TargetUserId, contactRequest.Id);

        var requester = await _unitOfWork.Users.GetByIdAsync(requesterId);
        await _notificationService.CreateAndSendNotificationAsync(
            dto.TargetUserId,
            NotificationType.ContactRequestReceived, // TODO: Нужен NotificationType.ContactRequestReceived
            $"User {requester?.Username ?? "Unknown"} sent you a contact request.",
            "New Contact Request",
            relatedEntityId: requesterId.ToString(), // ID отправителя запроса
            relatedEntityType: "UserContactRequest"
        );
    }

    public async Task RespondToContactRequestAsync(Guid responderId, RespondToContactRequestDto dto)
    {
        _logger.LogInformation("User {ResponderId} responding to contact request {RequestId} with {Response}", responderId, dto.RequestId, dto.Response);
        var contactRequest = await _unitOfWork.Contacts.GetByIdAsync(dto.RequestId); 
        if (contactRequest == null)
        {
            throw new KeyNotFoundException("Contact request not found.");
        }
        // Убеждаемся, что responderId - это тот, кому был адресован запрос (ContactUserId)
        if (contactRequest.ContactUserId != responderId)
        {
            throw new UnauthorizedAccessException("User cannot respond to this request.");
        }
        if (contactRequest.Status != ContactRequestStatus.Pending)
        {
            throw new InvalidOperationException($"Request is not pending. Current status: {contactRequest.Status}.");
        }
        if (dto.Response != ContactRequestStatus.Accepted && dto.Response != ContactRequestStatus.Declined)
        {
            throw new ArgumentException("Invalid response status. Must be Accepted or Declined.");
        }

        contactRequest.Status = dto.Response;
        contactRequest.RespondedAt = DateTime.UtcNow;
        await _unitOfWork.Contacts.UpdateAsync(contactRequest);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Contact request {RequestId} (from {OriginalRequesterId} to {ResponderId}) responded with {Response}", 
            dto.RequestId, contactRequest.UserId, responderId, dto.Response);

        var responder = await _unitOfWork.Users.GetByIdAsync(responderId);
        string notificationMessage = dto.Response == ContactRequestStatus.Accepted
            ? $"User {responder?.Username ?? "Unknown"} accepted your contact request."
            : $"User {responder?.Username ?? "Unknown"} declined your contact request.";
        
        NotificationType notificationType = dto.Response == ContactRequestStatus.Accepted 
            ? NotificationType.ContactRequestAccepted 
            : NotificationType.ContactRequestDeclined;

        
        await _notificationService.CreateAndSendNotificationAsync(
            contactRequest.UserId, // Уведомляем инициатора запроса
            notificationType, // TODO: Нужен NotificationType.ContactRequestResponded
            notificationMessage,
            "Contact Request Update",
            relatedEntityId: responderId.ToString(), // ID того, кто ответил
            relatedEntityType: "UserContactResponse"
        );
    }

    public async Task RemoveContactAsync(Guid currentUserId, Guid contactUserIdToRemove)
    {
        _logger.LogInformation("User {CurrentUserId} attempting to remove contact with user {ContactUserIdToRemove}", currentUserId, contactUserIdToRemove);

        var contactEntry = await _unitOfWork.Contacts.GetContactRequestAsync(currentUserId, contactUserIdToRemove) ??
                           await _unitOfWork.Contacts.GetContactRequestAsync(contactUserIdToRemove, currentUserId);

        if (contactEntry == null || contactEntry.Status != ContactRequestStatus.Accepted)
        {
            throw new KeyNotFoundException("No accepted contact relationship found to remove.");
        }

        // Вместо удаления можно менять статус, например на "RemovedByInitiator" или "RemovedByTarget"
        // Или действительно удалять запись. Пока удаляем.
        await _unitOfWork.Contacts.DeleteAsync(contactEntry.Id);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Contact between {CurrentUserId} and {ContactUserIdToRemove} (Entry ID: {ContactEntryId}) removed.", 
            currentUserId, contactUserIdToRemove, contactEntry.Id);
        
        // TODO: Optionally notify contactUserIdToRemove that they were removed.
        // Это может быть спорным моментом с точки зрения UX (тихое удаление или уведомление).
        var currentUser = await _unitOfWork.Users.GetByIdAsync(currentUserId);
        await _notificationService.CreateAndSendNotificationAsync(
            contactUserIdToRemove,
            NotificationType.ContactRemoved,
            $"User {currentUser?.Username ?? "Unknown"} has removed you from their contacts.",
            "Contact Removed",
            relatedEntityId: currentUserId.ToString(),
            relatedEntityType: "User" 
        );
    }

    public async Task<IEnumerable<ContactDto>> GetUserContactsAsync(Guid userId, ContactRequestStatus? statusFilter = ContactRequestStatus.Accepted)
    {
        _logger.LogInformation("Requesting contacts for user {UserId} with status filter {StatusFilter}", userId, statusFilter);
        var contacts = await _unitOfWork.Contacts.GetUserContactsAsync(userId, statusFilter);
        
        var contactDtos = new List<ContactDto>();
        foreach(var contact in contacts)
        {
            // Определяем, кто в этой записи является "другим" пользователем
            var otherUserId = (contact.UserId == userId) ? contact.ContactUserId : contact.UserId;
            var contactUserDomain = await _unitOfWork.Users.GetByIdAsync(otherUserId);
            
            if (contactUserDomain != null)
            {
               contactDtos.Add(new ContactDto {
                    ContactEntryId = contact.Id,
                    User = _mapper.Map<UserDto>(contactUserDomain), // Это DTO пользователя-контакта
                    Status = contact.Status,
                    RequestedAt = contact.RequestedAt,
                    RespondedAt = contact.RespondedAt
               });
            }
            else
            {
                _logger.LogWarning("Could not find user details for contact entry {ContactEntryId}, other user ID {OtherUserId}", contact.Id, otherUserId);
            }
        }
        return contactDtos;
    }

    public async Task<IEnumerable<ContactDto>> GetPendingContactRequestsAsync(Guid userId)
    {
        _logger.LogInformation("Requesting pending contact requests for user {UserId} (requests sent TO this user)", userId);
        // Этот метод должен возвращать запросы, где `userId` является `ContactUserId` (получателем запроса)
        var requests = await _unitOfWork.Contacts.GetPendingContactRequestsForUserAsync(userId); 
        
        var requestDtos = new List<ContactDto>();
        foreach(var req in requests)
        {
            // В данном случае, req.UserId - это тот, кто отправил запрос пользователю `userId`
            var requesterUser = await _unitOfWork.Users.GetByIdAsync(req.UserId); 
            if(requesterUser != null)
            {
                requestDtos.Add(new ContactDto {
                    ContactEntryId = req.Id,
                    User = _mapper.Map<UserDto>(requesterUser), // DTO пользователя, отправившего запрос
                    Status = req.Status, // Должен быть Pending
                    RequestedAt = req.RequestedAt
                });
            }
            else
            {
                 _logger.LogWarning("Could not find user details for requester ID {RequesterId} in contact request {ContactRequestId}", req.UserId, req.Id);
            }
        }
        return requestDtos;
    }
}