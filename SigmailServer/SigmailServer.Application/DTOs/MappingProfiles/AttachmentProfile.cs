using AutoMapper;
using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class AttachmentProfile : Profile
    {
        public AttachmentProfile()
        {
            // Из Attachment (домен) в AttachmentDto (DTO для отображения)
            CreateMap<Attachment, AttachmentDto>()
                .ForMember(dest => dest.PresignedUrl, opt => opt.Ignore()) // Генерируется по запросу
                .ForMember(dest => dest.ThumbnailPresignedUrl, opt => opt.Ignore()); // Генерируется по запросу

            // Из CreateAttachmentDto (DTO для создания сущности Attachment в Message) в Attachment (домен)
            CreateMap<CreateAttachmentDto, Attachment>();
        }
    }
}