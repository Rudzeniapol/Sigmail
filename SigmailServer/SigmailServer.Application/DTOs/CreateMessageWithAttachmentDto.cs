using SigmailClient.Domain.Enums;
using System.ComponentModel.DataAnnotations;

namespace SigmailServer.Application.DTOs
{
    public class CreateMessageWithAttachmentDto
    {
        [Required]
        public Guid ChatId { get; set; }

        [Required]
        public string FileKey { get; set; } // Ключ файла в S3 (получен от GetPresignedUploadUrl)

        [Required]
        public string FileName { get; set; } // Оригинальное имя файла

        [Required]
        public string ContentType { get; set; }

        [Required]
        public long FileSize { get; set; }

        [Required]
        public AttachmentType AttachmentType { get; set; }
        
        public int? Width { get; set; } // Для изображений/видео
        public int? Height { get; set; } // Для изображений/видео
        public string? ThumbnailKey { get; set; } // Если клиент генерирует превью и загружает его отдельно
    }
} 