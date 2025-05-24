namespace SigmailServer.Application.Services.Interfaces;

public interface IPasswordHasher { string HashPassword(string password); bool VerifyPassword(string hashedPassword, string providedPassword); }