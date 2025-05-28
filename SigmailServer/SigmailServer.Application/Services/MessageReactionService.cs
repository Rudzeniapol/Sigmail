using AutoMapper;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;
using Microsoft.Extensions.Logging; // Для логирования
using SigmailServer.Domain.Exceptions; // <--- ВОЗВРАЩАЕМ USING

namespace SigmailServer.Application.Services;

public class MessageReactionService : IMessageReactionService
{
    private readonly IMessageRepository _messageRepository;
    private readonly IUnitOfWork _unitOfWork; // Для MongoDB это может быть "пустышка", но если есть транзакционность...
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier; // Для уведомлений через SignalR
    private readonly ILogger<MessageReactionService> _logger;
    private readonly IChatRepository _chatRepository; // Для получения chatId

    public MessageReactionService(
        IMessageRepository messageRepository, 
        IUnitOfWork unitOfWork, 
        IMapper mapper, 
        IRealTimeNotifier realTimeNotifier,
        ILogger<MessageReactionService> logger,
        IChatRepository chatRepository)
    {
        _messageRepository = messageRepository;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _chatRepository = chatRepository;
    }

    public async Task<IEnumerable<ReactionDto>> AddReactionAsync(string messageId, Guid userId, string emoji)
    {
        _logger.LogInformation("Attempting to add reaction (emoji: {Emoji}, userId: {UserId}) to message {MessageId}", emoji, userId, messageId);
        
        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null)
        {
            _logger.LogWarning("AddReactionAsync: Message with ID {MessageId} not found.", messageId);
            throw new NotFoundException($"Message with ID {messageId} not found.");
        }

        var existingReaction = message.Reactions.FirstOrDefault(r => r.Emoji == emoji);

        if (existingReaction != null)
        {
            if (!existingReaction.UserIds.Contains(userId))
            {
                existingReaction.UserIds.Add(userId);
                existingReaction.LastReactedAt = DateTime.UtcNow;
                _logger.LogInformation("User {UserId} added to existing reaction {Emoji} for message {MessageId}", userId, emoji, messageId);
            }
            else
            {
                _logger.LogInformation("User {UserId} already reacted with {Emoji} to message {MessageId}. No changes made.", userId, emoji, messageId);
                // Можно просто вернуть текущие реакции без изменений или считать это успехом
                // return _mapper.Map<IEnumerable<ReactionDto>>(message.Reactions); // Если ничего не изменилось
            }
        }
        else
        {
            message.Reactions.Add(new Reaction(emoji, userId));
            _logger.LogInformation("New reaction {Emoji} by user {UserId} added to message {MessageId}", emoji, userId, messageId);
        }

        await _messageRepository.UpdateAsync(message);
        // await _unitOfWork.SaveChangesAsync(); // Если бы это был EF Core для Message
        _logger.LogInformation("Message {MessageId} updated in repository with new reaction info.", messageId);

        var updatedReactionsDto = _mapper.Map<IEnumerable<ReactionDto>>(message.Reactions);
        
        // Уведомление клиентов через SignalR
        // Нам нужен ChatId, чтобы отправить уведомление в нужную группу
        // Предположим, что MessageModel содержит ChatId. Если нет, нужно его получить.
        // В текущей Message.cs ChatId есть.
        await _realTimeNotifier.NotifyMessageReactionsUpdatedAsync(message.ChatId.ToString(), messageId, updatedReactionsDto);
        _logger.LogInformation("SignalR notification sent for reaction update on message {MessageId} in chat {ChatId}", messageId, message.ChatId);

        return updatedReactionsDto;
    }

    public async Task<IEnumerable<ReactionDto>> RemoveReactionAsync(string messageId, Guid userId, string emoji)
    {
        _logger.LogInformation("Attempting to remove reaction (emoji: {Emoji}, userId: {UserId}) from message {MessageId}", emoji, userId, messageId);

        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null)
        {
            _logger.LogWarning("RemoveReactionAsync: Message with ID {MessageId} not found.", messageId);
            throw new NotFoundException($"Message with ID {messageId} not found.");
        }

        var reactionToRemove = message.Reactions.FirstOrDefault(r => r.Emoji == emoji);

        if (reactionToRemove != null)
        {
            bool userRemoved = reactionToRemove.UserIds.Remove(userId);
            if (userRemoved)
            {
                _logger.LogInformation("User {UserId}'s reaction {Emoji} removed from message {MessageId}", userId, emoji, messageId);
                if (reactionToRemove.UserIds.Count == 0)
                {
                    message.Reactions.Remove(reactionToRemove);
                    _logger.LogInformation("Emoji reaction {Emoji} entirely removed from message {MessageId} as no users are left.", emoji, messageId);
                }
                else
                {
                    // Обновить LastReactedAt, если это важно (кто последний убрал - не так важно, как кто последний добавил)
                    // reactionToRemove.LastReactedAt = DateTime.UtcNow; 
                }
                
                await _messageRepository.UpdateAsync(message);
                // await _unitOfWork.SaveChangesAsync();
                _logger.LogInformation("Message {MessageId} updated in repository after reaction removal.", messageId);

                var updatedReactionsDto = _mapper.Map<IEnumerable<ReactionDto>>(message.Reactions);
                await _realTimeNotifier.NotifyMessageReactionsUpdatedAsync(message.ChatId.ToString(), messageId, updatedReactionsDto);
                _logger.LogInformation("SignalR notification sent for reaction removal on message {MessageId} in chat {ChatId}", messageId, message.ChatId);
                return updatedReactionsDto;
            }
            else
            {
                _logger.LogInformation("User {UserId} had not reacted with {Emoji} to message {MessageId}. No changes made.", userId, emoji, messageId);
            }
        }
        else
        {
            _logger.LogInformation("Reaction with emoji {Emoji} not found on message {MessageId}. No changes made.", emoji, messageId);
        }
        
        // Если ничего не изменилось, возвращаем текущее состояние реакций
        return _mapper.Map<IEnumerable<ReactionDto>>(message.Reactions);
    }
} 