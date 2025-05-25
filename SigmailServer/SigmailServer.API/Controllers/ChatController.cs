using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using System.Security.Claims;

namespace SigmailServer.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ChatsController : ControllerBase
    {
        private readonly IChatService _chatService;
        private readonly ILogger<ChatsController> _logger;
        // IAttachmentService может понадобиться для аватаров чата

        public ChatsController(IChatService chatService, ILogger<ChatsController> logger)
        {
            _chatService = chatService;
            _logger = logger;
        }

        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId)) return userId;
            throw new UnauthorizedAccessException("User identifier not found or invalid.");
        }

        [HttpPost]
        public async Task<IActionResult> CreateChat([FromBody] CreateChatDto dto)
        {
            try
            {
                var creatorId = GetCurrentUserId();
                var chatDto = await _chatService.CreateChatAsync(creatorId, dto);
                // При создании возвращаем 201 Created и ссылку на созданный ресурс
                return CreatedAtAction(nameof(GetChatById), new { chatId = chatDto.Id }, chatDto);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating chat for user {CreatorId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred while creating chat." });
            }
        }

        [HttpGet("{chatId}")]
        public async Task<IActionResult> GetChatById(Guid chatId)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var chatDto = await _chatService.GetChatByIdAsync(chatId, currentUserId);
                if (chatDto == null)
                {
                    return NotFound(new { message = $"Chat with ID {chatId} not found or access denied." });
                }
                return Ok(chatDto);
            }
            catch (UnauthorizedAccessException ex)
            {
                // GetChatByIdAsync в ChatService уже бросает UnauthorizedAccessException, если не член
                return Forbid(ex.Message); // или NotFound()
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching chat {ChatId} for user {UserId}", chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpGet("my")]
        public async Task<IActionResult> GetMyChats([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var userId = GetCurrentUserId();
                var chats = await _chatService.GetUserChatsAsync(userId, page, pageSize);
                return Ok(chats);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching chats for user {UserId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        [HttpPut("{chatId}/details")]
        public async Task<IActionResult> UpdateChatDetails(Guid chatId, [FromBody] UpdateChatDto dto)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var updatedChat = await _chatService.UpdateChatDetailsAsync(chatId, currentUserId, dto);
                return Ok(updatedChat);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex) // Например, попытка изменить личный чат
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating details for chat {ChatId} by user {UserId}", chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }

        // --- Управление участниками ---
        [HttpPost("{chatId}/members/{userIdToAdd}")]
        public async Task<IActionResult> AddMember(Guid chatId, Guid userIdToAdd)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                await _chatService.AddMemberToChatAsync(chatId, currentUserId, userIdToAdd);
                return Ok(new { message = $"User {userIdToAdd} added to chat {chatId}." });
            }
            // ... обработка KeyNotFoundException, UnauthorizedAccessException, InvalidOperationException ...
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error adding member {UserIdToAdd} to chat {ChatId} by user {CurrentUserId}", userIdToAdd, chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }

        [HttpDelete("{chatId}/members/{userIdToRemove}")]
        public async Task<IActionResult> RemoveMember(Guid chatId, Guid userIdToRemove)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                await _chatService.RemoveMemberFromChatAsync(chatId, currentUserId, userIdToRemove);
                return Ok(new { message = $"User {userIdToRemove} removed from chat {chatId}." });
            }
             // ... обработка KeyNotFoundException, UnauthorizedAccessException, InvalidOperationException ...
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing member {UserIdToRemove} from chat {ChatId} by user {CurrentUserId}", userIdToRemove, chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }
        
        [HttpPost("{chatId}/leave")]
        public async Task<IActionResult> LeaveChat(Guid chatId)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                await _chatService.LeaveChatAsync(chatId, currentUserId);
                return Ok(new { message = $"User {currentUserId} left chat {chatId}." });
            }
            // ... обработка KeyNotFoundException, InvalidOperationException ...
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error leaving chat {ChatId} by user {CurrentUserId}", chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }

        [HttpGet("{chatId}/members")]
        public async Task<IActionResult> GetChatMembers(Guid chatId)
        {
            try
            {
                // Проверка, является ли текущий пользователь участником чата, может быть добавлена в сам сервис GetChatMembersAsync,
                // или выполнена здесь перед вызовом сервиса.
                var currentUserId = GetCurrentUserId();
                if (!await _chatService.IsUserMemberAsync(chatId, currentUserId))
                {
                    return Forbid("You are not a member of this chat.");
                }

                var members = await _chatService.GetChatMembersAsync(chatId);
                return Ok(members);
            }
             // ... обработка KeyNotFoundException ...
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error fetching members for chat {ChatId}", chatId);
                return StatusCode(500, new { message = "An error occurred." });
            }
        }

        // TODO: Добавить эндпоинты для PromoteMemberToAdmin, DemoteAdminToMember, UpdateChatAvatarAsync, DeleteChatAsync
    }
}