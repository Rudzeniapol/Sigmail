using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Interfaces;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class UserService : IUserService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<UserService> _logger;
    private readonly INotificationService _notificationService;

    public UserService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<UserService> logger,
        INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _notificationService = notificationService;
    }

    public async Task<UserDto?> GetByIdAsync(Guid id)
    {
        _logger.LogInformation("Requesting user by ID {UserId}", id);
        var user = await _unitOfWork.Users.GetByIdAsync(id);
        if (user == null)
        {
            _logger.LogWarning("User with ID {UserId} not found.", id);
            return null;
        }
        return _mapper.Map<UserDto>(user);
    }

    public async Task UpdateOnlineStatusAsync(Guid id, bool isOnline, string? deviceToken = null)
    {
        _logger.LogInformation("Updating online status for user {UserId}: IsOnline={IsOnline}, DeviceToken={DeviceToken}", id, isOnline, deviceToken != null ? "provided" : "not provided");
        var user = await _unitOfWork.Users.GetByIdAsync(id);
        if (user == null)
        {
            _logger.LogWarning("User {UserId} not found for status update.", id);
            // Consider throwing KeyNotFoundException if user must exist
            return;
        }

        if (isOnline) user.GoOnline(deviceToken);
        else user.GoOffline();

        await _unitOfWork.Users.UpdateAsync(user);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Online status updated for user {UserId} to IsOnline={IsOnline}", id, user.IsOnline);

        // Уведомление контактов об изменении статуса
        var contacts = await _unitOfWork.Contacts.GetUserContactsAsync(id, ContactRequestStatus.Accepted);
        var contactUserIds = contacts
            .Select(c => c.UserId == id ? c.ContactUserId : c.UserId)
            .Distinct()
            .ToList();
        
        if (contactUserIds.Any())
        {
            // Можно было бы дополнительно отфильтровать contactUserIds, чтобы уведомлять только тех, кто онлайн,
            // но это усложнит (нужно будет делать запрос к Users), и сам клиент решит, как ему обработать это.
            await _realTimeNotifier.NotifyUserStatusChangedAsync(contactUserIds, id, user.IsOnline, user.LastSeen);
            _logger.LogInformation("Notified {Count} contacts about status change for user {UserId}", contactUserIds.Count, id);
        }
    }

    public async Task<IEnumerable<UserDto>> GetOnlineUsersAsync()
    {
        _logger.LogInformation("Requesting all online users");
        // Внимание: этот метод может быть очень ресурсоемким, если пользователей много.
        // Рассмотрите альтернативы, если это не для админ-панели.
        var users = await _unitOfWork.Users.GetAllAsync(); // Предполагается, что GetAllAsync существует
        var onlineUsers = users.Where(u => u.IsOnline);
        return _mapper.Map<IEnumerable<UserDto>>(onlineUsers);
    }

    public async Task<UserDto?> GetByUsernameAsync(string username)
    {
        _logger.LogInformation("Requesting user by username {Username}", username);
        if (string.IsNullOrWhiteSpace(username))
        {
            throw new ArgumentException("Username cannot be empty.", nameof(username));
        }
        var user = await _unitOfWork.Users.GetByUsernameAsync(username);
        if (user == null)
        {
            _logger.LogWarning("User with username {Username} not found.", username);
            return null;
        }
        return _mapper.Map<UserDto>(user);
    }

    public async Task<IEnumerable<UserDto>> SearchUsersAsync(string searchTerm, Guid currentUserId)
    {
        _logger.LogInformation("User {CurrentUserId} searching for users with term '{SearchTerm}'", currentUserId, searchTerm);
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            return Enumerable.Empty<UserDto>();
        }
        // IUserRepository.FindUsersAsync должен быть реализован для поиска по username, email и т.д.
        // и не должен возвращать текущего пользователя.
        var users = await _unitOfWork.Users.FindUsersAsync(searchTerm); 
        
        // Исключаем текущего пользователя из результатов поиска
        var foundUsers = users.Where(u => u.Id != currentUserId);
        
        return _mapper.Map<IEnumerable<UserDto>>(foundUsers);
    }

    public async Task UpdateUserProfileAsync(Guid userId, UpdateUserProfileDto dto)
    {
        _logger.LogInformation("User {UserId} updating profile with DTO: Username={DtoUsername}, Email={DtoEmail}", userId, dto.Username, dto.Email);
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user == null)
        {
            _logger.LogWarning("User {UserId} not found for profile update.", userId);
            throw new KeyNotFoundException("User not found.");
        }

        bool changed = false;

        if (!string.IsNullOrWhiteSpace(dto.Username) && dto.Username != user.Username)
        {
           var existingUserByUsername = await _unitOfWork.Users.GetByUsernameAsync(dto.Username);
           if (existingUserByUsername != null && existingUserByUsername.Id != userId)
           {
               throw new ArgumentException("Username already taken.");
           }
           // user.Username = dto.Username; // User.UpdateProfile должен это делать
           changed = true;
        }
        if (!string.IsNullOrWhiteSpace(dto.Email) && dto.Email != user.Email)
        {
           var existingUserByEmail = await _unitOfWork.Users.GetByEmailAsync(dto.Email);
           if (existingUserByEmail != null && existingUserByEmail.Id != userId)
           {
               throw new ArgumentException("Email already taken.");
           }
           // user.Email = dto.Email; // User.UpdateProfile должен это делать
           changed = true;
        }
        if (dto.Bio != user.Bio) // Bio может быть null или пустым
        {
            // user.Bio = dto.Bio; // User.UpdateProfile должен это делать
            changed = true;
        }

        // ProfileImageUrl обновляется через отдельный endpoint, здесь мы его не трогаем

        if(changed)
        {
            string? oldUsername = user.Username;
            
            user.UpdateProfile(dto.Username, dto.Email, dto.Bio, user.ProfileImageUrl); // Передаем старый URL аватара
            await _unitOfWork.Users.UpdateAsync(user);
            await _unitOfWork.CommitAsync();
            _logger.LogInformation("Profile for user {UserId} updated.", userId);

            if (!string.IsNullOrWhiteSpace(dto.Username) && dto.Username != oldUsername)
            {
                var contacts = await _unitOfWork.Contacts.GetUserContactsAsync(userId, ContactRequestStatus.Accepted);
                var contactUserIdsToNotify = contacts
                    .Select(c => c.UserId == userId ? c.ContactUserId : c.UserId)
                    .Distinct();

                foreach (var contactUserId in contactUserIdsToNotify)
                {
                    await _notificationService.CreateAndSendNotificationAsync(
                        contactUserId,
                        NotificationType.UserProfileUpdated,
                        $"User '{oldUsername}' is now known as '{user.Username}'.",
                        "User Profile Updated",
                        relatedEntityId: userId.ToString(),
                        relatedEntityType: "User"
                    );
                }
                _logger.LogInformation("Notified {Count} contacts about username change for user {UserId}", contactUserIdsToNotify.Count(), userId);

                // Также можно отправить real-time уведомление, если это необходимо
                // await _realTimeNotifier.NotifyUserProfileChangedAsync(contactUserIdsToNotify, userId, user.Username, user.ProfileImageUrl);
            }
        }
        else
        {
            _logger.LogInformation("No changes detected for user {UserId} profile.", userId);
        }
    }
}