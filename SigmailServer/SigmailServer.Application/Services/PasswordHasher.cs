using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class PasswordHasher : IPasswordHasher
{
    public string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool VerifyPassword(string hashedPassword, string providedPassword)
    {
        try
        {
            return BCrypt.Net.BCrypt.Verify(providedPassword, hashedPassword);
        }
        catch (BCrypt.Net.SaltParseException) // Обработка некорректного формата хеша
        {
            return false;
        }
    }
}