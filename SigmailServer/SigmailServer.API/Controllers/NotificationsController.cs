using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.Services.Interfaces;
using System.Security.Claims;

namespace SigmailServer.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly ILogger<NotificationsController> _logger;

        public NotificationsController(INotificationService notificationService, ILogger<NotificationsController> logger)
        {
            _notificationService = notificationService;
            _logger = logger;
        }
        
        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId)) return userId;
            throw new UnauthorizedAccessException("User identifier not found or invalid.");
        }

        [HttpGet]
        public async Task<IActionResult> GetMyNotifications([FromQuery] bool unreadOnly = false, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var userId = GetCurrentUserId();
                var notifications = await _notificationService.GetUserNotificationsAsync(userId, unreadOnly, page, pageSize);
                return Ok(notifications);
            }
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message });}
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching notifications for user {UserId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("{notificationId}/read")]
        public async Task<IActionResult> MarkAsRead(string notificationId) // notificationId из MongoDB - строка
        {
            try
            {
                var userId = GetCurrentUserId();
                await _notificationService.MarkNotificationAsReadAsync(notificationId, userId);
                return Ok(new { message = "Notification marked as read." });
            }
            catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
            catch (UnauthorizedAccessException ex) { return Forbid(ex.Message); } // Пользователь не владелец
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking notification {NotificationId} as read by user {UserId}", notificationId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        [HttpPost("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            try
            {
                var userId = GetCurrentUserId();
                await _notificationService.MarkAllUserNotificationsAsReadAsync(userId);
                return Ok(new { message = "All notifications marked as read." });
            }
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message });}
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking all notifications as read for user {UserId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        // Эндпоинт для удаления уведомления (если вы реализуете этот функционал в сервисе и репозитории)
        // [HttpDelete("{notificationId}")]
        // public async Task<IActionResult> DeleteNotification(string notificationId)
        // {
        //     try
        //     {
        //         var userId = GetCurrentUserId();
        //         await _notificationService.DeleteNotificationAsync(notificationId, userId);
        //         return Ok(new { message = "Notification deleted." });
        //     }
        //     catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
        //     catch (UnauthorizedAccessException ex) { return Forbid(ex.Message); }
        //     catch (Exception ex)
        //     {
        //         _logger.LogError(ex, "Error deleting notification {NotificationId} by user {UserId}", notificationId, GetCurrentUserId());
        //         return StatusCode(500, new { message = "An unexpected error occurred." });
        //     }
        // }
    }
}