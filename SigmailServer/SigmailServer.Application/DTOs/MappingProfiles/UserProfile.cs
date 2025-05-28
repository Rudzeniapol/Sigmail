using AutoMapper;
using SigmailServer.Application.DTOs;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.DTOs.MappingProfiles
{
    public class UserProfile : Profile
    {
        public UserProfile()
        {
            // Из User (домен) в UserDto (DTO для отображения)
            CreateMap<User, UserDto>();

            // Из User (домен) в UserSimpleDto (упрощенное DTO)
            CreateMap<User, UserSimpleDto>();

            // Из CreateUserDto (DTO для создания) в User (домен)
            // Обратите внимание: PasswordHash будет устанавливаться в сервисе, не через AutoMapper
            CreateMap<CreateUserDto, User>()
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore()) // Пароль хешируется отдельно
                .ForMember(dest => dest.Id, opt => opt.Ignore()) // Id генерируется в конструкторе User или БД
                .ForMember(dest => dest.ProfileImageUrl, opt => opt.Ignore())
                .ForMember(dest => dest.Bio, opt => opt.Ignore())
                .ForMember(dest => dest.IsOnline, opt => opt.Ignore())
                .ForMember(dest => dest.LastSeen, opt => opt.Ignore())
                .ForMember(dest => dest.CurrentDeviceToken, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshToken, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshTokenExpiryTime, opt => opt.Ignore());


            // Из UpdateUserProfileDto в User для обновления
            // AutoMapper может использоваться для копирования совпадающих свойств,
            // но логика обновления (проверки, частичные обновления) остается в сервисе.
            CreateMap<UpdateUserProfileDto, User>()
                .ForMember(dest => dest.Id, opt => opt.Ignore())
                .ForMember(dest => dest.PasswordHash, opt => opt.Ignore())
                .ForMember(dest => dest.ProfileImageUrl, opt => opt.Ignore()) // Обновляется отдельно
                .ForMember(dest => dest.IsOnline, opt => opt.Ignore())
                .ForMember(dest => dest.LastSeen, opt => opt.Ignore())
                .ForMember(dest => dest.CurrentDeviceToken, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshToken, opt => opt.Ignore())
                .ForMember(dest => dest.RefreshTokenExpiryTime, opt => opt.Ignore())
                // Пропускаем Username и Email, так как их обновление требует проверки на уникальность в сервисе.
                // Сервис будет вызывать user.UpdateProfile()
                .ForMember(dest => dest.Username, opt => opt.Ignore())
                .ForMember(dest => dest.Email, opt => opt.Ignore());


        }
    }
}