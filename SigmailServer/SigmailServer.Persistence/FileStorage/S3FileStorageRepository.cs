using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Microsoft.Extensions.Options;
using SigmailServer.Domain.Interfaces;

namespace SigmailServer.Persistence.FileStorage;

public class S3FileStorageRepository : IFileStorageRepository
{
    private readonly IAmazonS3 _s3Client;
    private readonly S3StorageSettings _settings;
    // private readonly ILogger<S3FileStorageRepository> _logger; // Если нужно логирование ошибок

    public S3FileStorageRepository(IAmazonS3 s3Client, IOptions<S3StorageSettings> settings /*, ILogger<S3FileStorageRepository> logger*/)
    {
        _s3Client = s3Client ?? throw new ArgumentNullException(nameof(s3Client));
        _settings = settings?.Value ?? throw new ArgumentNullException(nameof(settings));
        // _logger = logger;
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
            Expires = DateTime.UtcNow.Add(duration),
            Verb = HttpVerb.PUT,
        };

        // Если PublicPresignedUrlHostPort задан, добавляем его как заголовок Host
        // Это повлияет на то, как SDK генерирует подпись.
        if (!string.IsNullOrEmpty(_settings.PublicPresignedUrlHostPort))
        {
            request.Headers["Host"] = _settings.PublicPresignedUrlHostPort;
            Console.WriteLine($"[S3FileStorageRepository] Added 'Host' header for presigning: {_settings.PublicPresignedUrlHostPort}");
        }

        string generatedUrlBySdk = _s3Client.GetPreSignedURL(request);
        
        Console.WriteLine($"[S3FileStorageRepository] SDK Generated Presigned URL (with potential Host header): {generatedUrlBySdk}");
        Console.WriteLine($"[S3FileStorageRepository] Query parameters of generated URL: {new Uri(generatedUrlBySdk).Query}");

        // Важно: Логику модификации URL здесь оставляем УДАЛЕННОЙ.
        // Клиент должен будет заменить minio:9000 на 10.0.2.2:9000 в этом URL.

        return Task.FromResult(generatedUrlBySdk);
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