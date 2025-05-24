using System.Security.Authentication;
using AutoMapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class AuthService : IAuthService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;
    private readonly ILogger<AuthService> _logger;
    private readonly IConfiguration _configuration; // Для срока действия Refresh Token

    public AuthService(
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IPasswordHasher passwordHasher,
        IJwtTokenGenerator jwtTokenGenerator,
        ILogger<AuthService> logger,
        IConfiguration configuration) // Добавлен IConfiguration
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _passwordHasher = passwordHasher;
        _jwtTokenGenerator = jwtTokenGenerator;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<AuthResultDto> RegisterAsync(CreateUserDto dto)
    {
        _logger.LogInformation("Attempting to register user {Username}", dto.Username);

        if (string.IsNullOrWhiteSpace(dto.Username) || string.IsNullOrWhiteSpace(dto.Email) || string.IsNullOrWhiteSpace(dto.Password))
        {
            throw new ArgumentException("Username, email, and password are required.");
        }

        if (await _unitOfWork.Users.GetByUsernameAsync(dto.Username) != null)
        {
            _logger.LogWarning("Registration failed: Username {Username} already exists.", dto.Username);
            throw new ArgumentException("Username already exists.");
        }
        if (await _unitOfWork.Users.GetByEmailAsync(dto.Email) != null)
        {
            _logger.LogWarning("Registration failed: Email {Email} already exists.", dto.Email);
            throw new ArgumentException("Email already exists.");
        }

        var passwordHash = _passwordHasher.HashPassword(dto.Password);
        var user = new User(dto.Username, dto.Email, passwordHash); // Конструктор User должен это поддерживать

        await _unitOfWork.Users.AddAsync(user);
        // CommitAsync здесь может быть преждевременным, если генерация токена или установка RT требуют новой транзакции
        // Однако, для простоты, оставим пока так. В идеале, RT сохраняется после успешной генерации.

        var (accessToken, accessTokenExpiration, refreshToken) = _jwtTokenGenerator.GenerateTokens(user);
        
        var refreshTokenValidityInDays = _configuration.GetValue<int>("Jwt:RefreshTokenValidityInDays", 7);
        user.SetRefreshToken(refreshToken, DateTime.UtcNow.AddDays(refreshTokenValidityInDays));
        
        // Обновляем пользователя с RT. Если AddAsync уже вызвал SaveChanges (в MongoDB), то Update может быть не нужен,
        // но для EF Core (PostgreSQL) - нужен. UnitOfWork должен это разрулить.
        await _unitOfWork.Users.UpdateAsync(user); 
        await _unitOfWork.CommitAsync(); // Финальный коммит

        _logger.LogInformation("User {Username} registered successfully with ID {UserId}", dto.Username, user.Id);
        return new AuthResultDto
        {
            User = _mapper.Map<UserDto>(user),
            AccessToken = accessToken,
            AccessTokenExpiration = accessTokenExpiration,
            RefreshToken = refreshToken
        };
    }

    public async Task<AuthResultDto> LoginAsync(LoginDto dto)
    {
        _logger.LogInformation("Attempting to login user {UsernameOrEmail}", dto.UsernameOrEmail);
        if (string.IsNullOrWhiteSpace(dto.UsernameOrEmail) || string.IsNullOrWhiteSpace(dto.Password))
        {
            throw new ArgumentException("Username/Email and password are required.");
        }

        var user = await _unitOfWork.Users.GetByUsernameAsync(dto.UsernameOrEmail) 
                   ?? await _unitOfWork.Users.GetByEmailAsync(dto.UsernameOrEmail);

        if (user == null || !_passwordHasher.VerifyPassword(user.PasswordHash, dto.Password))
        {
            _logger.LogWarning("Login failed for {UsernameOrEmail}: Invalid credentials", dto.UsernameOrEmail);
            throw new InvalidCredentialException("Invalid username or password.");
        }

        var (accessToken, accessTokenExpiration, refreshToken) = _jwtTokenGenerator.GenerateTokens(user);
        
        var refreshTokenValidityInDays = _configuration.GetValue<int>("Jwt:RefreshTokenValidityInDays", 7);
        user.SetRefreshToken(refreshToken, DateTime.UtcNow.AddDays(refreshTokenValidityInDays));
        user.GoOnline(); // Обновляем статус

        await _unitOfWork.Users.UpdateAsync(user);
        await _unitOfWork.CommitAsync();

        _logger.LogInformation("User {UsernameOrEmail} (ID: {UserId}) logged in successfully", dto.UsernameOrEmail, user.Id);
        return new AuthResultDto
        {
            User = _mapper.Map<UserDto>(user),
            AccessToken = accessToken,
            AccessTokenExpiration = accessTokenExpiration,
            RefreshToken = refreshToken
        };
    }

    public async Task<AuthResultDto?> RefreshTokenAsync(RefreshTokenDto dto)
    {
        _logger.LogInformation("Attempting to refresh token");
        if (string.IsNullOrWhiteSpace(dto.Token))
        {
            throw new ArgumentException("Refresh token is required.");
        }

        var user = await _unitOfWork.Users.GetByRefreshTokenAsync(dto.Token);

        if (user == null || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
        {
            _logger.LogWarning("Refresh token failed: Invalid or expired token.");
            if(user != null) // Если токен был, но истек, чистим его
            {
                user.ClearRefreshToken();
                await _unitOfWork.Users.UpdateAsync(user);
                await _unitOfWork.CommitAsync();
            }
            return null; // Или выбросить исключение
        }

        var (newAccessToken, newAccessTokenExpiration, newRefreshToken) = _jwtTokenGenerator.GenerateTokens(user);
        
        var refreshTokenValidityInDays = _configuration.GetValue<int>("Jwt:RefreshTokenValidityInDays", 7);
        user.SetRefreshToken(newRefreshToken, DateTime.UtcNow.AddDays(refreshTokenValidityInDays));
        
        await _unitOfWork.Users.UpdateAsync(user);
        await _unitOfWork.CommitAsync();

        _logger.LogInformation("Token refreshed successfully for user {UserId}", user.Id);
        return new AuthResultDto
        {
            User = _mapper.Map<UserDto>(user),
            AccessToken = newAccessToken,
            AccessTokenExpiration = newAccessTokenExpiration,
            RefreshToken = newRefreshToken
        };
    }

    public async Task LogoutAsync(Guid userId, string refreshTokenToInvalidate)
    {
        _logger.LogInformation("User {UserId} logging out", userId);
        var user = await _unitOfWork.Users.GetByIdAsync(userId);
        if (user != null)
        {
            // Инвалидируем только если предоставленный RT совпадает с текущим у пользователя
            if(user.RefreshToken == refreshTokenToInvalidate)
            {
                 user.ClearRefreshToken();
            }
            user.GoOffline(); // В любом случае ставим оффлайн
            await _unitOfWork.Users.UpdateAsync(user);
            await _unitOfWork.CommitAsync();
            _logger.LogInformation("User {UserId} processed logout. Refresh token cleared if matched.", userId);
        }
        else
        {
            _logger.LogWarning("Logout for user {UserId}: User not found.", userId);
        }
    }
}