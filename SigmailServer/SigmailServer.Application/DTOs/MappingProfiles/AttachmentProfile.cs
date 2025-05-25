using AutoMapper;
using SigmailClient.Domain.Models;
using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class AttachmentProfile : Profile
    {
        public AttachmentProfile()
        {
            // Из Attachment (домен) в AttachmentDto (DTO для отображения)
            CreateMap<SigmailClient.Domain.Models.Attachment, AttachmentDto>()
                .ForMember(dest => dest.PresignedUrl, opt => opt.Ignore()) // Генерируется по запросу
                .ForMember(dest => dest.ThumbnailPresignedUrl, opt => opt.Ignore()); // Генерируется по запросу

            // Из CreateAttachmentDto (DTO для создания сущности Attachment в Message) в Attachment (домен)
            CreateMap<CreateAttachmentDto, SigmailClient.Domain.Models.Attachment>();
        }
    }
}