using AutoMapper;
using Microsoft.Extensions.Logging;
using SigmailServer.Application.DTOs;
using SigmailServer.Application.Services.Interfaces;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Options;
using SigmailServer.Domain.Enums;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Domain.Models;

namespace SigmailServer.Application.Services;

public class AttachmentService : IAttachmentService
{
    private readonly IFileStorageRepository _fileStorageRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<AttachmentService> _logger;
    private readonly IUnitOfWork _unitOfWork; 
    private readonly AttachmentSettings _attachmentSettings; // Добавлено

    public AttachmentService(
        IFileStorageRepository fileStorageRepository,
        IMapper mapper,
        ILogger<AttachmentService> logger,
        IUnitOfWork unitOfWork,
        IOptions<AttachmentSettings> attachmentSettingsOptions) // Добавлено
    {
        _fileStorageRepository = fileStorageRepository;
        _mapper = mapper;
        _logger = logger;
        _unitOfWork = unitOfWork;
        _attachmentSettings = attachmentSettingsOptions.Value; // Добавлено
    }

    // Вариант 1: Клиент загружает файл на сервер, сервер пересылает в S3
    // Этот вариант менее предпочтителен для больших файлов из-за нагрузки на сервер.
    // Presigned URLs (Вариант 2) обычно лучше.
    public async Task<AttachmentDto> UploadAttachmentAsync(Guid uploaderId, Stream fileStream, string fileName, string contentType, AttachmentType attachmentType)
    {
        _logger.LogInformation("User {UploaderId} uploading attachment {FileName} (server-side proxy)", uploaderId, fileName);

        if (fileStream == null || fileStream.Length == 0)
        {
            throw new ArgumentException("File stream cannot be null or empty.", nameof(fileStream));
        }
        if (string.IsNullOrWhiteSpace(fileName))
        {
            throw new ArgumentException("File name cannot be empty.", nameof(fileName));
        }

        // Генерация уникального ключа файла
        var fileExtension = Path.GetExtension(fileName);
        var uniqueFileKey = $"{uploaderId}/{Guid.NewGuid()}{fileExtension}";

        if (string.IsNullOrWhiteSpace(contentType))
        {
            new FileExtensionContentTypeProvider().TryGetContentType(fileName, out contentType);
            contentType ??= "application/octet-stream";
        }

        string fileUrlOrKey = await _fileStorageRepository.UploadFileAsync(fileStream, uniqueFileKey, contentType); // Репозиторий должен вернуть ключ или URL

        // Здесь может быть создание записи об Attachment в БД (если они не вложены в Message)
        // SigmailServer.Domain.Models.Attachment attachmentEntity = new SigmailServer.Domain.Models.Attachment
        // {
        //     FileKey = fileUrlOrKey, // или uniqueFileKey, если UploadFileAsync возвращает только его
        //     FileName = fileName,
        //     ContentType = contentType,
        //     Type = attachmentType,
        //     Size = fileStream.Length, // Важно: если stream уже прочитан, Length может быть неверным. Получать до чтения.
        //     // UploaderId = uploaderId, CreatedAt = DateTime.UtcNow, etc.
        // };
        // await _unitOfWork.Attachments.AddAsync(attachmentEntity); // Если есть такой репозиторий
        // await _unitOfWork.CommitAsync();

        _logger.LogInformation("Attachment {FileName} uploaded by {UploaderId}, key: {FileKey}", fileName, uploaderId, fileUrlOrKey);

        // Возвращаем DTO. PresignedUrl для скачивания можно сгенерировать сразу или по запросу.
        var downloadUrl = await _fileStorageRepository.GeneratePresignedUrlAsync(fileUrlOrKey, TimeSpan.FromHours(1));

        return new AttachmentDto
        {
            FileKey = fileUrlOrKey,
            FileName = fileName,
            ContentType = contentType,
            Type = attachmentType,
            Size = fileStream.Length, // Перепроверить получение размера
            PresignedUrl = downloadUrl
            // ThumbnailKey и другие поля по необходимости
        };
    }

