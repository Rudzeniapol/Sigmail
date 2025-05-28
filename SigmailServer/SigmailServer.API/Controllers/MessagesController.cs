using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Domain.Exceptions; // Для NotFoundException

namespace SigmailServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class MessagesController : ControllerBase
    {
        private readonly IMessageService _messageService;
        private readonly IMessageReactionService _messageReactionService;
        private readonly ILogger<MessagesController> _logger;

        public MessagesController(
            IMessageService messageService, 
            IMessageReactionService messageReactionService,
            ILogger<MessagesController> logger)
        {
            _messageService = messageService;
            _messageReactionService = messageReactionService;
            _logger = logger;
        }
        
        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId)) return userId;
            throw new UnauthorizedAccessException("User identifier not found or invalid.");
        }

        [HttpPost("with-attachment")]
        public async Task<IActionResult> CreateMessageWithAttachment([FromBody] CreateMessageWithAttachmentDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            try
            {
                var senderId = GetCurrentUserId(); 
                var messageDto = await _messageService.CreateMessageWithAttachmentAsync(senderId, dto);
                return CreatedAtAction(nameof(GetMessageById), new { messageId = messageDto.Id }, messageDto);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex) 
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating message with attachment for chat {ChatId} by user {SenderId}", dto.ChatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost]
        public async Task<IActionResult> SendMessage([FromBody] CreateMessageDto dto)
        {
            try
            {
                var senderId = GetCurrentUserId();
                var messageDto = await _messageService.SendMessageAsync(senderId, dto);
                // WebSocket (SignalR) уже должен был уведомить клиентов.
                // Возвращаем созданное сообщение.
                return CreatedAtAction(nameof(GetMessageById), new { messageId = messageDto.Id }, messageDto);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex) // Чат не найден
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex) // Не член чата
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending message by user {SenderId} to chat {ChatId}", GetCurrentUserId(), dto.ChatId);
                return StatusCode(500, new { message = "An unexpected error occurred while sending message." });
            }
        }

        [HttpGet("chat/{chatId}")]
        public async Task<IActionResult> GetMessagesForChat(Guid chatId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var messages = await _messageService.GetMessagesAsync(chatId, currentUserId, page, pageSize);
                return Ok(messages);
            }
            catch (UnauthorizedAccessException ex) // Не член чата
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching messages for chat {ChatId} by user {UserId}", chatId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpGet("{messageId}")]
        public async Task<IActionResult> GetMessageById(string messageId) // messageId из MongoDB - строка
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var message = await _messageService.GetMessageByIdAsync(messageId, currentUserId);
                if (message == null)
                {
                    return NotFound(new { message = $"Message with ID {messageId} not found." });
                }
                return Ok(message);
            }
            catch (UnauthorizedAccessException ex) // Не член чата, к которому принадлежит сообщение
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error fetching message {MessageId} by user {UserId}", messageId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        [HttpPut("{messageId}")]
        public async Task<IActionResult> EditMessage(string messageId, [FromBody] UpdateMessageTextDto dto) // Нужен новый DTO
        {
            if (string.IsNullOrWhiteSpace(dto.NewText))
            {
                 return BadRequest(new { message = "New text cannot be empty." });
            }
            try
            {
                var editorUserId = GetCurrentUserId();
                await _messageService.EditMessageAsync(messageId, editorUserId, dto.NewText);
                return Ok(new { message = "Message edited successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (InvalidOperationException ex) // Например, сообщение уже удалено или нельзя редактировать
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error editing message {MessageId} by user {UserId}", messageId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }
        
        // DTO для редактирования текста сообщения
        public class UpdateMessageTextDto { public string NewText { get; set; } }


        [HttpDelete("{messageId}")]
        public async Task<IActionResult> DeleteMessage(string messageId)
        {
            try
            {
                var deleterUserId = GetCurrentUserId();
                await _messageService.DeleteMessageAsync(messageId, deleterUserId);
                return Ok(new { message = "Message deleted successfully." });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting message {MessageId} by user {UserId}", messageId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred." });
            }
        }
        
        // --- Реакции ---
        [HttpPost("{messageId}/reactions")]
        public async Task<IActionResult> AddReaction(string messageId, [FromBody] AddReactionDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            try
            {
                var reactorUserId = GetCurrentUserId();
                var reactions = await _messageReactionService.AddReactionAsync(messageId, reactorUserId, dto.Emoji);
                return Ok(reactions);
            }
            catch (NotFoundException ex)
            {
                _logger.LogWarning(ex, "AddReaction: Resource not found for message {MessageId}", messageId);
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                 _logger.LogWarning(ex, "AddReaction: Unauthorized access by user {UserId} to message {MessageId}", GetCurrentUserId(), messageId);
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding reaction to message {MessageId} by user {UserId}", messageId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred while adding reaction." });
            }
        }

        [HttpDelete("{messageId}/reactions/{emoji}")] // emoji передается в URL
        public async Task<IActionResult> RemoveReaction(string messageId, string emoji)
        {
            try
            {
                var reactorUserId = GetCurrentUserId();
                var decodedEmoji = System.Net.WebUtility.UrlDecode(emoji);
                var reactions = await _messageReactionService.RemoveReactionAsync(messageId, reactorUserId, decodedEmoji);
                return Ok(reactions);
            }
            catch (NotFoundException ex)
            {
                _logger.LogWarning(ex, "RemoveReaction: Resource not found for message {MessageId} or reaction {Emoji}", messageId, emoji);
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "RemoveReaction: Unauthorized access by user {UserId} to message {MessageId}", GetCurrentUserId(), messageId);
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                 _logger.LogError(ex, "Error removing reaction {Emoji} from message {MessageId} by user {UserId}", emoji, messageId, GetCurrentUserId());
                return StatusCode(500, new { message = "An error occurred while removing reaction." });
            }
        }
        
        // Эндпоинт для MarkMessageAsReadAsync уже не нужен в контроллере,
        // так как это делается через SignalR Hub (MarkMessageAsReadOnServer).
        // MarkMessagesAsDeliveredAsync - это скорее внутренний механизм, который может быть вызван 
        // при доставке push-уведомления или когда клиент подтверждает получение через WebSocket.
        // Если нужен явный HTTP эндпоинт, его можно добавить.

    }
}