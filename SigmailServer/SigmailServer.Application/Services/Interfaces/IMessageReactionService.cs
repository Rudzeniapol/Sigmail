using SigmailServer.Application.DTOs; // Для ReactionDto, если он будет возвращаться
using SigmailServer.Domain.Models; // Для Reaction

namespace SigmailServer.Application.Services.Interfaces;

public interface IMessageReactionService
{
    /// <summary>
    /// Adds a reaction from a user to a message.
    /// If the emoji reaction already exists, the user is added to it.
    /// If the user has already reacted with this emoji, the operation might be idempotent or throw an exception (TBD).
    /// </summary>
    /// <param name="messageId">The ID of the message to react to.</param>
    /// <param name="userId">The ID of the user adding the reaction.</param>
    /// <param name="emoji">The emoji string for the reaction.</param>
    /// <returns>The updated list of reactions for the message, or a success/failure indicator.</returns>
    Task<IEnumerable<ReactionDto>> AddReactionAsync(string messageId, Guid userId, string emoji);

    /// <summary>
    /// Removes a reaction from a user from a message.
    /// If the user is the last one to react with this emoji, the emoji reaction might be removed entirely.
    /// </summary>
    /// <param name="messageId">The ID of the message.</param>
    /// <param name="userId">The ID of the user whose reaction is to be removed.</param>
    /// <param name="emoji">The emoji string for the reaction to remove.</param>
    /// <returns>The updated list of reactions for the message, or a success/failure indicator.</returns>
    Task<IEnumerable<ReactionDto>> RemoveReactionAsync(string messageId, Guid userId, string emoji);
} 