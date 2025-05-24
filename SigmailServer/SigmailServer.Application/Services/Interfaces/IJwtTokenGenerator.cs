using SigmailClient.Domain.Models;

namespace SigmailServer.Application.Services.Interfaces;

public interface IJwtTokenGenerator { (string accessToken, DateTime accessTokenExpiration, string refreshToken) GenerateTokens(User user); }