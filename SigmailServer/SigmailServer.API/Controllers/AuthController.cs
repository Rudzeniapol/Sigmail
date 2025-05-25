using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using System.Security.Authentication; // Для InvalidCredentialException
using System.Security.Claims; // Для ClaimTypes

namespace SigmailServer.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] CreateUserDto dto)
        {
            try
            {
                var result = await _authService.RegisterAsync(dto);
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Registration failed due to argument exception.");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred during registration.");
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                return Ok(result);
            }
            catch (InvalidCredentialException ex)
            {
                _logger.LogWarning(ex, "Login failed due to invalid credentials.");
                return Unauthorized(new { message = ex.Message });
            }
            catch (ArgumentException ex) // Если логин или пароль пустые
            {
                 _logger.LogWarning(ex, "Login failed due to argument exception.");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred during login.");
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("refresh-token")]
        [AllowAnonymous] // Или [Authorize] если старый access token еще валиден и нужен для каких-то проверок
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenDto dto)
        {
            try
            {
                var result = await _authService.RefreshTokenAsync(dto);
                if (result == null)
                {
                    return Unauthorized(new { message = "Invalid or expired refresh token." });
                }
                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Refresh token failed due to argument exception.");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An unexpected error occurred during token refresh.");
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout([FromBody] RefreshTokenDto? dto) // refreshToken опционален для логаута
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized(new { message = "User identifier not found in token." });
            }

            try
            {
                // Передаем токен, чтобы сервер мог попытаться инвалидировать его, если он совпадает с сохраненным.
                // Пользователь все равно выйдет из системы на стороне клиента, удалив токены.
                await _authService.LogoutAsync(userId, dto?.Token ?? string.Empty);
                return Ok(new { message = "Logged out successfully." });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred during logout for user {UserId}.", userId);
                return StatusCode(500, new { message = "An error occurred during logout." });
            }
        }
    }
}