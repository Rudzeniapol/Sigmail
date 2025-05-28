using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Domain.Enums;

namespace SigmailServer.Controllers
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
                // Возвращаем обновленного пользователя после обновления профиля
                var updatedUser = await _userService.GetByIdAsync(userId);
                if (updatedUser == null) 
                {
                    // Этого не должно произойти, если UpdateUserProfileAsync не выбросил исключение
                    _logger.LogError("User {UserId} not found after profile update.", userId);
                    return NotFound(new { message = "User not found after update." });
                }
                return Ok(updatedUser);
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
        public async Task<ActionResult<UserDto>> UploadAvatar(IFormFile file)
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
                    AttachmentType.Image 
                );

                await _userService.UpdateUserAvatarAsync(userId, attachmentDto.FileKey);
                
                _logger.LogInformation("User {UserId} uploaded and linked new avatar. FileKey: {FileKey}", userId, attachmentDto.FileKey);
                
                // Получаем и возвращаем обновленный UserDto
                var updatedUserDto = await _userService.GetByIdAsync(userId);
                if (updatedUserDto == null)
                {
                    // Этого не должно произойти, если UpdateUserAvatarAsync не выбросил исключение и пользователь существует
                    _logger.LogError("User {UserId} not found after avatar update.", userId);
                    return NotFound(new { message = "User not found after avatar update." }); 
                }
                
                return Ok(updatedUserDto); // Возвращаем полный UserDto
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
                _logger.LogError(ex, "Error uploading avatar for user {UserId}.", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred during avatar upload." });
            }
        }

        [Authorize]
        [HttpGet("search")]
        public async Task<ActionResult<IEnumerable<UserSimpleDto>>> SearchUsers([FromQuery] string query)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return Ok(Enumerable.Empty<UserSimpleDto>()); // Возвращаем пустой список, если запрос пуст
            }

            var users = await _userService.SearchUsersAsync(query);
            return Ok(users);
        }
    }
}