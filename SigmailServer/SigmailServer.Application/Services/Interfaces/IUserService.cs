using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.Services.Interfaces;

public interface IUserService {
    Task<UserDto?> GetByIdAsync(Guid id);
    // RegisterAsync лучше перенести в IAuthService
    // Task<UserDto> RegisterAsync(CreateUserDto dto); // Переместить в IAuthService
    Task UpdateOnlineStatusAsync(Guid id, bool isOnline, string? deviceToken = null);
    Task<IEnumerable<UserDto>> GetOnlineUsersAsync(); // Для кого это? Для админа? Для друзей?
    Task<UserDto?> GetByUsernameAsync(string username); // Полезно
    Task<IEnumerable<UserDto>> SearchUsersAsync(string searchTerm, Guid currentUserId); // Для поиска контактов
    Task UpdateUserProfileAsync(Guid userId, UpdateUserProfileDto dto); // Новый
    // Task UpdateUserAvatarAsync(Guid userId, Stream avatarStream, string contentType); // Новый (работа с файлом)
}