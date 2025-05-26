namespace SigmailClient.Persistence.FileStorage;


public class S3StorageSettings
{
    public string BucketName { get; set; } = string.Empty;

    /// <summary>
    /// AWS Access Key ID. Для MinIO это MINIO_ROOT_USER.
    /// </summary>
    public string AWSAccessKeyId { get; set; } = string.Empty;

    /// <summary>
    /// AWS Secret Access Key. Для MinIO это MINIO_ROOT_PASSWORD.
    /// </summary>
    public string AWSSecretAccessKey { get; set; } = string.Empty;

    /// <summary>
    /// Регион AWS, например, "us-east-1", "eu-central-1".
    /// Для MinIO это поле может быть формальным, но SDK часто его требует.
    /// </summary>
    public string Region { get; set; } = string.Empty;

    /// <summary>
    /// URL сервиса S3.
    /// Для Amazon S3 это поле обычно не заполняется (SDK определяет URL по региону).
    /// Для MinIO или других S3-совместимых хранилищ здесь указывается их эндпоинт,
    /// например, "http://localhost:9000" или "http://minio:9000".
    /// </summary>
    public string? ServiceURL { get; set; }

    public bool ForcePathStyle { get; set; }

    public string? PublicPresignedUrlHostPort { get; set; }
}