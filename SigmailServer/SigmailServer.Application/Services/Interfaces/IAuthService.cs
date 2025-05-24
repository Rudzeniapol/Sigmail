using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResultDto> RegisterAsync(CreateUserDto dto);
    Task<AuthResultDto> LoginAsync(LoginDto dto);
    Task<AuthResultDto?> RefreshTokenAsync(RefreshTokenDto dto);
    Task LogoutAsync(Guid userId, string refreshToken); // Опционально, для инвалидации refresh токена
    // Task RequestPasswordResetAsync(string email);
    // Task ResetPasswordAsync(ResetPasswordDto dto);
}