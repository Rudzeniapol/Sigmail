namespace SigmailServer.Domain.Interfaces;

public interface IFileStorageRepository
{
    Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType, CancellationToken cancellationToken = default);
    Task DeleteFileAsync(string fileKey, CancellationToken cancellationToken = default);
    Task<string> GeneratePresignedUrlAsync(string fileKey, TimeSpan duration, CancellationToken cancellationToken = default);
    Task<Stream> DownloadFileAsync(string fileKey, CancellationToken cancellationToken = default);
}