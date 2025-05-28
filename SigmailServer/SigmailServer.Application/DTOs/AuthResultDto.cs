namespace SigmailServer.Application.DTOs;

public class AuthResultDto {
    public UserDto User { get; set; } = null!;
    public string AccessToken { get; set; } = null!;
    public DateTime AccessTokenExpiration { get; set; }
    public string RefreshToken { get; set; } = null!;
}