    public async Task<UploadAttachmentResponseDto> GetPresignedUploadUrlAsync(Guid uploaderId, string fileName, string contentType, long fileSize, AttachmentType attachmentType)
    {
        _logger.LogInformation("User {UploaderId} requesting presigned URL for upload: {FileName}, Size: {FileSize}, ContentType: {ContentType}", uploaderId, fileName, fileSize, contentType);

        if (string.IsNullOrWhiteSpace(fileName)) throw new ArgumentException("File name is required.");
        if (fileSize <= 0) throw new ArgumentException("File size must be greater than zero.");

        // Валидация размера файла
        if (fileSize > _attachmentSettings.MaxFileSizeBytes)
        {
            throw new ArgumentException($"File size exceeds the maximum allowed limit of {_attachmentSettings.MaxFileSizeMB} MB.");
        }

        var fileExtension = Path.GetExtension(fileName).ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(contentType))
        {
            new FileExtensionContentTypeProvider().TryGetContentType(fileName, out contentType);
            contentType ??= "application/octet-stream"; // Fallback
        }

        // Валидация типа файла (по расширению и ContentType)
        bool extensionAllowed = _attachmentSettings.AllowedFileExtensions.Any(ext => ext.Equals(fileExtension, StringComparison.OrdinalIgnoreCase));
        bool contentTypeAllowed = _attachmentSettings.AllowedContentTypes.Any(ct => ct.Equals(contentType, StringComparison.OrdinalIgnoreCase));

        if ((_attachmentSettings.AllowedFileExtensions.Any() && !extensionAllowed) || 
            (_attachmentSettings.AllowedContentTypes.Any() && !contentTypeAllowed))
        {
            _logger.LogWarning("File type not allowed. FileName: {FileName}, Extension: {FileExtension}, ContentType: {ContentType}", fileName, fileExtension, contentType);
            throw new ArgumentException("File type not allowed.");
        }
        
        var uniqueFileKey = $"uploads/{uploaderId}/{Guid.NewGuid()}{fileExtension}";
        var presignedUrl = await _fileStorageRepository.GeneratePresignedUrlAsync(uniqueFileKey, TimeSpan.FromMinutes(15));

