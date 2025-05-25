using System.Security.Claims;
using Microsoft.AspNetCore.SignalR;

namespace SigmailServer;

public class NameIdentifierUserIdProvider : IUserIdProvider
{
    public virtual string? GetUserId(HubConnectionContext connection)
    {
        return connection.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    }
}