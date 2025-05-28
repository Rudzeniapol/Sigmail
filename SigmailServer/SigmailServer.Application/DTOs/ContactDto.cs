using SigmailServer.Domain.Enums;

namespace SigmailServer.Application.DTOs;

public class ContactDto { // Отображение контакта
    public Guid ContactEntryId { get; set; } // Id записи в таблице Contact
    public UserDto User { get; set; } = null!; // Информация о пользователе-контакте
    public ContactRequestStatus Status { get; set; }
    public DateTime RequestedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}