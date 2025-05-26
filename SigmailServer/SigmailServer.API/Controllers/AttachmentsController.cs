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
    public class AttachmentsController : ControllerBase
    {
        private readonly IAttachmentService _attachmentService;
        private readonly ILogger<AttachmentsController> _logger;

        public AttachmentsController(IAttachmentService attachmentService, ILogger<AttachmentsController> logger)
        {
            _attachmentService = attachmentService;
            _logger = logger;
        }

        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId)) return userId;
            throw new UnauthorizedAccessException("User identifier not found or invalid.");
        }

        [HttpPost("upload-url")]
        public async Task<IActionResult> GetPresignedUploadUrl([FromBody] CreatePresignedUrlRequestDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.FileName) || dto.FileSize <=0)
            {
                return BadRequest(new { message = "FileName and FileSize are required and FileSize must be positive."});
            }

            try
            {
                var uploaderId = GetCurrentUserId();
                var response = await _attachmentService.GetPresignedUploadUrlAsync(
                    uploaderId, 
                    dto.FileName, 
                    dto.ContentType ?? "application/octet-stream",
                    dto.FileSize, 
                    dto.AttachmentType
                );
                return Ok(response);
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
                _logger.LogError(ex, "Error generating presigned upload URL for user {UploaderId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        public class CreatePresignedUrlRequestDto
        {
            public string FileName { get; set; }
            public string? ContentType { get; set; }
            public long FileSize { get; set; }
            public SigmailClient.Domain.Enums.AttachmentType AttachmentType { get; set; }
        }

        [HttpGet("download-url/{fileKey}")]
        public async Task<IActionResult> GetPresignedDownloadUrl(string fileKey)
        {
            if (string.IsNullOrWhiteSpace(fileKey))
            {
                return BadRequest(new { message = "FileKey is required." });
            }
            try
            {
                var currentUserId = GetCurrentUserId();
                var url = await _attachmentService.GetPresignedDownloadUrlAsync(System.Net.WebUtility.UrlDecode(fileKey), currentUserId);
                return Ok(new { presignedUrl = url });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex) // Если файл не найден в S3 или нет записи о нем
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex) // Нет прав на доступ к файлу
            {
                return Forbid(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating presigned download URL for fileKey {FileKey} by user {UserId}", fileKey, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        // DELETE /api/attachments/{fileKey} - удаление вложения
        // Этот эндпоинт может быть более сложным, так как удаление файла из S3
        // также должно повлечь за собой удаление его из сообщения в MongoDB.
        // Такая логика уже есть в AttachmentService.DeleteAttachmentAsync.
        [HttpDelete("{fileKey}")]
        public async Task<IActionResult> DeleteAttachment(string fileKey)
        {
             if (string.IsNullOrWhiteSpace(fileKey))
            {
                return BadRequest(new { message = "FileKey is required." });
            }
            try
            {
                var currentUserId = GetCurrentUserId();
                await _attachmentService.DeleteAttachmentAsync(currentUserId, System.Net.WebUtility.UrlDecode(fileKey));
                return Ok(new { message = $"Attachment {fileKey} marked for deletion."});
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
                _logger.LogError(ex, "Error deleting attachment {FileKey} by user {UserId}", fileKey, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
    }
}