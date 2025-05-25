using AutoMapper;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class MessageProfile : Profile
    {
        public MessageProfile()
        {
            // Из Message (домен) в MessageDto (DTO для отображения)
            CreateMap<Message, MessageDto>()
                .ForMember(dest => dest.Sender, opt => opt.Ignore()); // Sender (UserSimpleDto) будет заполняться в сервисе

            // Из CreateMessageDto (DTO для создания) в Message (домен)
            CreateMap<CreateMessageDto, Message>()
                .ForMember(dest => dest.Id, opt => opt.Ignore()) // Генерируется MongoDB
                .ForMember(dest => dest.SenderId, opt => opt.Ignore()) // Устанавливается из контекста пользователя в сервисе
                .ForMember(dest => dest.Timestamp, opt => opt.Ignore()) // Устанавливается в сервисе
                .ForMember(dest => dest.Status, opt => opt.Ignore()) // Устанавливается в сервисе
                .ForMember(dest => dest.IsEdited, opt => opt.MapFrom(src => false))
                .ForMember(dest => dest.EditedAt, opt => opt.Ignore())
                .ForMember(dest => dest.ReadBy, opt => opt.Ignore())
                .ForMember(dest => dest.DeliveredTo, opt => opt.Ignore()) // DeliveredTo также обычно управляется логикой
                .ForMember(dest => dest.Reactions, opt => opt.Ignore()) // Реакции добавляются отдельно
                .ForMember(dest => dest.IsDeleted, opt => opt.Ignore())
                .ForMember(dest => dest.DeletedAt, opt => opt.Ignore())
                .ForMember(dest => dest.Attachments, opt => opt.MapFrom(src => src.Attachments)); // Маппим вложения

            // Из MessageReactionEntry (домен) в MessageReactionDto (DTO)
            CreateMap<MessageReactionEntry, MessageReactionDto>();
        }
    }
}