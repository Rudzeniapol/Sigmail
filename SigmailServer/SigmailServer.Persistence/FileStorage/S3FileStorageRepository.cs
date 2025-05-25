using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Microsoft.Extensions.Options;
using SigmailClient.Domain.Interfaces;
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace SigmailClient.Persistence.FileStorage;

public class S3FileStorageRepository : IFileStorageRepository
{
    private readonly IAmazonS3 _s3Client;
    private readonly S3StorageSettings _settings;

    public S3FileStorageRepository(IAmazonS3 s3Client, IOptions<S3StorageSettings> settings)
    {
        _s3Client = s3Client ?? throw new ArgumentNullException(nameof(s3Client));
        _settings = settings?.Value ?? throw new ArgumentNullException(nameof(settings));
    }

    public async Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType, CancellationToken cancellationToken = default)
    {
        // Генерируем уникальный ключ для файла, чтобы избежать коллизий имен
        var fileKey = $"{Guid.NewGuid()}-{Path.GetFileName(fileName)}";

        var parallèles = new TransferUtilityUploadRequest
        {
            InputStream = fileStream,
            Key = fileKey,
            BucketName = _settings.BucketName,
            ContentType = contentType,
            // Можно добавить метаданные, если нужно, например, оригинальное имя файла
            // Metadata = { ["original-filename"] = fileName }
        };

        // Используем TransferUtility для упрощения загрузки, особенно для больших файлов
        var transferUtility = new TransferUtility(_s3Client);
        await transferUtility.UploadAsync(parallèles, cancellationToken);

        return fileKey; // Возвращаем ключ, по которому файл сохранен в S3
    }

    public async Task DeleteFileAsync(string fileKey, CancellationToken cancellationToken = default)
    {
        var deleteObjectRequest = new DeleteObjectRequest
        {
            BucketName = _settings.BucketName,
            Key = fileKey
        };
        await _s3Client.DeleteObjectAsync(deleteObjectRequest, cancellationToken);
    }

    public Task<string> GeneratePresignedUrlAsync(string fileKey, TimeSpan duration, CancellationToken cancellationToken = default)
    {
        var request = new GetPreSignedUrlRequest
        {
            BucketName = _settings.BucketName,
            Key = fileKey,
            Expires = DateTime.UtcNow.Add(duration)
            // HttpMethod = HttpVerb.GET // По умолчанию GET
        };
        string url = _s3Client.GetPreSignedURL(request);
        return Task.FromResult(url);
    }

    public async Task<Stream> DownloadFileAsync(string fileKey, CancellationToken cancellationToken = default)
    {
        var request = new GetObjectRequest
        {
            BucketName = _settings.BucketName,
            Key = fileKey
        };

        var response = await _s3Client.GetObjectAsync(request, cancellationToken);
        // response.ResponseStream нужно будет правильно обработать (например, скопировать в MemoryStream, если нужно)
        // и убедиться, что он будет закрыт вызывающим кодом.
        // Для простоты возвращаем ResponseStream напрямую. Пользователь стрима отвечает за его Dispose.
        return response.ResponseStream;
    }
}