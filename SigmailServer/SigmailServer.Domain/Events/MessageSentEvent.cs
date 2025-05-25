using SigmailClient.Domain.Events.Interfaces;

namespace SigmailClient.Domain.Events;

public class MessageSentEvent : IDomainEvent {
    public Guid MessageId { get; }
    public Guid ChatId { get; }
    public Guid SenderId { get; }
    public DateTime SentAt { get; }

    public MessageSentEvent(Guid messageId, Guid chatId, Guid senderId, DateTime sentAt) {
        MessageId = messageId;
        ChatId = chatId;
        SenderId = senderId;
        SentAt = sentAt;
    }
}