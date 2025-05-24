namespace SigmailServer.Application.DTOs;

public class AuthResultDto {
    public UserDto User { get; set; }
    public string AccessToken { get; set; }
    public DateTime AccessTokenExpiration { get; set; }
    public string RefreshToken { get; set; }
}