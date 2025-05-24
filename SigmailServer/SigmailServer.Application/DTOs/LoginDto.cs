namespace SigmailServer.Application.DTOs;


public class LoginDto {
    public string UsernameOrEmail { get; set; }
    public string Password { get; set; }
}