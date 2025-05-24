namespace SigmailClient.Domain.Enums;

public enum NotificationType
{
    NewMessage,
    MessageEdited,
    MessageRead,
    ChatCreated,
    MemberJoined,
    MemberLeft,
    ReactionAdded,
    ContactRequestReceived, // Добавлено
    ContactRequestAccepted, // Добавлено (возможно, более подходящее имя, чем Responded)
    ContactRequestDeclined, // Добавлено (для полноты)
    ContactRemoved,         // Добавлено (для TODO: Optionally notify contactUserIdToRemove that they were removed)
    UserProfileUpdated    // Добавлено (для TODO: Уведомить контактов об изменении данных (имени пользователя))
    // ... другие типы уведомлений
}