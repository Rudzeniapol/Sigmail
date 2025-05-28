using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Domain.Models;
using BCrypt.Net;
using SigmailServer.Domain.Enums;
using System.Threading;

namespace SigmailServer.Application.Services;

public class UserService : IUserService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<UserService> _logger;
    private readonly INotificationService _notificationService;
    private readonly IFileStorageRepository _fileStorageRepository;

    public UserService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<UserService> logger,
        INotificationService notificationService,
        IFileStorageRepository fileStorageRepository)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _notificationService = notificationService;
        _fileStorageRepository = fileStorageRepository;
    }

    private async Task<UserDto> MapUserToDtoWithAvatarUrlAsync(User user)
    {
        var userDto = _mapper.Map<UserDto>(user);
        if (!string.IsNullOrWhiteSpace(userDto.ProfileImageUrl))
        {
            try
            {
                // ProfileImageUrl хранит ключ файла.
                // Генерируем presigned URL для доступа к файлу.
                // TimeSpan можно вынести в конфигурацию, если нужно.
                var presignedUrl = await _fileStorageRepository.GeneratePresignedUrlAsync(userDto.ProfileImageUrl, TimeSpan.FromHours(1)); 
                userDto.ProfileImageUrl = presignedUrl;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get presigned URL for avatar {AvatarKey} for user {UserId}. Returning key itself.", userDto.ProfileImageUrl, user.Id);
                // Оставляем ключ как fallback. Клиент не сможет загрузить, но и не должен упасть.
            }
        }
        return userDto;
    }
    
    public async Task<UserSimpleDto?> MapUserToSimpleDtoWithAvatarUrlAsync(User user)
    {
        if (user == null) 
        {
            _logger.LogWarning("MapUserToSimpleDtoWithAvatarUrlAsync called with null user.");
            return null; // Возвращаем null, если пользователь null
        }

        var userSimpleDto = _mapper.Map<UserSimpleDto>(user);
        if (!string.IsNullOrWhiteSpace(userSimpleDto.ProfileImageUrl))
        {
            try
            {
                var presignedUrl = await _fileStorageRepository.GeneratePresignedUrlAsync(userSimpleDto.ProfileImageUrl, TimeSpan.FromHours(1));
                userSimpleDto.ProfileImageUrl = presignedUrl;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get presigned URL for avatar {AvatarKey} for user {UserId} (SimpleDto). Returning key itself.", userSimpleDto.ProfileImageUrl, user.Id);
            }
        }
        return userSimpleDto;
    }

    private async Task<IEnumerable<UserDto>> MapUsersToDtoWithAvatarUrlAsync(IEnumerable<User> users)
    {
        var userDtos = new List<UserDto>();
        foreach (var user in users)
        {
            userDtos.Add(await MapUserToDtoWithAvatarUrlAsync(user));
        }
        return userDtos;
    }
    
    private async Task<IEnumerable<UserSimpleDto>> MapUsersToSimpleDtoWithAvatarUrlAsync(IEnumerable<User> users)
    {
        var userSimpleDtos = new List<UserSimpleDto>();
        foreach (var user in users)
        {
            userSimpleDtos.Add(await MapUserToSimpleDtoWithAvatarUrlAsync(user));
        }
        return userSimpleDtos;
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
        // return _mapper.Map<UserDto>(user);
        return await MapUserToDtoWithAvatarUrlAsync(user);
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
        // return _mapper.Map<IEnumerable<UserDto>>(onlineUsers);
        return await MapUsersToDtoWithAvatarUrlAsync(onlineUsers);
    }

    public async Task<UserDto?> GetByUsernameAsync(string username)
    {
        _logger.LogInformation("Requesting user by username {Username}", username);
        if (string.IsNullOrWhiteSpace(username))
        {
            // Consider throwing ArgumentException if username cannot be empty
            _logger.LogWarning("Requested username was null or whitespace.");
            return null; 
        }
        var user = await _unitOfWork.Users.GetByUsernameAsync(username);
        if (user == null)
        {
            _logger.LogWarning("User with username {Username} not found.", username);
            return null;
        }
        // return _mapper.Map<UserDto>(user);
        return await MapUserToDtoWithAvatarUrlAsync(user);
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
        var users = await _unitOfWork.Users.FindUsersAsync(searchTerm, 20, CancellationToken.None); 
        
        // Исключаем текущего пользователя из результатов поиска
        var foundUsers = users.Where(u => u.Id != currentUserId);
        
        // return _mapper.Map<IEnumerable<UserDto>>(foundUsers);
        return await MapUsersToDtoWithAvatarUrlAsync(foundUsers);
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
        string? oldUsername = user.Username; // Сохраняем старое имя для уведомлений
        string? oldEmail = user.Email; // Сохраняем старый email

        // Обновляем имя пользователя, если оно предоставлено и отличается
        if (!string.IsNullOrWhiteSpace(dto.Username) && dto.Username != user.Username)
        {
           var existingUserByUsername = await _unitOfWork.Users.GetByUsernameAsync(dto.Username);
           if (existingUserByUsername != null && existingUserByUsername.Id != userId)
           {
               throw new ArgumentException("Username already taken.");
           }
           // user.Username = dto.Username; // Будет установлено через UpdateProfile
           changed = true;
        }
        // Обновляем email, если он предоставлен и отличается
        if (!string.IsNullOrWhiteSpace(dto.Email) && dto.Email != user.Email)
        {
           var existingUserByEmail = await _unitOfWork.Users.GetByEmailAsync(dto.Email);
           if (existingUserByEmail != null && existingUserByEmail.Id != userId)
           {
               throw new ArgumentException("Email already taken.");
           }
           // user.Email = dto.Email; // Будет установлено через UpdateProfile
           changed = true;
        }
        // Обновляем Bio, если оно предоставлено и отличается (может быть null или пустым)
        if (dto.Bio != user.Bio) 
        {
            // user.Bio = dto.Bio; // Будет установлено через UpdateProfile
            changed = true;
        }

        if(changed)
        {
            // Используем метод модели User для обновления полей
            user.UpdateProfile(
                string.IsNullOrWhiteSpace(dto.Username) ? oldUsername : dto.Username, 
                string.IsNullOrWhiteSpace(dto.Email) ? oldEmail : dto.Email, 
                dto.Bio, 
                user.ProfileImageUrl // ProfileImageUrl здесь не меняем, он обновляется отдельно
            ); 

            await _unitOfWork.Users.UpdateAsync(user);
            await _unitOfWork.CommitAsync();
            _logger.LogInformation("Profile for user {UserId} updated.", userId);

            // Уведомление контактов, если изменилось имя пользователя
            if (!string.IsNullOrWhiteSpace(dto.Username) && dto.Username != oldUsername)
            {
                var contacts = await _unitOfWork.Contacts.GetUserContactsAsync(userId, ContactRequestStatus.Accepted);
                var contactUserIdsToNotify = contacts
                    .Select(c => c.UserId == userId ? c.ContactUserId : c.UserId)
                    .Distinct();

                foreach (var contactUserId in contactUserIdsToNotify)
                {
                    // TODO: Пересмотреть текст уведомления, чтобы он был более общим, если и email меняется
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
                 // Также можно отправить real-time уведомление об изменении профиля, если это нужно
                // await _realTimeNotifier.NotifyUserProfileChangedAsync(contactUserIdsToNotify, userId, user.Username, user.ProfileImageUrl); // Нужен метод в IRealTimeNotifier
            }
        }
        else
        {
            _logger.LogInformation("No changes detected for user {UserId} profile.", userId);
        }
    }
    
    public async Task UpdateUserAvatarAsync(Guid userId, string avatarFileKey)
    {
        _logger.LogInformation("User {UserId} updating avatar with new file key {AvatarFileKey}", userId, avatarFileKey);
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user == null)
        {
            _logger.LogWarning("User {UserId} not found for avatar update.", userId);
            // Если файл уже загружен в S3, а пользователь не найден, это проблема.
            // Возможно, стоит удалить "бесхозный" файл из S3.
            // Пока просто выбрасываем исключение.
            throw new KeyNotFoundException("User not found.");
        }

        string? oldAvatarKey = user.ProfileImageUrl;

        user.ProfileImageUrl = avatarFileKey; // Обновляем URL/ключ аватара

        await _unitOfWork.Users.UpdateAsync(user);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Avatar updated for user {UserId}. New key: {NewKey}, Old key: {OldKey}", userId, avatarFileKey, oldAvatarKey ?? "N/A");

        // Удаляем старый аватар из S3, если он был и он не является каким-то placeholder'ом по умолчанию
        if (!string.IsNullOrWhiteSpace(oldAvatarKey) && oldAvatarKey != avatarFileKey)
        {
            try
            {
                _logger.LogInformation("Attempting to delete old avatar {OldAvatarKey} for user {UserId}", oldAvatarKey, userId);
                await _fileStorageRepository.DeleteFileAsync(oldAvatarKey);
                _logger.LogInformation("Successfully deleted old avatar {OldAvatarKey} for user {UserId}", oldAvatarKey, userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete old avatar {OldAvatarKey} for user {UserId} from S3. This needs to be handled manually or by a cleanup job.", oldAvatarKey, userId);
            }
        }
    
        // Уведомляем контакты/других пользователей об обновлении аватара через SignalR
        try
        {
            var contacts = await _unitOfWork.Contacts.GetUserContactsAsync(userId, ContactRequestStatus.Accepted);
            var contactUserIdsToNotify = contacts
                .Select(c => c.UserId == userId ? c.ContactUserId : c.UserId)
                .Distinct()
                .ToList(); // ToList() чтобы избежать многократного выполнения запроса

            if (contactUserIdsToNotify.Any())
            {
                string? newAvatarFullUrl = null;
                if (!string.IsNullOrWhiteSpace(user.ProfileImageUrl)) // user.ProfileImageUrl это ключ
                {
                    try
                    {
                        newAvatarFullUrl = await _fileStorageRepository.GeneratePresignedUrlAsync(user.ProfileImageUrl, TimeSpan.FromHours(1));
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to generate presigned URL for new avatar {AvatarKey} for user {UserId} during notification. Avatar URL will be sent as key.", user.ProfileImageUrl, userId);
                        newAvatarFullUrl = user.ProfileImageUrl; // Отправляем ключ как fallback, если генерация URL не удалась
                    }
                }
                else
                {
                    newAvatarFullUrl = string.Empty; // Если ключа нет, отправляем пустую строку
                }
                
                // Убедитесь, что NotifyUserAvatarUpdatedAsync существует в IRealTimeNotifier и SignalRNotifier
                await _realTimeNotifier.NotifyUserAvatarUpdatedAsync(contactUserIdsToNotify, userId, newAvatarFullUrl);
                _logger.LogInformation("Notified {Count} contacts about avatar update for user {UserId}", contactUserIdsToNotify.Count, userId);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to notify contacts about avatar update for user {UserId}.", userId);
            // Не прерываем выполнение, так как основная операция (обновление аватара) уже завершена.
        }
    }

    public async Task<IEnumerable<UserSimpleDto>> SearchUsersAsync(string searchTerm, int limit = 20)
    {
        _logger.LogInformation("Searching for users (simple DTO) with term '{SearchTerm}' and limit {Limit}", searchTerm, limit);
        if (string.IsNullOrWhiteSpace(searchTerm))
        {
            return Enumerable.Empty<UserSimpleDto>();
        }
        // Пока для простоты оставим без этого

        var users = await _unitOfWork.Users.FindUsersAsync(searchTerm.ToLower(), limit, CancellationToken.None); // Заменено SearchUsersByUsernameAsync на FindUsersAsync и добавлен CancellationToken.None
        // return _mapper.Map<IEnumerable<UserSimpleDto>>(users);
        return await MapUsersToSimpleDtoWithAvatarUrlAsync(users);
    }

    public async Task ChangePasswordAsync(Guid userId, string oldPassword, string newPassword)
    {
        _logger.LogInformation("User {UserId} attempting to change password.", userId);
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user == null)
        {
            _logger.LogWarning("User {UserId} not found for password change.", userId);
            throw new KeyNotFoundException("User not found.");
        }

        if (!BCrypt.Net.BCrypt.Verify(oldPassword, user.PasswordHash))
        {
            _logger.LogWarning("Invalid old password for user {UserId}.", userId);
            throw new ArgumentException("Invalid old password.");
        }

        var newPasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
        user.UpdatePassword(newPasswordHash); // Предполагается, что в User.cs есть метод UpdatePassword

        await _unitOfWork.Users.UpdateAsync(user);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Password changed successfully for user {UserId}.", userId);
    }
}