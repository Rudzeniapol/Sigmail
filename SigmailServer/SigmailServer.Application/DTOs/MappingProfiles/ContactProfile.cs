using AutoMapper;
using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class ContactProfile : Profile
    {
        public ContactProfile()
        {
            // Из Contact (домен) в ContactDto
            // Этот маппинг будет неполным, так как UserDto (контактное лицо)
            // определяется в сервисе на основе UserId и ContactUserId.
            CreateMap<Contact, ContactDto>()
                .ForMember(dest => dest.ContactEntryId, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.User, opt => opt.Ignore()); // Заполняется в ContactService
        }
    }
}