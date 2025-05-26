using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class MessageService : IMessageService
{
    private readonly IMessageRepository _messageRepository;
    private readonly IUnitOfWork _unitOfWork; // Для IChatRepository, IUserRepository
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<MessageService> _logger;
    private readonly INotificationService _notificationService;

    public MessageService(
        IMessageRepository messageRepository,
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<MessageService> logger,
        INotificationService notificationService) // Добавлен INotificationService
    {
        _messageRepository = messageRepository;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _notificationService = notificationService;
    }

    public async Task<MessageDto> SendMessageAsync(Guid senderId, CreateMessageDto dto)
    {
        _logger.LogInformation("User {SenderId} sending message to chat {ChatId}. Text: '{TextSnippet}'. ClientMsgId: {ClientMessageId}",
            senderId, dto.ChatId, dto.Text?.Substring(0, Math.Min(dto.Text.Length, 20)), dto.ClientMessageId);

        var chat = await _unitOfWork.Chats.GetByIdAsync(dto.ChatId);
        if (chat == null) throw new KeyNotFoundException($"Chat with ID {dto.ChatId} not found.");

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(dto.ChatId, senderId);
        if (!isMember) throw new UnauthorizedAccessException($"Sender {senderId} is not a member of chat {dto.ChatId}.");

        if (string.IsNullOrWhiteSpace(dto.Text) && (dto.Attachments == null || !dto.Attachments.Any()))
        {
            throw new ArgumentException("Message must have text or attachments.");
        }

        var message = new Message
        {
            // Id будет сгенерирован MongoDB автоматически или в конструкторе Message
            ChatId = dto.ChatId,
            SenderId = senderId,
            Text = dto.Text,
            Timestamp = DateTime.UtcNow,
            Status = MessageStatus.Sent, // Изначально Sent. Статус Delivered/Read обновляется позже.
            ForwardedFromMessageId = dto.ForwardedFromMessageId,
            // ForwardedFromUserId будет установлен, если ForwardedFromMessageId не null и сообщение переслано от другого пользователя
        };

        if (!string.IsNullOrEmpty(dto.ForwardedFromMessageId))
        {
            var originalMessage = await _messageRepository.GetByIdAsync(dto.ForwardedFromMessageId);
            if (originalMessage != null)
            {
                message.ForwardedFromUserId = originalMessage.SenderId;
            }
            else
            {
                _logger.LogWarning("Original message {ForwardedFromMessageId} for forwarding not found.", dto.ForwardedFromMessageId);
                // Можно либо бросить ошибку, либо продолжить без ForwardedFromUserId
            }
        }

        if (dto.Attachments != null && dto.Attachments.Any())
        {
            foreach (var attDto in dto.Attachments)
            {
                // Предполагается, что FileKey уже существует (файл загружен через AttachmentService, и клиент передал ключ)
                // Также предполагается, что CreateAttachmentDto содержит все необходимые поля для SigmailServer.Domain.Models.Attachment
                var attachment = _mapper.Map<SigmailClient.Domain.Models.Attachment>(attDto);
                message.Attachments.Add(attachment);
            }
        }

        await _messageRepository.AddAsync(message);
        // После добавления сообщения в MongoDB, message.Id должен быть заполнен.

        // Обновляем LastMessageId в чате (хранится в PostgreSQL)
        await _unitOfWork.Chats.UpdateLastMessageAsync(dto.ChatId, message.Id);
        await _unitOfWork.CommitAsync(); // Сохраняем изменения в PostgreSQL (Chat.LastMessageId)

        var messageDto = await MapMessageToDtoAsync(message); // Используем вспомогательный метод

        // Уведомляем всех участников чата о новом сообщении
        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(dto.ChatId);
        var memberIdsToNotify = chatMembers.Select(m => m.Id).ToList();

        foreach (var memberId in memberIdsToNotify)
        {
            // Отправляем real-time уведомление о новом сообщении
            await _realTimeNotifier.NotifyMessageReceivedAsync(memberId, messageDto);

            // Создаем персистентное уведомление для тех, кто не отправитель
            if (memberId != senderId)
            {
                var senderUser = await _unitOfWork.Users.GetByIdAsync(senderId);
                await _notificationService.CreateAndSendNotificationAsync(
                    memberId,
                    NotificationType.NewMessage,
                    $"{(senderUser?.Username ?? "Someone")}: {messageDto.Text?.Substring(0, Math.Min(messageDto.Text?.Length ?? 0, 50)) ?? "Attachment"}",
                    $"New message in {(chat?.Name ?? "chat")}", // Используем 'chat' который был загружен ранее
                    message.Id, 
                    "Message"
                );
            }
        }
        
        // Теперь уведомим об обновлении самого чата (например, для обновления LastMessage в списке чатов)
        var updatedChatEntity = await _unitOfWork.Chats.GetByIdAsync(dto.ChatId); 
        if (updatedChatEntity != null)
        {
            ChatDto chatDtoForUpdate = _mapper.Map<ChatDto>(updatedChatEntity);
            
            // Устанавливаем только что отправленное сообщение как последнее в DTO для SignalR уведомления
            // так как updatedChatEntity.LastMessageId был только что обновлен этим сообщением.
            chatDtoForUpdate.LastMessage = messageDto; 
            // Также убедимся, что основные поля чата, которые могли измениться (как UpdatedAt), присутствуют
            // AutoMapper должен был перенести updatedChatEntity.UpdatedAt в chatDtoForUpdate.UpdatedAt
            // Если нет, то chatDtoForUpdate.UpdatedAt = updatedChatEntity.UpdatedAt;

            // Обновляем список участников в DTO, если он маппится и важен для клиента при ChatDetailsUpdated
            // Это зависит от того, как настроен AutoMapper и что ожидает клиент от ChatDetailsUpdated
            // var membersForDto = await _unitOfWork.Chats.GetChatMembersAsync(dto.ChatId);
            // chatDtoForUpdate.Members = _mapper.Map<List<UserSimpleDto>>(membersForDto);
            // chatDtoForUpdate.MemberCount = membersForDto.Count;
            // Если _mapper.Map<ChatDto>(updatedChatEntity) уже корректно заполняет members и memberCount, то выше не нужно.

            foreach (var memberId in memberIdsToNotify) // Используем тот же список участников
            {
                await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(new List<Guid> { memberId }, chatDtoForUpdate); // Отправляем каждому индивидуально, если метод принимает List
                                                                                                                  // Или если NotifyChatDetailsUpdatedAsync может принять IEnumerable<Guid> сразу:
                                                                                                                  // await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(memberIdsToNotify, chatDtoForUpdate);
                                                                                                                  // Судя по интерфейсу IRealTimeNotifier, он принимает List<Guid> memberIds
            }
            // Если NotifyChatDetailsUpdatedAsync принимает IEnumerable или List:
            await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(memberIdsToNotify, chatDtoForUpdate);

            _logger.LogInformation("Chat {ChatId} details update notification sent to {MemberCount} members.", dto.ChatId, memberIdsToNotify.Count);
        }
        else
        {
            _logger.LogWarning("Chat {ChatId} not found after update for sending ChatDetailsUpdated notification.", dto.ChatId);
        }

        _logger.LogInformation("Message {MessageId} sent by {SenderId} to chat {ChatId}. Notified {MemberCount} members for new message.", message.Id, senderId, dto.ChatId, memberIdsToNotify.Count);
        return messageDto;
    }

    public async Task<MessageDto> CreateMessageWithAttachmentAsync(Guid senderId, CreateMessageWithAttachmentDto dto)
    {
        _logger.LogInformation("User {SenderId} creating message with attachment in chat {ChatId}. FileKey: {FileKey}, FileName: {FileName}",
            senderId, dto.ChatId, dto.FileKey, dto.FileName);

        var chat = await _unitOfWork.Chats.GetByIdAsync(dto.ChatId);
        if (chat == null) throw new KeyNotFoundException($"Chat with ID {dto.ChatId} not found.");

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(dto.ChatId, senderId);
        if (!isMember) throw new UnauthorizedAccessException($"Sender {senderId} is not a member of chat {dto.ChatId}.");

        if (string.IsNullOrWhiteSpace(dto.FileKey) || string.IsNullOrWhiteSpace(dto.FileName))
        {
            throw new ArgumentException("FileKey and FileName are required for messages with attachments.");
        }

        var attachment = new SigmailClient.Domain.Models.Attachment
        {
            FileKey = dto.FileKey,
            FileName = dto.FileName,
            ContentType = dto.ContentType,
            Size = dto.FileSize,
            Type = dto.AttachmentType,
            Width = dto.Width,
            Height = dto.Height,
            ThumbnailKey = dto.ThumbnailKey
            // Другие поля Attachment, если они есть и приходят из DTO, можно добавить здесь
        };

        var message = new Message
        {
            ChatId = dto.ChatId,
            SenderId = senderId,
            Timestamp = DateTime.UtcNow,
            Status = MessageStatus.Sent, // Изначально Sent
            Attachments = new List<SigmailClient.Domain.Models.Attachment> { attachment }
            // Text может быть null или пустым для сообщений только с вложениями
        };

        await _messageRepository.AddAsync(message);
        await _unitOfWork.Chats.UpdateLastMessageAsync(dto.ChatId, message.Id);
        await _unitOfWork.CommitAsync();

        var messageDto = await MapMessageToDtoAsync(message);

        // Уведомляем всех участников чата о новом сообщении
        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(dto.ChatId);
        var memberIdsToNotify = chatMembers.Select(m => m.Id).ToList();

        foreach (var memberId in memberIdsToNotify)
        {
            await _realTimeNotifier.NotifyMessageReceivedAsync(memberId, messageDto);

            if (memberId != senderId)
            {
                 var senderUser = await _unitOfWork.Users.GetByIdAsync(senderId);
                 var notificationText = $"{(senderUser?.Username ?? "Someone")} sent an attachment: {dto.FileName}";
                 var notificationTitle = $"New attachment in {(chat?.Name ?? "chat")}";
                
                await _notificationService.CreateAndSendNotificationAsync(
                    memberId,
                    NotificationType.NewMessage, // Или можно создать NotificationType.NewAttachment
                    notificationText,
                    notificationTitle,
                    message.Id,
                    "Message" 
                );
            }
        }
        
        // Уведомляем об обновлении чата (LastMessage)
        var updatedChatEntity = await _unitOfWork.Chats.GetByIdAsync(dto.ChatId);
        if (updatedChatEntity != null)
        {
            ChatDto chatDtoForUpdate = _mapper.Map<ChatDto>(updatedChatEntity);
            chatDtoForUpdate.LastMessage = messageDto;

            // ДОБАВИТЬ ЭТИ ЛОГИ:
            _logger.LogInformation("PRE-NOTIFICATION LOG for Chat {ChatId}: LastMessage.Id='{LastMessageId}', HasAttachments={HasAttachments}", 
                chatDtoForUpdate.Id, 
                chatDtoForUpdate.LastMessage?.Id, 
                chatDtoForUpdate.LastMessage?.Attachments?.Any());
            if (chatDtoForUpdate.LastMessage?.Attachments != null)
            {
                foreach (var att in chatDtoForUpdate.LastMessage.Attachments)
                {
                    _logger.LogInformation("PRE-NOTIFICATION LOG Attachment for Chat {ChatId}: FileKey='{FileKey}', FileName='{FileName}'", 
                        chatDtoForUpdate.Id, att.FileKey, att.FileName);
                }
            }
            // КОНЕЦ ДОБАВЛЕННЫХ ЛОГОВ
            
            // Код для NotifyChatDetailsUpdatedAsync аналогичен тому, что в SendMessageAsync
            await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(memberIdsToNotify, chatDtoForUpdate);
             _logger.LogInformation("Chat {ChatId} details update notification sent to {MemberCount} members after attachment message.", dto.ChatId, memberIdsToNotify.Count);
        }


        _logger.LogInformation("Message {MessageId} with attachment {FileKey} created by {SenderId} in chat {ChatId}. Notified {MemberCount} members.", 
            message.Id, dto.FileKey, senderId, dto.ChatId, memberIdsToNotify.Count);
            
        return messageDto;
    }

    private async Task<MessageDto> MapMessageToDtoAsync(Message message)
    {
        if (message == null) return null;

        var dto = _mapper.Map<MessageDto>(message);
        if (message.SenderId != Guid.Empty)
        {
            var sender = await _unitOfWork.Users.GetByIdAsync(message.SenderId);
            dto.Sender = _mapper.Map<UserSimpleDto>(sender);
        }
        // Маппинг вложений и реакций обычно делается AutoMapper'ом, если профили настроены
        return dto;
    }
    
    private async Task<IEnumerable<MessageDto>> MapMessagesToDtoAsync(IEnumerable<Message> messages)
    {
        if (messages == null || !messages.Any()) return Enumerable.Empty<MessageDto>();
        
        var senderIds = messages.Select(m => m.SenderId).Where(id => id != Guid.Empty).Distinct().ToList();
        var senders = new Dictionary<Guid, UserSimpleDto>();
        if(senderIds.Any())
        {
            var senderUsers = await _unitOfWork.Users.GetManyByIdsAsync(senderIds); // TODO: Заменить на GetUsersByIdsAsync(senderIds)
            senders = senderUsers.Where(u => senderIds.Contains(u.Id))
                                 .ToDictionary(u => u.Id, u => _mapper.Map<UserSimpleDto>(u));
        }

        var dtos = new List<MessageDto>();
        foreach(var message in messages)
        {
            var dto = _mapper.Map<MessageDto>(message);
            if (message.SenderId != Guid.Empty && senders.TryGetValue(message.SenderId, out var senderDto))
            {
                dto.Sender = senderDto;
            }
            dtos.Add(dto);
        }
        return dtos;
    }


    public async Task<IEnumerable<MessageDto>> GetMessagesAsync(Guid chatId, Guid currentUserId, int page = 1, int pageSize = 20)
    {
        _logger.LogInformation("User {CurrentUserId} requesting messages for chat {ChatId}, Page: {Page}, PageSize: {PageSize}", currentUserId, chatId, page, pageSize);
        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(chatId, currentUserId);
        if (!isMember) throw new UnauthorizedAccessException($"User {currentUserId} is not a member of chat {chatId}.");

        var messages = await _messageRepository.GetByChatAsync(chatId, page, pageSize);
        return await MapMessagesToDtoAsync(messages);
    }

    public async Task<MessageDto?> GetMessageByIdAsync(string id, Guid currentUserId)
    {
        _logger.LogInformation("User {CurrentUserId} requesting message {MessageId}", currentUserId, id);
        var message = await _messageRepository.GetByIdAsync(id);
        if (message == null)
        {
            _logger.LogWarning("Message {MessageId} not found.", id);
            return null;
        }

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(message.ChatId, currentUserId);
        if (!isMember) throw new UnauthorizedAccessException($"User {currentUserId} is not a member of the chat {message.ChatId} this message belongs to.");

        return await MapMessageToDtoAsync(message);
    }

    public async Task EditMessageAsync(string messageId, Guid editorUserId, string newText)
    {
        _logger.LogInformation("User {EditorUserId} editing message {MessageId} with new text: '{NewTextSnippet}'", editorUserId, messageId, newText.Substring(0, Math.Min(newText.Length, 20)));
        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message {messageId} not found.");
        if (message.SenderId != editorUserId) throw new UnauthorizedAccessException($"User {editorUserId} cannot edit message {messageId} (not sender).");
        
        // TODO: Проверить, не истекло ли время на редактирование (например, 24 часа)
        // if ((DateTime.UtcNow - message.Timestamp).TotalHours > 24)
        // {
        //     throw new InvalidOperationException("Message can no longer be edited.");
        // }
        if (message.IsDeleted) throw new InvalidOperationException("Cannot edit a deleted message.");
        if (message.Text == newText)
        {
            _logger.LogInformation("Message {MessageId} text is the same. No edit performed.", messageId);
            return; // Нет изменений
        }

        message.Edit(newText); // Метод в доменной модели Message
        await _messageRepository.UpdateAsync(message);

        var messageDto = await MapMessageToDtoAsync(message);

        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(message.ChatId);
        var memberIds = chatMembers.Select(m => m.Id).ToList();
        await _realTimeNotifier.NotifyMessageEditedAsync(memberIds, messageDto);
        _logger.LogInformation("Message {MessageId} edited successfully by {EditorUserId}.", messageId, editorUserId);
    }

    public async Task DeleteMessageAsync(string messageId, Guid deleterUserId)
    {
        _logger.LogInformation("User {DeleterUserId} attempting to delete message {MessageId}", deleterUserId, messageId);
        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message {messageId} not found.");
        if (message.IsDeleted)
        {
            _logger.LogInformation("Message {MessageId} is already deleted.", messageId);
            return;
        }

        // Проверка прав на удаление:
        // 1. Отправитель сообщения.
        // 2. Админ/Владелец чата (если есть такие права в бизнес-логике).
        var member = await _unitOfWork.Chats.GetChatMemberAsync(message.ChatId, deleterUserId);
        bool canDelete = message.SenderId == deleterUserId || 
                         (member != null && (member.Role == ChatMemberRole.Admin || member.Role == ChatMemberRole.Owner));
                         // TODO: Добавить более гранулярные права для админов (может ли админ удалять чужие сообщения).

        if (!canDelete)
        {
            throw new UnauthorizedAccessException($"User {deleterUserId} cannot delete message {messageId}.");
        }

        message.SoftDelete(); // Метод в доменной модели Message
        await _messageRepository.UpdateAsync(message); 

        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(message.ChatId);
        var memberIds = chatMembers.Select(m => m.Id).ToList();
        await _realTimeNotifier.NotifyMessageDeletedAsync(memberIds, messageId, message.ChatId);
        _logger.LogInformation("Message {MessageId} soft-deleted successfully by {DeleterUserId}.", messageId, deleterUserId);
    }

    public async Task MarkMessageAsReadAsync(string messageId, Guid readerUserId, Guid chatId)
    {
        _logger.LogDebug("User {ReaderUserId} marked message {MessageId} in chat {ChatId} as read (attempt)", readerUserId, messageId, chatId);
        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message {messageId} not found.");
        if (message.ChatId != chatId) throw new ArgumentException($"Message {messageId} does not belong to chat {chatId}.");
        
        // Отправитель не "читает" свои сообщения в контексте этого события.
        // Прочитанным оно становится для других.
        if (message.SenderId == readerUserId && !message.ReadBy.Any(id => id != readerUserId) ) 
        {
            // Если это сообщение от самого себя и его еще никто другой не прочитал - ничего не делаем
            // Или если это личный чат "с самим собой" (Избранное), то можно помечать прочитанным.
            // Пока упростим: свои сообщения не помечаем через этот эндпоинт.
            return;
        }

        bool alreadyRead = message.ReadBy.Contains(readerUserId);
        if (!alreadyRead)
        {
            // Метод MarkMessageAsReadByAsync в репозитории должен атомарно добавить readerUserId в список ReadBy.
            await _messageRepository.MarkMessageAsReadByAsync(messageId, readerUserId);
             _logger.LogInformation("Message {MessageId} marked as read by {ReaderUserId} in chat {ChatId}.", messageId, readerUserId, chatId);

            // Обновляем статус сообщения на Read, если все получатели его прочитали (в личном чате - один получатель)
            // Это более сложная логика.
            var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
            if (chat != null && chat.Type == ChatType.Private)
            {
                var members = await _unitOfWork.Chats.GetChatMembersAsync(chatId);
                var otherMember = members.FirstOrDefault(m => m.Id != message.SenderId);
                if (otherMember != null && otherMember.Id == readerUserId) // Если прочитал единственный получатель
                {
                    var freshMessage = await _messageRepository.GetByIdAsync(messageId); // Получаем обновленное сообщение
                    if(freshMessage != null && freshMessage.Status != MessageStatus.Read) // Проверяем, чтобы не перезаписать если уже Read
                    {
                        freshMessage.Status = MessageStatus.Read;
                        await _messageRepository.UpdateAsync(freshMessage); // Обновляем статус в БД
                         _logger.LogInformation("Message {MessageId} status updated to Read as recipient {ReaderUserId} read it.", messageId, readerUserId);
                    }
                }
            }
            // Для групповых чатов статус "Read" сложнее - когда все прочитали, или не используется.

            var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(chatId);
            var memberIds = chatMembers.Select(m => m.Id).ToList();
            // Уведомляем всех (включая отправителя), что сообщение прочитано конкретным пользователем
            await _realTimeNotifier.NotifyMessageReadAsync(memberIds, messageId, readerUserId, chatId);
        }
    }

    public async Task AddReactionToMessageAsync(string messageId, Guid reactorUserId, AddReactionDto reactionDto)
    {
        _logger.LogInformation("User {ReactorUserId} adding reaction '{Emoji}' to message {MessageId}", reactorUserId, reactionDto.Emoji, messageId);
        if (string.IsNullOrWhiteSpace(reactionDto.Emoji)) throw new ArgumentException("Emoji cannot be empty.");

        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message {messageId} not found.");
        if (message.IsDeleted) throw new InvalidOperationException("Cannot react to a deleted message.");

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(message.ChatId, reactorUserId);
        if (!isMember) throw new UnauthorizedAccessException($"User {reactorUserId} is not a member of chat {message.ChatId}.");

        // Метод AddReactionAsync в репозитории должен обрабатывать логику:
        // если пользователь уже ставил эту реакцию - ничего не делать,
        // если ставил другую - заменить, если не ставил - добавить.
        // Либо, как в Telegram, можно ставить несколько разных реакций. Модель MessageReactionEntry это позволяет (один юзер - один emoji).
        // Будем считать, что IMessageRepository.AddReactionAsync заменяет существующую реакцию пользователя на новую (если emoji тот же)
        // или добавляет, если это новый emoji от этого пользователя (или если одна реакция на пользователя).
        // В текущей реализации Message.Reactions это List<MessageReactionEntry>, где UserId+Emoji должны быть уникальны.
        // Допустим AddReactionAsync в репозитории это обрабатывает.
        await _messageRepository.AddReactionAsync(messageId, reactorUserId, reactionDto.Emoji);
        _logger.LogInformation("Reaction '{Emoji}' added to message {MessageId} by {ReactorUserId}.", reactionDto.Emoji, messageId, reactorUserId);

        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(message.ChatId);
        var memberIds = chatMembers.Select(m => m.Id).ToList();
        await _realTimeNotifier.NotifyMessageReactionAddedAsync(memberIds, messageId, reactorUserId, reactionDto.Emoji, message.ChatId);
    }

    public async Task RemoveReactionFromMessageAsync(string messageId, Guid reactorUserId, string emoji)
    {
        _logger.LogInformation("User {ReactorUserId} removing reaction '{Emoji}' from message {MessageId}", reactorUserId, emoji, messageId);
        if (string.IsNullOrWhiteSpace(emoji)) throw new ArgumentException("Emoji cannot be empty.");

        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message {messageId} not found.");
        // Можно удалять реакцию и с удаленного сообщения, если они еще видны.

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(message.ChatId, reactorUserId);
        if (!isMember) throw new UnauthorizedAccessException($"User {reactorUserId} is not a member of chat {message.ChatId}.");
        
        // Метод RemoveReactionAsync в репозитории должен найти и удалить соответствующую запись.
        await _messageRepository.RemoveReactionAsync(messageId, reactorUserId, emoji);
        _logger.LogInformation("Reaction '{Emoji}' removed from message {MessageId} by {ReactorUserId}.", emoji, messageId, reactorUserId);

        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(message.ChatId);
        var memberIds = chatMembers.Select(m => m.Id).ToList();
        await _realTimeNotifier.NotifyMessageReactionRemovedAsync(memberIds, messageId, reactorUserId, emoji, message.ChatId);
    }

    public async Task MarkMessagesAsDeliveredAsync(IEnumerable<string> messageIds, Guid recipientUserId)
    {
        _logger.LogDebug("Marking messages as delivered to user {RecipientUserId}. Message IDs: {MessageIdsString}", 
            recipientUserId, string.Join(",", messageIds));
        
        // Этот метод обычно вызывается, когда клиент пользователя подтверждает получение сообщений.
        // Обновляем DeliveredTo в каждом сообщении и, возможно, общий статус сообщения.
        // IMessageRepository.MarkMessagesAsDeliveredToAsync должен эффективно обновить это в БД.
        await _messageRepository.MarkMessagesAsDeliveredToAsync(messageIds, recipientUserId);

        // После обновления, возможно, нужно уведомить отправителей этих сообщений,
        // что их сообщения доставлены этому recipientUserId. Это сложная логика уведомлений.
        // Для простоты, пока не будем отправлять real-time уведомления об этом событии обратно отправителям.
        // Отправители могут получить обновленный статус сообщений при следующем запросе GetMessagesAsync.
        _logger.LogInformation("Messages ({MessageCount}) marked as delivered to {RecipientUserId}.", messageIds.Count(), recipientUserId);
    }
}