using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SigmailClient.Domain.Enums;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using System.Security.Claims;

namespace SigmailServer.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ContactsController : ControllerBase
    {
        private readonly IContactService _contactService;
        private readonly ILogger<ContactsController> _logger;

        public ContactsController(IContactService contactService, ILogger<ContactsController> logger)
        {
            _contactService = contactService;
            _logger = logger;
        }

        private Guid GetCurrentUserId()
        {
            var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (Guid.TryParse(userIdString, out Guid userId)) return userId;
            throw new UnauthorizedAccessException("User identifier not found or invalid.");
        }

        [HttpPost("request")]
        public async Task<IActionResult> SendContactRequest([FromBody] ContactRequestDto dto)
        {
            try
            {
                var requesterId = GetCurrentUserId();
                await _contactService.SendContactRequestAsync(requesterId, dto);
                return Ok(new { message = "Contact request sent." });
            }
            catch (ArgumentException ex) { return BadRequest(new { message = ex.Message }); }
            catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
            catch (InvalidOperationException ex) { return Conflict(new { message = ex.Message }); } // Например, уже друзья или запрос существует
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message });}
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending contact request from user {RequesterId} to {TargetUserId}", GetCurrentUserId(), dto.TargetUserId);
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpPost("respond")]
        public async Task<IActionResult> RespondToContactRequest([FromBody] RespondToContactRequestDto dto)
        {
            try
            {
                var responderId = GetCurrentUserId();
                await _contactService.RespondToContactRequestAsync(responderId, dto);
                return Ok(new { message = "Contact request responded." });
            }
            catch (ArgumentException ex) { return BadRequest(new { message = ex.Message }); }
            catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
            catch (InvalidOperationException ex) { return Conflict(new { message = ex.Message }); }
            catch (UnauthorizedAccessException ex) { return Forbid(ex.Message); }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error responding to contact request {RequestId} by user {ResponderId}", dto.RequestId, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetMyContacts([FromQuery] ContactRequestStatus? statusFilter = ContactRequestStatus.Accepted)
        {
            try
            {
                var userId = GetCurrentUserId();
                var contacts = await _contactService.GetUserContactsAsync(userId, statusFilter);
                return Ok(contacts);
            }
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message }); }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching contacts for user {UserId} with filter {StatusFilter}", GetCurrentUserId(), statusFilter);
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
        
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingRequests()
        {
            try
            {
                var userId = GetCurrentUserId();
                var requests = await _contactService.GetPendingContactRequestsAsync(userId);
                return Ok(requests);
            }
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message }); }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error fetching pending contact requests for user {UserId}", GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }


        [HttpDelete("{contactUserIdToRemove}")]
        public async Task<IActionResult> RemoveContact(Guid contactUserIdToRemove)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                await _contactService.RemoveContactAsync(currentUserId, contactUserIdToRemove);
                return Ok(new { message = $"Contact with user {contactUserIdToRemove} removed." });
            }
            catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
            catch (UnauthorizedAccessException ex) { return Unauthorized(new { message = ex.Message }); }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error removing contact {ContactUserIdToRemove} by user {CurrentUserId}", contactUserIdToRemove, GetCurrentUserId());
                return StatusCode(500, new { message = "An unexpected error occurred." });
            }
        }
    }
}