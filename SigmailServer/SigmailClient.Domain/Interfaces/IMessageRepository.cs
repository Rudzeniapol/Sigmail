using SigmailClient.Domain.Models;

namespace SigmailClient.Domain.Interfaces;

public interface IMessageRepository : IRepository<MessageMetadata>
{
    Task<IEnumerable<MessageMetadata>> GetChatMessagesAsync(
        Guid chatId, 
        int page = 1, 
        int pageSize = 50, CancellationToken cancellationToken = default);
    
    Task<IEnumerable<MessageMetadata>> SearchInChatAsync(
        Guid chatId, 
        string searchText, CancellationToken cancellationToken = default);
    
    Task MarkAsDeletedAsync(Guid messageId, CancellationToken cancellationToken = default);
}