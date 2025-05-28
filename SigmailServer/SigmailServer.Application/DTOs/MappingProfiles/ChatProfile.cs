using AutoMapper;
using SigmailServer.Application.DTOs;
using System.Linq;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class ChatProfile : Profile
    {
        public ChatProfile()
        {
            // Из Chat (домен) в ChatDto (DTO для отображения)
            CreateMap<Chat, ChatDto>()
                .ForMember(dest => dest.LastMessage, opt => opt.Ignore()) // Заполняется в сервисе
                .ForMember(dest => dest.UnreadCount, opt => opt.Ignore()) // Рассчитывается в сервисе
                .ForMember(dest => dest.Members, opt => opt.Ignore()) // Заполняется в сервисе (маппинг User в UserSimpleDto)
                .ForMember(dest => dest.MemberCount, opt => opt.MapFrom(src => src.Members != null ? src.Members.Count : 0));


            // Из CreateChatDto (DTO для создания) в Chat (домен)
            CreateMap<CreateChatDto, Chat>()
                .ForMember(dest => dest.Id, opt => opt.Ignore()) // Генерируется в конструкторе Chat или БД
                .ForMember(dest => dest.CreatorId, opt => opt.Ignore()) // Устанавливается из контекста пользователя в сервисе
                .ForMember(dest => dest.CreatedAt, opt => opt.Ignore()) // Устанавливается в сервисе
                .ForMember(dest => dest.UpdatedAt, opt => opt.Ignore()) // Устанавливается в сервисе
                .ForMember(dest => dest.LastMessageId, opt => opt.Ignore())
                .ForMember(dest => dest.LastMessage, opt => opt.Ignore())
                .ForMember(dest => dest.Members, opt => opt.Ignore()) // Участники добавляются в сервисе
                .ForMember(dest => dest.Messages, opt => opt.Ignore());

            // Маппинг из ChatMember (сущность связи) в UserSimpleDto (для списка участников в ChatDto)
            // Это может быть использовано сервисом для маппинга списка ChatMember.User
            CreateMap<ChatMember, UserSimpleDto>()
                .ForMember(dest => dest.Id, opt => opt.MapFrom(src => src.User.Id))
                .ForMember(dest => dest.Username, opt => opt.MapFrom(src => src.User.Username))
                .ForMember(dest => dest.ProfileImageUrl, opt => opt.MapFrom(src => src.User.ProfileImageUrl));

        }
    }
}