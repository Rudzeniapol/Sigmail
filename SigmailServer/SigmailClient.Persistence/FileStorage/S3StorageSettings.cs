namespace SigmailClient.Persistence.FileStorage;


public class S3StorageSettings
{
    public string BucketName { get; set; } = null!;
    public string AWSAccessKeyId { get; set; } = null!;
    public string AWSSecretAccessKey { get; set; } = null!;
    public string Region { get; set; } = null!;
}