using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class NotificationService : INotificationService
{
    private readonly INotificationRepository _notificationRepository;
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<NotificationService> _logger;
    private readonly IUnitOfWork _unitOfWork; // Может понадобиться для получения доп. инфо (User)

    public NotificationService(
        INotificationRepository notificationRepository,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<NotificationService> logger,
        IUnitOfWork unitOfWork)
    {
        _notificationRepository = notificationRepository;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<NotificationDto>> GetUserNotificationsAsync(Guid userId, bool unreadOnly = false, int page = 1, int pageSize = 20)
    {
        _logger.LogInformation("Requesting notifications for user {UserId}, UnreadOnly: {UnreadOnly}, Page: {Page}, PageSize: {PageSize}", userId, unreadOnly, page, pageSize);
        // Пагинация должна быть реализована в репозитории GetForUserAsync
        var notifications = await _notificationRepository.GetForUserAsync(userId, unreadOnly); // TODO: Добавить пагинацию в репозиторий
        
        var pagedNotifications = notifications
            .OrderByDescending(n => n.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize);
            
        return _mapper.Map<IEnumerable<NotificationDto>>(pagedNotifications);
    }

    public async Task MarkNotificationAsReadAsync(string notificationId, Guid userId)
    {
        _logger.LogInformation("User {UserId} marking notification {NotificationId} as read", userId, notificationId);
        var notification = await _notificationRepository.GetByIdAsync(notificationId);
        if (notification == null)
        {
            _logger.LogWarning("Notification {NotificationId} not found.", notificationId);
            throw new KeyNotFoundException("Notification not found.");
        }
        if (notification.UserId != userId)
        {
             _logger.LogWarning("User {UserId} does not own notification {NotificationId}.", userId, notificationId);
            throw new UnauthorizedAccessException("User does not own this notification.");
        }

        if (!notification.IsRead)
        {
            await _notificationRepository.MarkAsReadAsync(notificationId); // Метод репозитория должен обновить IsRead = true
            _logger.LogInformation("Notification {NotificationId} marked as read for user {UserId}.", notificationId, userId);
            // Можно отправить real-time обновление клиенту, что уведомление прочитано (если UI это отображает)
            // await _realTimeNotifier.NotifyNotificationUpdatedAsync(userId, _mapper.Map<NotificationDto>(await _notificationRepository.GetByIdAsync(notificationId)));
        }
        else
        {
            _logger.LogInformation("Notification {NotificationId} was already read.", notificationId);
        }
    }

    public async Task MarkAllUserNotificationsAsReadAsync(Guid userId)
    {
        _logger.LogInformation("User {UserId} marking all their notifications as read", userId);
        var unreadNotifications = (await _notificationRepository.GetForUserAsync(userId, true)).ToList();
        if (!unreadNotifications.Any())
        {
            _logger.LogInformation("No unread notifications found for user {UserId}.", userId);
            return;
        }

        foreach (var notification in unreadNotifications)
        {
            // Этот метод должен делать Update в БД
            await _notificationRepository.MarkAsReadAsync(notification.Id); 
        }
        _logger.LogInformation("{Count} unread notifications for user {UserId} marked as read.", unreadNotifications.Count, userId);
        // TODO: Потенциально отправить одно real-time событие, что все прочитано
    }

    public async Task CreateAndSendNotificationAsync(
        Guid recipientUserId,
        NotificationType type,
        string message,
        string? title = null,
        string? relatedEntityId = null,
        string? relatedEntityType = null)
    {
        _logger.LogInformation("Creating notification for user {RecipientUserId}, Type: {Type}, Title: '{Title}', Message: '{MessageSnippet}'", 
            recipientUserId, type, title, message.Substring(0, Math.Min(message.Length, 30)));

        if (string.IsNullOrWhiteSpace(message))
        {
            _logger.LogError("Cannot create notification with empty message for user {RecipientUserId}", recipientUserId);
            throw new ArgumentException("Notification message cannot be empty.");
        }

        var user = await _unitOfWork.Users.GetByIdAsync(recipientUserId);
        if(user == null)
        {
            _logger.LogWarning("Recipient user {RecipientUserId} not found. Notification not created.", recipientUserId);
            return; // Или бросить исключение, если получатель обязателен
        }

        var notification = new Notification
        {
            // Id генерируется в конструкторе/MongoDB
            UserId = recipientUserId,
            Type = type,
            Title = title,
            Message = message,
            RelatedEntityId = relatedEntityId,
            RelatedEntityType = relatedEntityType,
            IsRead = false,
            CreatedAt = DateTime.UtcNow
        };
        await _notificationRepository.AddAsync(notification);
        _logger.LogInformation("Notification {NotificationId} created for user {RecipientUserId}. Sending real-time update.", notification.Id, recipientUserId);
        
        await _realTimeNotifier.NotifyNewNotificationAsync(recipientUserId, _mapper.Map<NotificationDto>(notification));
    }

    public async Task DeleteNotificationAsync(string notificationId, Guid userId)
    {
        _logger.LogInformation("User {UserId} attempting to delete notification {NotificationId}", userId, notificationId);
        var notification = await _notificationRepository.GetByIdAsync(notificationId);
        if (notification == null)
        {
             _logger.LogWarning("Notification {NotificationId} for deletion not found.", notificationId);
            throw new KeyNotFoundException("Notification not found.");
        }
        if (notification.UserId != userId)
        {
            _logger.LogWarning("User {UserId} does not own notification {NotificationId}. Cannot delete.", userId, notificationId);
            throw new UnauthorizedAccessException("User does not own this notification.");
        }

        // Предполагаем, что в INotificationRepository есть метод DeleteAsync(string id)
        // Если нет, и используется DeleteOldNotificationsAsync, то логика другая.
        // Добавим в IMessageRepository такой же метод DeleteAsync(string id) для консистентности
        // await _notificationRepository.DeleteAsync(notificationId); // Если такой метод есть
        _logger.LogWarning("DeleteNotificationAsync called. Assumed INotificationRepository has a DeleteAsync(string id) method. If not, implement or adjust. This is a placeholder.");
        // Заглушка, так как интерфейс INotificationRepository не объявлял DeleteAsync(id)
        // Если бы был, то:
        // await _notificationRepository.DeleteAsync(notificationId);
        // _logger.LogInformation("Notification {NotificationId} deleted by user {UserId}.", notificationId, userId);
        await Task.CompletedTask; // Удалите эту заглушку при наличии метода
    }
}