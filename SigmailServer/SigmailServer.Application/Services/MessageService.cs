using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.Services;

public class MessageService : IMessageService
{
    private readonly IMessageRepository _messageRepository;
    private readonly IUnitOfWork _unitOfWork; // Для IChatRepository, IUserRepository
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<MessageService> _logger;
    private readonly INotificationService _notificationService;
    private readonly IUserService _userService;
    private readonly IAttachmentService _attachmentService;

    public MessageService(
        IMessageRepository messageRepository,
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<MessageService> logger,
        INotificationService notificationService,
        IUserService userService,
        IAttachmentService attachmentService) // <--- add this
    {
        _messageRepository = messageRepository;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
        _notificationService = notificationService;
        _userService = userService;
        _attachmentService = attachmentService;
    }

    public async Task<MessageDto?> SendMessageAsync(Guid senderId, CreateMessageDto dto)
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
                var attachment = _mapper.Map<Attachment>(attDto);
                message.Attachments.Add(attachment);
            }
        }

        await _messageRepository.AddAsync(message);
        // После добавления сообщения в MongoDB, message.Id должен быть заполнен.

        // Обновляем LastMessageId в чате (хранится в PostgreSQL)
        await _unitOfWork.Chats.UpdateLastMessageAsync(dto.ChatId, message.Id);
        await _unitOfWork.CommitAsync(); // Сохраняем изменения в PostgreSQL (Chat.LastMessageId)

        var messageDto = await MapMessageToDtoAsync(message, senderId); // Используем вспомогательный метод, передаем senderId как currentUserId

        // Уведомляем всех участников чата о новом сообщении
        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(dto.ChatId);
        var memberIdsToNotify = chatMembers.Select(m => m.Id).ToList();

        foreach (var memberId in memberIdsToNotify)
        {
            // Отправляем real-time уведомление о новом сообщении
            if (messageDto != null)
            {
                await _realTimeNotifier.NotifyMessageReceivedAsync(memberId, messageDto);
            }

            // Создаем персистентное уведомление для тех, кто не отправитель
            if (memberId != senderId)
            {
                var senderUser = await _unitOfWork.Users.GetByIdAsync(senderId);
                var textSnippet = messageDto?.Text?.Substring(0, Math.Min(messageDto.Text.Length, 50)) ?? "Attachment";
                await _notificationService.CreateAndSendNotificationAsync(
                    memberId,
                    NotificationType.NewMessage,
                    $"{(senderUser?.Username ?? "Someone")}: {textSnippet}",
                    $"New message in {(chat?.Name ?? "chat")}", 
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

            if (updatedChatEntity.Members != null && updatedChatEntity.Members.Any())
            {
                // Используем маппинг из ChatMember в UserSimpleDto, который уже должен быть настроен в ChatProfile
                // AutoMapper сможет смапить List<ChatMember> в List<UserSimpleDto>, если есть маппинг ChatMember -> UserSimpleDto.
                chatDtoForUpdate.Members = _mapper.Map<List<UserSimpleDto>>(updatedChatEntity.Members);
                _logger.LogInformation((Exception?)null, "MessageService: Populated chatDtoForUpdate.Members with {Count} members for chat {ChatId}", chatDtoForUpdate.Members.Count, chatDtoForUpdate.Id);
            }
            else
            {
                chatDtoForUpdate.Members = new List<UserSimpleDto>(); // Инициализируем пустым списком, если нет участников
                _logger.LogWarning((Exception?)null, "MessageService: updatedChatEntity.Members was null or empty for chat {ChatId}. Initialized chatDtoForUpdate.Members as empty list.", chatDtoForUpdate.Id);
            }

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

    public async Task<MessageDto?> CreateMessageWithAttachmentAsync(Guid senderId, CreateMessageWithAttachmentDto dto)
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

        var attachment = new Attachment
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
            Attachments = new List<Attachment> { attachment }
            // Text может быть null или пустым для сообщений только с вложениями
        };

        await _messageRepository.AddAsync(message);
        await _unitOfWork.Chats.UpdateLastMessageAsync(dto.ChatId, message.Id);
        await _unitOfWork.CommitAsync();

        var messageDto = await MapMessageToDtoAsync(message, senderId);

        // Уведомляем всех участников чата о новом сообщении
        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(dto.ChatId);
        var memberIdsToNotify = chatMembers.Select(m => m.Id).ToList();

        foreach (var memberId in memberIdsToNotify)
        {
            if (messageDto != null)
            {
                await _realTimeNotifier.NotifyMessageReceivedAsync(memberId, messageDto);
            }

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

            // --- НАЧАЛО БЛОКА ДЛЯ ВСТАВКИ/ЗАМЕНЫ ---
            if (updatedChatEntity.Members != null && updatedChatEntity.Members.Any())
            {
                // Используем маппинг из List<ChatMember> в List<UserSimpleDto>.
                // ChatProfile должен содержать маппинг ChatMember -> UserSimpleDto.
                chatDtoForUpdate.Members = _mapper.Map<List<UserSimpleDto>>(updatedChatEntity.Members);
                _logger.LogInformation((Exception?)null, "MessageService: Populated chatDtoForUpdate.Members with {Count} members for chat {ChatId}", chatDtoForUpdate.Members.Count, chatDtoForUpdate.Id);
            }
            else
            {
                chatDtoForUpdate.Members = new List<UserSimpleDto>();
                _logger.LogWarning((Exception?)null, "MessageService: updatedChatEntity.Members was null or empty for chat {ChatId}. Initialized chatDtoForUpdate.Members as empty list.", chatDtoForUpdate.Id);
            }
            // --- КОНЕЦ БЛОКА ДЛЯ ВСТАВКИ/ЗАМЕНЫ ---

            // Существующие отладочные логи (их можно оставить или убрать после исправления)
            _logger.LogInformation((Exception?)null, "PRE-NOTIFICATION LOG for Chat {ChatId}: LastMessage.Id='{LastMessageId}', HasAttachments={HasAttachments}, MemberCountFromDto={MemberCount}", 
                chatDtoForUpdate.Id, 
                chatDtoForUpdate.LastMessage?.Id, 
                chatDtoForUpdate.LastMessage?.Attachments?.Any(),
                chatDtoForUpdate.Members?.Count ?? -1); 
            if (chatDtoForUpdate.LastMessage?.Attachments != null)
            {
                foreach (var att in chatDtoForUpdate.LastMessage.Attachments)
                {
                    _logger.LogInformation((Exception?)null, "PRE-NOTIFICATION LOG Attachment for Chat {ChatId}: FileKey='{FileKey}', FileName='{FileName}'", 
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

    private async Task<MessageDto?> MapMessageToDtoAsync(Message? message, Guid currentUserId)
    {
        if (message == null) return null;

        var dto = _mapper.Map<MessageDto>(message);
        dto.IsRead = message.ReadBy.Contains(currentUserId);

        if (message.SenderId != Guid.Empty)
        {
            var sender = await _unitOfWork.Users.GetByIdAsync(message.SenderId);
            if (sender != null) 
            {
                dto.Sender = await _userService.MapUserToSimpleDtoWithAvatarUrlAsync(sender); 
            }
        }
        // Populate PresignedUrl for each attachment
        if (dto.Attachments != null)
        {
            foreach (var attachment in dto.Attachments)
            {
                if (!string.IsNullOrEmpty(attachment.FileKey))
                {
                    try
                    {
                        attachment.PresignedUrl = await _attachmentService.GetPresignedDownloadUrlAsync(attachment.FileKey, currentUserId);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Failed to generate presigned URL for attachment {FileKey}", attachment.FileKey);
                        attachment.PresignedUrl = null;
                    }
                }
            }
        }
        return dto;
    }

    private async Task<IEnumerable<MessageDto>> MapMessagesToDtoAsync(IEnumerable<Message> messages, Guid currentUserId)
    {
        if (messages == null || !messages.Any()) return Enumerable.Empty<MessageDto>();
        var senderIds = messages.Select(m => m.SenderId).Where(id => id != Guid.Empty).Distinct().ToList();
        var sendersWithPresignedUrls = new Dictionary<Guid, UserSimpleDto>();
        if(senderIds.Any())
        {
            var senderUsers = await _unitOfWork.Users.GetManyByIdsAsync(senderIds);
            foreach (var user in senderUsers)
            {
                if (senderIds.Contains(user.Id))
                {
                    sendersWithPresignedUrls[user.Id] = await _userService.MapUserToSimpleDtoWithAvatarUrlAsync(user);
                }
            }
        }
        var dtos = new List<MessageDto>();
        foreach(var message in messages)
        {
            var dto = _mapper.Map<MessageDto>(message);
            dto.IsRead = message.ReadBy.Contains(currentUserId);
            if (message.SenderId != Guid.Empty && sendersWithPresignedUrls.TryGetValue(message.SenderId, out var senderDto))
            {
                dto.Sender = senderDto;
            }
            // Populate PresignedUrl for each attachment
            if (dto.Attachments != null)
            {
                foreach (var attachment in dto.Attachments)
                {
                    if (!string.IsNullOrEmpty(attachment.FileKey))
                    {
                        try
                        {
                            attachment.PresignedUrl = await _attachmentService.GetPresignedDownloadUrlAsync(attachment.FileKey, currentUserId);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to generate presigned URL for attachment {FileKey}", attachment.FileKey);
                            attachment.PresignedUrl = null;
                        }
                    }
                }
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
        return await MapMessagesToDtoAsync(messages, currentUserId);
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

        return await MapMessageToDtoAsync(message, currentUserId);
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

        var messageDto = await MapMessageToDtoAsync(message, editorUserId);

        var chatMembers = await _unitOfWork.Chats.GetChatMembersAsync(message.ChatId);
        var memberIds = chatMembers.Select(m => m.Id).ToList();
        if (messageDto != null)
        {
            await _realTimeNotifier.NotifyMessageEditedAsync(memberIds, messageDto);
        }
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
        var message = await _messageRepository.GetByIdAsync(messageId);
        if (message == null) throw new KeyNotFoundException($"Message with ID {messageId} not found.");

        // Проверяем, что пользователь является участником чата
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null || !chat.Members.Any(m => m.UserId == readerUserId))
        {
            throw new UnauthorizedAccessException($"User {readerUserId} is not authorized to mark messages as read in chat {chatId}.");
        }

        // Добавляем пользователя в список прочитавших, если его там еще нет
        if (!message.ReadBy.Contains(readerUserId))
        {
            message.ReadBy.Add(readerUserId);
            if (message.Status < MessageStatus.Read) // Обновляем статус сообщения, если оно было только Sent/Delivered
            {
                message.Status = MessageStatus.Read;
            }
            await _messageRepository.UpdateAsync(message);
            _logger.LogInformation("Message {MessageId} marked as read by user {ReaderUserId}", messageId, readerUserId);

            // Уведомляем отправителя о том, что сообщение прочитано
            // Это комплексная логика, возможно, выходящая за рамки простого MarkAsRead
            // Уведомление других участников чата об обновлении статуса сообщения
            // Получаем актуальный список участников чата для уведомления
            var currentChatMembers = await _unitOfWork.Chats.GetChatMembersAsync(chatId);
            var memberUserIdsToNotify = currentChatMembers.Select(cm => cm.Id).ToList();
            // ИСПРАВЛЕН ВЫЗОВ: аргументы и их порядок
            await _realTimeNotifier.NotifyMessageReadAsync(memberUserIdsToNotify, messageId, readerUserId, chatId);
        }
        else
        {
            _logger.LogInformation("Message {MessageId} was already read by user {ReaderUserId}", messageId, readerUserId);
        }
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