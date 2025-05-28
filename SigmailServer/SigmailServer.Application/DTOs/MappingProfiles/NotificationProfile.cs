using AutoMapper;
using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Models;

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