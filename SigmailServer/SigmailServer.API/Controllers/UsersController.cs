using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using System.Security.Claims;

namespace SigmailServer.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Большинство методов здесь требуют авторизации
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IAttachmentService _attachmentService; // Для загрузки аватара
        private readonly ILogger<UsersController> _logger;

        public UsersController(IUserService userService, IAttachmentService attachmentService, ILogger<UsersController> logger)
        {
            _userService = userService;
            _attachmentService = attachmentService;
            _logger = logger;
        }

        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId))
            {
                return userId;
            }
            // Это не должно происходить, если [Authorize] работает корректно
            throw new UnauthorizedAccessException("User identifier not found or invalid in token.");
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetMyProfile()
        {
            try
            {
                var userId = GetCurrentUserId();
                var userDto = await _userService.GetByIdAsync(userId);
                if (userDto == null)
                {
                    return NotFound(new { message = "User profile not found." });
                }
                return Ok(userDto);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching current user's profile.");
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserProfile(Guid id)
        {
            try
            {
                var userDto = await _userService.GetByIdAsync(id);
                if (userDto == null)
                {
                    return NotFound(new { message = $"User with ID {id} not found." });
                }
                // TODO: Добавить логику, кто может просматривать чужие профили (например, только контакты или все)
                return Ok(userDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching user profile for ID {UserId}.", id);
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        [HttpPut("me/profile")]
        public async Task<IActionResult> UpdateMyProfile([FromBody] UpdateUserProfileDto dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                await _userService.UpdateUserProfileAsync(userId, dto);
                return Ok(new { message = "Profile updated successfully." });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error updating user profile for user {UserId}.", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("me/avatar")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new { message = "No file uploaded." });
            }

            try
            {
                var userId = GetCurrentUserId();
                
                var attachmentDto = await _attachmentService.UploadAttachmentAsync(
                    userId,
                    file.OpenReadStream(),
                    file.FileName,
                    file.ContentType,
                    SigmailClient.Domain.Enums.AttachmentType.Image 
                );

                // <<< ВЫЗОВ НОВОГО МЕТОДА СЕРВИСА >>>
                await _userService.UpdateUserAvatarAsync(userId, attachmentDto.FileKey);
                
                _logger.LogInformation("User {UserId} uploaded and linked new avatar. FileKey: {FileKey}", userId, attachmentDto.FileKey);
                
                // Получаем обновленный URL (если UploadAttachmentAsync его не возвращает в актуальном виде для аватара)
                // или просто подтверждаем успех. PresignedUrl из attachmentDto может быть не тем, что хранится как ProfileImageUrl.
                // ProfileImageUrl - это обычно сам fileKey или постоянный CDN URL, а не временный presigned.
                return Ok(new { 
                    message = "Avatar uploaded and updated successfully.", 
                    fileKey = attachmentDto.FileKey,
                    // Если ProfileImageUrl должен быть доступен через presigned URL, его нужно генерировать отдельно:
                    // profileImageUrl = await _attachmentService.GetPresignedDownloadUrlAsync(attachmentDto.FileKey, userId) 
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex) // Если user не найден в UpdateUserAvatarAsync
            {
                 return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex) 
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading avatar for user {UserId}.", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred during avatar upload." });
            }
        }


        [HttpGet("search")]
        public async Task<IActionResult> SearchUsers([FromQuery] string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
            {
                return BadRequest(new { message = "Search term cannot be empty." });
            }
            try
            {
                var currentUserId = GetCurrentUserId();
                var users = await _userService.SearchUsersAsync(searchTerm, currentUserId);
                return Ok(users);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error searching users with term '{SearchTerm}'.", searchTerm);
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
    }
}