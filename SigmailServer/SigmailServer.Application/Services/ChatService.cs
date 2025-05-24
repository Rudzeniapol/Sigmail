using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailClient.Domain.Enums;
using SigmailClient.Domain.Interfaces;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;

namespace SigmailServer.Application.Services;

public class ChatService : IChatService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMessageRepository _messageRepository; 
    private readonly IMapper _mapper;
    private readonly IRealTimeNotifier _realTimeNotifier;
    private readonly ILogger<ChatService> _logger;

    public ChatService(
        IUnitOfWork unitOfWork,
        IMessageRepository messageRepository,
        IMapper mapper,
        IRealTimeNotifier realTimeNotifier,
        ILogger<ChatService> logger)
    {
        _unitOfWork = unitOfWork;
        _messageRepository = messageRepository;
        _mapper = mapper;
        _realTimeNotifier = realTimeNotifier;
        _logger = logger;
    }

    public async Task<ChatDto> CreateChatAsync(Guid creatorId, CreateChatDto dto)
    {
        _logger.LogInformation("User {CreatorId} creating chat of type {ChatType} with name '{ChatName}'", creatorId, dto.Type, dto.Name);

        if (dto.Type == ChatType.Private)
        {
            if (dto.MemberIds == null || dto.MemberIds.Count != 1)
            {
                throw new ArgumentException("Private chat must be created with exactly one other member.");
            }
            Guid otherMemberId = dto.MemberIds.First();
            if (creatorId == otherMemberId)
            {
                throw new ArgumentException("Cannot create a private chat with yourself.");
            }
            // Проверяем, существует ли уже такой приватный чат
            var existingPrivateChat = await _unitOfWork.Chats.GetPrivateChatByMembersAsync(creatorId, otherMemberId);
            if (existingPrivateChat != null)
            {
                _logger.LogInformation("Private chat between {User1} and {User2} already exists (ID: {ChatId}). Returning existing.", creatorId, otherMemberId, existingPrivateChat.Id);
                // Нужно загрузить всю информацию для ChatDto
                return await MapChatToDtoAsync(existingPrivateChat, creatorId);
            }
        }
        else // Group or Channel
        {
            if (string.IsNullOrWhiteSpace(dto.Name))
            {
                throw new ArgumentException("Chat name is required for group or channel chats.");
            }
        }

        var chat = new Chat
        {
            Name = dto.Type == ChatType.Private ? null : dto.Name,
            Type = dto.Type,
            Description = dto.Description,
            CreatorId = creatorId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
            // AvatarUrl будет установлен позже, если нужно
        };

        await _unitOfWork.Chats.AddAsync(chat);
        // Важно: CommitAsync нужен здесь, чтобы chat.Id был сгенерирован перед добавлением участников, если Id генерируется БД.
        // Если Guid генерируется в конструкторе Chat, то можно коммитить позже. Предположим, Id генерируется при Add.
        await _unitOfWork.CommitAsync(); // Commit для получения Chat.Id

        await _unitOfWork.Chats.AddMemberAsync(chat.Id, creatorId, ChatMemberRole.Owner);

        var memberIdsToNotify = new HashSet<Guid> { creatorId };

        if (dto.MemberIds != null)
        {
            foreach (var memberId in dto.MemberIds.Distinct()) // Уникальные ID
            {
                if (memberId == creatorId && dto.Type != ChatType.Private) continue; // Создатель уже добавлен как владелец

                var userExists = await _unitOfWork.Users.GetByIdAsync(memberId) != null;
                if (!userExists)
                {
                    _logger.LogWarning("User with ID {MemberId} not found. Skipping for chat {ChatId}.", memberId, chat.Id);
                    continue;
                }
                await _unitOfWork.Chats.AddMemberAsync(chat.Id, memberId, ChatMemberRole.Member);
                memberIdsToNotify.Add(memberId);
            }
        }
        await _unitOfWork.CommitAsync(); // Коммит для добавления участников

        var chatDto = await MapChatToDtoAsync(chat, creatorId);

        await _realTimeNotifier.NotifyChatCreatedAsync(memberIdsToNotify.ToList(), chatDto);
        _logger.LogInformation("Chat {ChatId} (Name: '{ChatName}') created successfully.", chat.Id, chat.Name);
        return chatDto;
    }

    public async Task<ChatDto?> GetChatByIdAsync(Guid chatId, Guid currentUserId)
    {
        _logger.LogInformation("User {CurrentUserId} requesting chat {ChatId}", currentUserId, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null)
        {
            _logger.LogWarning("Chat {ChatId} not found.", chatId);
            return null;
        }

        var isMember = await _unitOfWork.Chats.IsUserMemberAsync(chatId, currentUserId);
        if (!isMember)
        {
            // Для каналов можно разрешить просмотр не-участникам, если это публичный канал.
            // Пока что требуем членства для всех типов.
            _logger.LogWarning("User {CurrentUserId} is not a member of chat {ChatId}. Access denied.", currentUserId, chatId);
            throw new UnauthorizedAccessException("User is not a member of this chat.");
        }

        return await MapChatToDtoAsync(chat, currentUserId);
    }

    public async Task<IEnumerable<ChatDto>> GetUserChatsAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        _logger.LogInformation("Requesting chats for user {UserId}, Page: {Page}, PageSize: {PageSize}", userId, page, pageSize);
        // Пагинация должна быть реализована в репозитории GetUserChatsAsync
        var chats = await _unitOfWork.Chats.GetUserChatsAsync(userId); // TODO: Добавить пагинацию в IChatRepository
        
        var chatDtos = new List<ChatDto>();
        foreach (var chat in chats) // Убрана временная пагинация .Skip().Take()
        {
            chatDtos.Add(await MapChatToDtoAsync(chat, userId));
        }
        return chatDtos;
    }

    private async Task<ChatDto> MapChatToDtoAsync(Chat chat, Guid currentUserId)
    {
        var chatDto = _mapper.Map<ChatDto>(chat);
        
        if (!string.IsNullOrEmpty(chat.LastMessageId))
        {
            var lastMessage = await _messageRepository.GetByIdAsync(chat.LastMessageId);
            if(lastMessage != null)
            {
                var lastMessageDto = _mapper.Map<MessageDto>(lastMessage);
                if (lastMessage.SenderId != Guid.Empty) 
                {
                    var sender = await _unitOfWork.Users.GetByIdAsync(lastMessage.SenderId);
                    lastMessageDto.Sender = _mapper.Map<UserSimpleDto>(sender);
                }
                chatDto.LastMessage = lastMessageDto;
            }
        }

        var members = await _unitOfWork.Chats.GetChatMembersAsync(chat.Id);
        chatDto.Members = _mapper.Map<List<UserSimpleDto>>(members); // Маппинг списка пользователей
        chatDto.MemberCount = members.Count(); // Количество участников
        
        // Используем новый метод репозитория для подсчета непрочитанных сообщений
        chatDto.UnreadCount = (int)await _messageRepository.GetUnreadMessageCountForUserInChatAsync(chat.Id, currentUserId); 
        
        return chatDto;
    }


    public async Task<ChatDto> UpdateChatDetailsAsync(Guid chatId, Guid currentUserId, UpdateChatDto dto)
    {
        _logger.LogInformation("User {CurrentUserId} updating details for chat {ChatId} with Name: \'{DtoName}\'", currentUserId, chatId, dto.Name);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null)
        {
            _logger.LogWarning("Chat {ChatId} not found for update.", chatId);
            throw new KeyNotFoundException("Chat not found.");
        }

        if (chat.Type == ChatType.Private)
        {
            throw new InvalidOperationException("Cannot update details of a private chat directly.");
        }

        var member = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (member == null || (member.Role != ChatMemberRole.Admin && member.Role != ChatMemberRole.Owner))
        {
            _logger.LogWarning("User {CurrentUserId} does not have permission to update chat {ChatId} details.", currentUserId, chatId);
            throw new UnauthorizedAccessException("User does not have permission to update chat details.");
        }

        bool updated = false;
        if (!string.IsNullOrWhiteSpace(dto.Name) && chat.Name != dto.Name)
        {
            chat.Name = dto.Name;
            updated = true;
        }
        if (dto.Description != null && chat.Description != dto.Description) 
        {
            chat.Description = dto.Description;
            updated = true;
        }
        
        var updatedChatDto = await MapChatToDtoAsync(chat, currentUserId); // Готовим DTO до коммита

        if (updated)
        {
            chat.UpdatedAt = DateTime.UtcNow;
            await _unitOfWork.Chats.UpdateAsync(chat);
            await _unitOfWork.CommitAsync();
            _logger.LogInformation("Chat {ChatId} details updated.", chatId);

            var memberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
            if (memberIds.Any())
            {
                await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(memberIds, updatedChatDto);
            }
        }
        return updatedChatDto; // Возвращаем DTO с обновленными данными (или старыми, если не было изменений)
    }

    public async Task AddMemberToChatAsync(Guid chatId, Guid currentUserId, Guid userIdToAdd)
    {
        _logger.LogInformation("User {CurrentUserId} adding user {UserIdToAdd} to chat {ChatId}", currentUserId, userIdToAdd, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");
        if (chat.Type == ChatType.Private) throw new InvalidOperationException("Cannot add members to a private chat.");

        var currentUserMember = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (currentUserMember == null || (currentUserMember.Role != ChatMemberRole.Admin && currentUserMember.Role != ChatMemberRole.Owner))
        {
            throw new UnauthorizedAccessException("User does not have permission to add members.");
        }

        var userToAdd = await _unitOfWork.Users.GetByIdAsync(userIdToAdd);
        if (userToAdd == null) throw new KeyNotFoundException("User to add not found.");

        var isAlreadyMember = await _unitOfWork.Chats.IsUserMemberAsync(chatId, userIdToAdd);
        if (isAlreadyMember) throw new InvalidOperationException("User is already a member of this chat.");

        await _unitOfWork.Chats.AddMemberAsync(chatId, userIdToAdd, ChatMemberRole.Member);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("User {UserIdToAdd} added to chat {ChatId} by user {CurrentUserId}", userIdToAdd, chatId, currentUserId);

        var memberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
        var addedUserDto = _mapper.Map<UserSimpleDto>(userToAdd);
        var chatDto = await MapChatToDtoAsync(chat, currentUserId); // Для передачи обновленного чата

        await _realTimeNotifier.NotifyMemberAddedToChatAsync(memberIds, chatDto, addedUserDto, currentUserId);
    }
    
    public async Task RemoveMemberFromChatAsync(Guid chatId, Guid currentUserId, Guid userIdToRemove)
    {
        _logger.LogInformation("User {CurrentUserId} removing user {UserIdToRemove} from chat {ChatId}", currentUserId, userIdToRemove, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");
        if (chat.Type == ChatType.Private) throw new InvalidOperationException("Cannot remove members from a private chat.");

        var memberToRemove = await _unitOfWork.Chats.GetChatMemberAsync(chatId, userIdToRemove);
        if (memberToRemove == null) throw new InvalidOperationException("User to remove is not a member of this chat.");

        // Логика прав на удаление:
        // Владелец может удалять кого угодно (кроме себя, для этого есть LeaveChat).
        // Админ может удалять обычных участников.
        // Пользователь может удалять сам себя (LeaveChat).
        // Нельзя удалить владельца, если ты не владелец.

        var currentUserMember = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (currentUserMember == null) throw new UnauthorizedAccessException("Current user is not a member or not found.");

        bool canRemove = false;
        if (currentUserId == userIdToRemove) // Сам себя пользователь удаляет через LeaveChat
        {
            throw new InvalidOperationException("Use LeaveChat to remove yourself from the chat.");
        }
        if (currentUserMember.Role == ChatMemberRole.Owner)
        {
            if (memberToRemove.Role == ChatMemberRole.Owner && currentUserId != userIdToRemove) // Владелец пытается удалить другого владельца (не должно быть возможно)
            {
                 // Если это единственный владелец, он не может быть удален таким образом.
                if (chat.Members.Count(m => m.Role == ChatMemberRole.Owner) <= 1 && memberToRemove.UserId == chat.CreatorId)
                {
                    throw new InvalidOperationException("Cannot remove the original owner and only owner of the chat.");
                }
            }
            canRemove = true; 
        }
        else if (currentUserMember.Role == ChatMemberRole.Admin && memberToRemove.Role == ChatMemberRole.Member)
        {
            canRemove = true;
        }
        
        if (!canRemove)
        {
            throw new UnauthorizedAccessException("User does not have permission to remove this member.");
        }

        await _unitOfWork.Chats.RemoveMemberAsync(chatId, userIdToRemove);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("User {UserIdToRemove} removed from chat {ChatId} by user {CurrentUserId}", userIdToRemove, chatId, currentUserId);
        
        var chatDto = await MapChatToDtoAsync(chat, currentUserId); // Для передачи обновленного чата
        var memberIdsToNotify = chat.Members.Where(m => m.UserId != userIdToRemove).Select(m => m.UserId).ToList(); // Все, кроме удаленного
        memberIdsToNotify.Add(userIdToRemove); // Уведомляем и удаленного пользователя

        await _realTimeNotifier.NotifyMemberRemovedFromChatAsync(memberIdsToNotify, chatDto, userIdToRemove, currentUserId);
    }

    public async Task PromoteMemberToAdminAsync(Guid chatId, Guid currentUserId, Guid userIdToPromote)
    {
        _logger.LogInformation("User {CurrentUserId} promoting user {UserIdToPromote} to Admin in chat {ChatId}", currentUserId, userIdToPromote, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");
        if (chat.Type == ChatType.Private) throw new InvalidOperationException("Roles are not applicable in private chats.");

        var currentUserMember = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (currentUserMember == null || currentUserMember.Role != ChatMemberRole.Owner)
        {
            throw new UnauthorizedAccessException("Only the owner can promote members to admin.");
        }

        var memberToPromote = await _unitOfWork.Chats.GetChatMemberAsync(chatId, userIdToPromote);
        if (memberToPromote == null) throw new KeyNotFoundException("User to promote not found in this chat.");
        if (memberToPromote.Role == ChatMemberRole.Admin) throw new InvalidOperationException("User is already an admin.");
        if (memberToPromote.Role == ChatMemberRole.Owner) throw new InvalidOperationException("Cannot change role of the owner.");


        await _unitOfWork.Chats.UpdateMemberRoleAsync(chatId, userIdToPromote, ChatMemberRole.Admin);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("User {UserIdToPromote} promoted to Admin in chat {ChatId} by user {CurrentUserId}", userIdToPromote, chatId, currentUserId);

        var memberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
        var chatDto = await MapChatToDtoAsync(chat, currentUserId);
        await _realTimeNotifier.NotifyChatMemberRoleChangedAsync(memberIds, chatDto, userIdToPromote, ChatMemberRole.Admin, currentUserId);
    }

    public async Task DemoteAdminToMemberAsync(Guid chatId, Guid currentUserId, Guid adminUserIdToDemote)
    {
        _logger.LogInformation("User {CurrentUserId} demoting admin {AdminUserIdToDemote} to Member in chat {ChatId}", currentUserId, adminUserIdToDemote, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");
        if (chat.Type == ChatType.Private) throw new InvalidOperationException("Roles are not applicable in private chats.");

        var currentUserMember = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (currentUserMember == null || currentUserMember.Role != ChatMemberRole.Owner)
        {
            throw new UnauthorizedAccessException("Only the owner can demote admins.");
        }

        var adminToDemote = await _unitOfWork.Chats.GetChatMemberAsync(chatId, adminUserIdToDemote);
        if (adminToDemote == null) throw new KeyNotFoundException("Admin to demote not found in this chat.");
        if (adminToDemote.Role != ChatMemberRole.Admin) throw new InvalidOperationException("User is not an admin.");

        await _unitOfWork.Chats.UpdateMemberRoleAsync(chatId, adminUserIdToDemote, ChatMemberRole.Member);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Admin {AdminUserIdToDemote} demoted to Member in chat {ChatId} by user {CurrentUserId}", adminUserIdToDemote, chatId, currentUserId);

        var memberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
        var chatDto = await MapChatToDtoAsync(chat, currentUserId);
        await _realTimeNotifier.NotifyChatMemberRoleChangedAsync(memberIds, chatDto, adminUserIdToDemote, ChatMemberRole.Member, currentUserId);
    }

    public async Task LeaveChatAsync(Guid chatId, Guid currentUserId)
    {
        _logger.LogInformation("User {CurrentUserId} attempting to leave chat {ChatId}", currentUserId, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");

        var memberToLeave = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (memberToLeave == null) throw new InvalidOperationException("User is not a member of this chat.");

        bool isLastMember = chat.Members.Count() == 1;
        bool isOwnerLeaving = memberToLeave.Role == ChatMemberRole.Owner;

        if (isOwnerLeaving && isLastMember) // Владелец выходит из чата, и он последний участник
        {
            _logger.LogInformation("Owner {CurrentUserId} is the last member leaving chat {ChatId}. Deleting chat.", currentUserId, chatId);
            // Удаляем сообщения чата
            await _unitOfWork.Messages.DeleteMessagesByChatIdAsync(chatId); // Физическое удаление сообщений
            // Удаляем сам чат (включая всех участников через каскадное удаление в БД)
            await _unitOfWork.Chats.DeleteAsync(chatId);
            await _unitOfWork.CommitAsync();
            // Уведомлять некого, чат удален
            _logger.LogInformation("Chat {ChatId} and its messages deleted as the last member (owner) left.", chatId);
            return; // Выход из метода, так как чат удален
        }
        else if (isOwnerLeaving && chat.Members.Count(m => m.Role == ChatMemberRole.Owner) == 1)
        {
            // Владелец уходит, но есть другие участники. Нужно назначить нового владельца.
            var admins = chat.Members.Where(m => m.Role == ChatMemberRole.Admin && m.UserId != currentUserId).OrderBy(m => m.JoinedAt).ToList();
            var members = chat.Members.Where(m => m.Role == ChatMemberRole.Member && m.UserId != currentUserId).OrderBy(m => m.JoinedAt).ToList();
            
            Guid? newOwnerId = null;
            if (admins.Any()) newOwnerId = admins.First().UserId;
            else if (members.Any()) newOwnerId = members.First().UserId;

            if (newOwnerId.HasValue)
            {
                await _unitOfWork.Chats.UpdateMemberRoleAsync(chatId, newOwnerId.Value, ChatMemberRole.Owner);
                _logger.LogInformation("User {NewOwnerId} promoted to Owner in chat {ChatId} as previous owner left.", newOwnerId.Value, chatId);
            }
            else // Это не должно произойти, если isLastMember = false
            {
                 _logger.LogWarning("Owner {CurrentUserId} leaving chat {ChatId}, but no suitable member found to promote to new owner. This might lead to an orphaned chat.", currentUserId, chatId);
                // Потенциально, можно просто удалить чат, если владелец уходит и некого назначить.
                // Или запретить выход владельцу, если он единственный и есть другие участники, не являющиеся админами.
                // Для простоты, пока разрешим выход, но это проблемная ситуация.
            }
        }
        
        // Удаляем участника из чата
        await _unitOfWork.Chats.RemoveMemberAsync(chatId, currentUserId);
        chat.UpdatedAt = DateTime.UtcNow; // Обновляем время изменения чата
        await _unitOfWork.Chats.UpdateAsync(chat); // Для обновления UpdatedAt
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("User {CurrentUserId} left chat {ChatId}.", currentUserId, chatId);

        var remainingMemberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
        var chatDto = await MapChatToDtoAsync(chat, currentUserId); // currentUserId здесь уже не участник, но нужен для контекста DTO

        if (remainingMemberIds.Any())
        {
            await _realTimeNotifier.NotifyMemberLeftChatAsync(remainingMemberIds, chatDto, currentUserId);
        }
    }
    
    public async Task DeleteChatAsync(Guid chatId, Guid currentUserId) // Добавлен метод
    {
        _logger.LogInformation("User {CurrentUserId} attempting to delete chat {ChatId}", currentUserId, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null) throw new KeyNotFoundException("Chat not found.");

        var member = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        // Только владелец может удалить чат
        if (member == null || member.Role != ChatMemberRole.Owner)
        {
            throw new UnauthorizedAccessException("Only the owner can delete the chat.");
        }

        // 1. Уведомить всех участников (кроме текущего пользователя, если он еще там), что чат будет удален
        var memberIdsToNotify = chat.Members.Select(m => m.UserId).Where(id => id != currentUserId).ToList();
        if (memberIdsToNotify.Any())
        {
            // Нужен метод в IRealTimeNotifier, например, NotifyChatDeletedAsync(List<Guid> userIds, Guid chatId)
            // await _realTimeNotifier.NotifyChatDeletedAsync(memberIdsToNotify, chatId);
        }
        
        // 2. Удалить все сообщения чата из MongoDB
        await _unitOfWork.Messages.DeleteMessagesByChatIdAsync(chatId);
        _logger.LogInformation("All messages for chat {ChatId} deleted from MongoDB.", chatId);

        // 3. Удалить сам чат из PostgreSQL (ChatMembers удалятся каскадно)
        await _unitOfWork.Chats.DeleteAsync(chatId);
        await _unitOfWork.CommitAsync();
        _logger.LogInformation("Chat {ChatId} and its members deleted from PostgreSQL by owner {CurrentUserId}.", chatId, currentUserId);
        
        // TODO: Notify (если есть кого) что чат удален. Хотя тут некого. (Уже сделано выше перед удалением)
    }

    public async Task<IEnumerable<UserSimpleDto>> GetChatMembersAsync(Guid chatId) // Убран currentUserId, чтобы соответствовать интерфейсу
    {
        _logger.LogInformation("Requesting members for chat {ChatId}", chatId);
        // Проверка прав на получение списка участников должна быть выполнена до вызова этого метода,
        // если этот метод не предполагает предоставление общедоступной информации о составе чата.
        var members = await _unitOfWork.Chats.GetChatMembersAsync(chatId);
        return _mapper.Map<IEnumerable<UserSimpleDto>>(members);
    }

    public async Task<bool> IsUserMemberAsync(Guid chatId, Guid userId)
    {
        _logger.LogDebug("Checking if user {UserId} is a member of chat {ChatId}", userId, chatId);
        return await _unitOfWork.Chats.IsUserMemberAsync(chatId, userId);
    }
    
    public async Task<ChatDto> UpdateChatAvatarAsync(Guid chatId, Guid currentUserId, Stream avatarStream, string contentType)
    {
        _logger.LogInformation("User {CurrentUserId} updating avatar for chat {ChatId}", currentUserId, chatId);
        var chat = await _unitOfWork.Chats.GetByIdAsync(chatId);
        if (chat == null)
        {
            _logger.LogWarning("Chat {ChatId} not found for avatar update.", chatId);
            throw new KeyNotFoundException("Chat not found.");
        }

        if (chat.Type == ChatType.Private)
        {
            throw new InvalidOperationException("Cannot update avatar of a private chat directly.");
        }

        var member = await _unitOfWork.Chats.GetChatMemberAsync(chatId, currentUserId);
        if (member == null || (member.Role != ChatMemberRole.Admin && member.Role != ChatMemberRole.Owner))
        {
            _logger.LogWarning("User {CurrentUserId} does not have permission to update chat {ChatId} avatar.", currentUserId, chatId);
            throw new UnauthorizedAccessException("User does not have permission to update chat avatar.");
        }

        // Генерируем имя файла для аватара чата
        string fileName = $"chat_avatar_{chatId}{Path.GetExtension(contentType.Split('/').Last())}"; // Простое имя файла

        // Используем IAttachmentService для загрузки. AttachmentType может быть специальным для аватаров.
        // Либо напрямую IFileStorageRepository, если не нужна запись в Attachment DTO/Entity
        // Для простоты, предположим, что AttachmentService.UploadAttachmentAsync подходит
        // или у вас есть специальный метод для загрузки общих файлов, не привязанных к сообщениям.
        // Здесь мы напрямую используем FileStorageRepository для загрузки и обновления URL в чате.

        var fileKey = await _unitOfWork.Files.UploadFileAsync(avatarStream, fileName, contentType);
        
        if (string.IsNullOrWhiteSpace(fileKey))
        {
            _logger.LogError("Failed to upload avatar for chat {ChatId}. File key is null or empty.", chatId);
            throw new Exception("Avatar upload failed.");
        }

        // Удаляем старый аватар, если он был
        if (!string.IsNullOrWhiteSpace(chat.AvatarUrl))
        {
            try
            {
                await _unitOfWork.Files.DeleteFileAsync(chat.AvatarUrl); // Предполагаем, что AvatarUrl хранит fileKey
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to delete old avatar {OldFileKey} for chat {ChatId}.", chat.AvatarUrl, chatId);
                // Не прерываем операцию, если старый аватар не удалился
            }
        }
        
        chat.AvatarUrl = fileKey; // Сохраняем новый fileKey как AvatarUrl
        chat.UpdatedAt = DateTime.UtcNow;

        await _unitOfWork.Chats.UpdateAsync(chat);
        await _unitOfWork.CommitAsync();

        _logger.LogInformation("Avatar for chat {ChatId} updated. New avatar key: {FileKey}", chatId, fileKey);
        
        var chatDto = await MapChatToDtoAsync(chat, currentUserId);

        // Уведомление участников чата
        var memberIds = (await _unitOfWork.Chats.GetChatMembersAsync(chatId)).Select(u => u.Id).ToList();
        if (memberIds.Any())
        {
            // Предполагается, что NotifyChatDetailsUpdatedAsync уведомит об изменении DTO, включая новый AvatarUrl
            await _realTimeNotifier.NotifyChatDetailsUpdatedAsync(memberIds, chatDto);
        }

        return chatDto;
    }
}