        _logger.LogInformation("Presigned URL generated for {FileKey}", uniqueFileKey);
        return new UploadAttachmentResponseDto
        {
            FileKey = uniqueFileKey,
            FileName = fileName,
            ContentType = contentType,
            Size = fileSize,
            Type = attachmentType,
            PresignedUploadUrl = presignedUrl
        };
    }


    public async Task<string> GetPresignedDownloadUrlAsync(string fileKey, Guid currentUserId /* Добавлено для проверки прав */)
    {
        _logger.LogInformation("User {CurrentUserId} requesting presigned download URL for file key {FileKey}", currentUserId, fileKey);
        if (string.IsNullOrWhiteSpace(fileKey)) throw new ArgumentException("File key is required.");

        // Опциональная проверка существования файла (S3 вернет ошибку 404, если URL недействителен или файл удален)
        // bool fileExists = await _fileStorageRepository.FileExistsAsync(fileKey); // Потребует метод в IFileStorageRepository
        // if (!fileExists) throw new KeyNotFoundException("File not found.");


        // Проверка прав доступа:
        // Связываем fileKey с сообщением, чтобы проверить, имеет ли currentUserId доступ к этому чату/сообщению.
        // Это упрощенная проверка. В реальности может потребоваться более сложная логика.
        var messageContainingFile = await _unitOfWork.Messages.GetByAttachmentKeyAsync(fileKey);
        
        if (messageContainingFile != null)
        {
            var isMember = await _unitOfWork.Chats.IsUserMemberAsync(messageContainingFile.ChatId, currentUserId);
            if (!isMember)
            {
                 _logger.LogWarning("User {CurrentUserId} does not have permission to access file {FileKey} via chat {ChatId}", currentUserId, fileKey, messageContainingFile.ChatId);
                throw new UnauthorizedAccessException("You do not have permission to access this file.");
            }
        }
        else
        {
            // Если файл не привязан к сообщению (например, аватар пользователя), нужна другая логика проверки.
            // TODO: Реализовать проверку для аватаров, если они хранятся через этот сервис.
            // Пример:
            // var user = await _unitOfWork.Users.GetByIdAsync(currentUserId); // Предположим, мы хотим проверить, является ли это аватаром текущего пользователя
            // if (user == null || user.ProfileImageUrl != fileKey) {
            //      // Или это может быть аватар другого пользователя, если профили публичны
            //      var targetUser = await _unitOfWork.Users.FirstOrDefaultAsync(u => u.ProfileImageUrl == fileKey); // нужен метод в репозитории
            //      if (targetUser == null) { // Файл не является известным аватаром
            //          _logger.LogWarning("Could not determine access rights for file key {FileKey} for user {CurrentUserId} (not a message attachment or known avatar). Denying access.", fileKey, currentUserId);
            //          throw new UnauthorizedAccessException("Cannot determine access rights for this file.");
            //      }
            //      // Если это аватар другого пользователя, и профили публичны, то доступ можно разрешить.
            //      // Если нет, то проверяем, currentUserId == targetUser.Id
            // }
             _logger.LogWarning("Could not determine access rights for file key {FileKey} for user {CurrentUserId} (file not found in any message or other context). Denying access.", fileKey, currentUserId);
            throw new UnauthorizedAccessException("Cannot determine access rights for this file or file not found.");
        }

        return await _fileStorageRepository.GeneratePresignedUrlAsync(fileKey, TimeSpan.FromHours(1));
    }

    public async Task DeleteAttachmentAsync(Guid currentUserId, string fileKey)
    {
        _logger.LogInformation("User {CurrentUserId} attempting to delete attachment with key {FileKey}", currentUserId, fileKey);
        if (string.IsNullOrWhiteSpace(fileKey)) throw new ArgumentException("File key is required.");

        // Проверка прав на удаление:
        // Пользователь может удалить файл, если он отправитель сообщения, к которому прикреплен файл.
        // Админы/владельцы чата могут удалять сообщения (и, следовательно, файлы) в своих чатах.
        
        // Ищем сообщение, содержащее этот fileKey
        // Нужен метод: Task<Message?> GetMessageByFileKeyAsync(string fileKey, CancellationToken cancellationToken = default);
        Message? message = await _unitOfWork.Messages.GetByAttachmentKeyAsync(fileKey); 

        if (message == null)
        {
            // TODO: Реализовать логику удаления для аватаров или других файлов, не связанных с сообщениями, если это необходимо.
            // Пример:
            // var user = await _unitOfWork.Users.GetByIdAsync(currentUserId);
            // if (user != null && user.ProfileImageUrl == fileKey) {
            //     // Пользователь удаляет свой собственный аватар
            //     await _fileStorageRepository.DeleteFileAsync(fileKey);
            //     user.ProfileImageUrl = null; // или на URL по умолчанию
            //     await _unitOfWork.Users.UpdateAsync(user);
            //     await _unitOfWork.CommitAsync();
            //     _logger.LogInformation("User {CurrentUserId} deleted their avatar {FileKey}.", currentUserId, fileKey);
            //     return;
            // }

            _logger.LogWarning("File {FileKey} not found in any message or no permission for user {CurrentUserId} to delete (file not a message attachment or other context).", fileKey, currentUserId);
            throw new UnauthorizedAccessException("You do not have permission to delete this file or file not found.");
        }

        bool canDelete = false;
        if (message.SenderId == currentUserId)
        {
            canDelete = true;
        }
        else
        {
            var chatMember = await _unitOfWork.Chats.GetChatMemberAsync(message.ChatId, currentUserId);
            if (chatMember != null && (chatMember.Role == ChatMemberRole.Admin || chatMember.Role == ChatMemberRole.Owner))
            {
                // TODO: Добавить более гранулярную проверку прав (может ли админ удалять *любые* файлы в чате, или только файлы из удаляемых им сообщений)
                canDelete = true; 
            }
        }

        if (!canDelete)
        {
            _logger.LogWarning("User {CurrentUserId} does not have permission to delete file {FileKey} from message {MessageId}", currentUserId, fileKey, message.Id);
            throw new UnauthorizedAccessException("You do not have permission to delete this file.");
        }

        await _fileStorageRepository.DeleteFileAsync(fileKey);
        _logger.LogInformation("File {FileKey} deleted from S3 by user {CurrentUserId}.", fileKey, currentUserId);

        // Удаляем метаданные файла из сообщения в MongoDB
        message.Attachments.RemoveAll(a => a.FileKey == fileKey);
        await _unitOfWork.Messages.UpdateAsync(message); // UpdateAsync в MessageRepository должен обновить весь документ
        _logger.LogInformation("Attachment metadata for {FileKey} removed from message {MessageId}", fileKey, message.Id);
    }
}