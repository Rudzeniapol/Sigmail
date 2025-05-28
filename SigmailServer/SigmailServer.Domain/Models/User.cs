using System.ComponentModel.DataAnnotations;

namespace SigmailServer.Domain.Models;

public class User {
    [Key]
    public Guid Id { get; private set; } = Guid.NewGuid(); // Можно инициализировать здесь, если EF Core позволяет

    [Required]
    [MaxLength(50)]
    public string Username { get; private set; } = null!;

    [Required]
    [EmailAddress]
    [MaxLength(100)]
    public string Email { get; private set; } = null!;

    [Required]
    [MaxLength(256)] // Убедитесь, что достаточно для хеша
    public string PasswordHash { get; private set; } = null!;

    [Phone] // Атрибут для валидации номера телефона
    [MaxLength(20)] // Максимальная длина для номера телефона (с учетом международного формата)
    public string? PhoneNumber { get; private set; }
    
    [MaxLength(256)]
    public string? ProfileImageUrl { get; set; } // URL или ключ к аватару пользователя

    [MaxLength(200)]
    public string? Bio { get; set; }

    public bool IsOnline { get; set; }
    public DateTime LastSeen { get; set; } = DateTime.UtcNow;
    public string? CurrentDeviceToken { get; set; } // Для push-уведомлений

    // Для Refresh Token
    public string? RefreshToken { get; private set; }
    public DateTime? RefreshTokenExpiryTime { get; private set; }


    private User() { } // Для EF Core

    public User(string username, string email, string passwordHash, string? phoneNumber = null) {
        // Id генерируется автоматически или передается, если вы управляете этим снаружи
        Username = username;
        Email = email;
        PasswordHash = passwordHash;
        PhoneNumber = phoneNumber;
        IsOnline = false;
        LastSeen = DateTime.UtcNow;
    }
    // Конструктор для гидрации из БД, если Id уже есть
    public User(Guid id, string username, string email, string passwordHash, string? phoneNumber = null) : this(username, email, passwordHash, phoneNumber)
    {
        Id = id;
    }


    public void UpdatePassword(string newPasswordHash)
    {
        PasswordHash = newPasswordHash;
    }

    public void UpdateProfile(string? newUsername, string? newEmail, string? newBio, string? newProfileImageUrl, string? newPhoneNumber = null)
    {
        if (!string.IsNullOrWhiteSpace(newUsername)) Username = newUsername;
        if (!string.IsNullOrWhiteSpace(newEmail)) Email = newEmail; // Добавить валидацию email
        if (!string.IsNullOrWhiteSpace(newPhoneNumber)) PhoneNumber = newPhoneNumber;
        Bio = newBio; // Может быть null
        ProfileImageUrl = newProfileImageUrl; // Может быть null
    }

    public void SetRefreshToken(string token, DateTime expiryTime)
    {
        RefreshToken = token;
        RefreshTokenExpiryTime = expiryTime;
    }

    public void ClearRefreshToken()
    {
        RefreshToken = null;
        RefreshTokenExpiryTime = null;
    }

    public void UpdateLastSeen() {
        LastSeen = DateTime.UtcNow;
    }

    public void GoOnline(string? deviceToken = null) {
        IsOnline = true;
        CurrentDeviceToken = deviceToken; // Обновляем токен при каждом входе
        UpdateLastSeen();
    }

    public void GoOffline() {
        IsOnline = false;
        // CurrentDeviceToken можно не сбрасывать, чтобы пуши все равно доходили, если пользователь разрешил
        UpdateLastSeen();
    }
}