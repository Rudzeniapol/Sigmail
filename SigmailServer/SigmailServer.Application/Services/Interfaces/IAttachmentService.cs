using SigmailClient.Domain.Enums;
using SigmailServer.Application.DTOs;

namespace SigmailServer.Application.Services.Interfaces;

public interface IAttachmentService
{
    // Вариант 1: Клиент загружает файл на сервер, сервер пересылает в S3
    Task<AttachmentDto> UploadAttachmentAsync(Guid uploaderId, Stream fileStream, string fileName, string contentType, AttachmentType attachmentType);

    // Вариант 2: Сервер генерирует presigned URL, клиент загружает напрямую в S3
    Task<UploadAttachmentResponseDto> GetPresignedUploadUrlAsync(Guid uploaderId, string fileName, string contentType, long fileSize, AttachmentType attachmentType);
    Task<string> GetPresignedDownloadUrlAsync(string fileKey, Guid currentUserId); // Изменено: добавлен currentUserId
    Task DeleteAttachmentAsync(Guid currentUserId, string fileKey);
}