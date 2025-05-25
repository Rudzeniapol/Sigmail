using AutoMapper;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class NotificationProfile : Profile
    {
        public NotificationProfile()
        {
            // Из Notification (домен) в NotificationDto (DTO для отображения)
            CreateMap<Notification, NotificationDto>();
        }
    }
}