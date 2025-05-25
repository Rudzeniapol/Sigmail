using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.SignalR; // Для IUserIdProvider
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text;
using System.Security.Claims; // Для ClaimTypes

// Ваши пространства имен
using SigmailClient.Domain.Interfaces;
using SigmailClient.Persistence;
using SigmailClient.Persistence.MongoDB;
using SigmailClient.Persistence.PostgreSQL;
using SigmailClient.Persistence.FileStorage;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Application.Services;
using SigmailServer.Application.DTOs.MappingProfiles; // Для регистрации AutoMapper профилей
using Amazon.S3; // Для IAmazonS3
using Amazon.Runtime; // Для BasicAWSCredentials
using Amazon;
using SigmailServer; // Для RegionEndpoint

var builder = WebApplication.CreateBuilder(args);

// 1. Конфигурация сервисов (Dependency Injection)
// ==================================================

// Загрузка конфигураций
builder.Services.Configure<MongoDbSettings>(builder.Configuration.GetSection("MongoDbSettings"));
builder.Services.Configure<S3StorageSettings>(builder.Configuration.GetSection("S3StorageSettings"));
builder.Services.Configure<AttachmentSettings>(builder.Configuration.GetSection("AttachmentSettings"));

// AutoMapper
// Регистрирует все профили из сборки, где находится UserProfile (т.е. SigmailServer.Application)
// Убедитесь, что класс UserProfile (и другие ваши профили) находится в этой сборке.
builder.Services.AddAutoMapper(typeof(UserProfile).Assembly);


// Контексты баз данных
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("PostgreSQLConnection")));
builder.Services.AddSingleton<MongoDbContext>(); // Зависит от IOptions<MongoDbSettings>

// Репозитории
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IChatRepository, ChatRepository>();
builder.Services.AddScoped<IContactRepository, ContactRepository>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<INotificationRepository, NotificationRepository>();
builder.Services.AddScoped<IFileStorageRepository, S3FileStorageRepository>();

// Сервисы приложения
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddScoped<IMessageService, MessageService>();
builder.Services.AddScoped<IContactService, ContactService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IAttachmentService, AttachmentService>();
builder.Services.AddScoped<IRealTimeNotifier, SignalRNotifier>();

builder.Services.AddSingleton<IPasswordHasher, PasswordHasher>();
builder.Services.AddSingleton<IJwtTokenGenerator, JwtTokenGenerator>();

// AWS S3 Client
var s3Settings = builder.Configuration.GetSection("S3StorageSettings").Get<S3StorageSettings>();
if (s3Settings != null && !string.IsNullOrEmpty(s3Settings.ServiceURL)) // Проверяем наличие ServiceURL
{
    var s3Config = new AmazonS3Config
    {
        RegionEndpoint = RegionEndpoint.GetBySystemName(s3Settings.Region), // Регион все еще нужен
        ServiceURL = s3Settings.ServiceURL, // <-- Вот это для MinIO
        ForcePathStyle = true // <-- И это часто важно для MinIO
    };
    builder.Services.AddSingleton<IAmazonS3>(new AmazonS3Client(s3Settings.AWSAccessKeyId, s3Settings.AWSSecretAccessKey, s3Config));
    builder.Services.AddSingleton(s3Settings); 
}
else
{
    // Обработка ситуации, если S3Settings или ServiceURL не настроены
    // Можно логировать предупреждение или выбрасывать исключение, если S3 обязательно.
    Console.WriteLine("Warning: S3StorageSettings or ServiceURL is not configured. S3 functionality will be unavailable.");
}


// Аутентификация JWT
var jwtSettings = builder.Configuration.GetSection("Jwt");
var secretKey = jwtSettings["Key"];
if (string.IsNullOrEmpty(secretKey) || secretKey.Length < 32) // Проверка на существование и минимальную длину ключа
{
    // В реальном приложении это должно быть фатальной ошибкой или очень серьезным предупреждением.
    Console.Error.WriteLine("FATAL ERROR: JWT Key is not configured or is too short in appsettings.json. Application security is compromised.");
    // throw new ApplicationException("JWT Key is not configured or is too short. Application cannot start securely.");
    // Для целей этого примера, если ключ не задан, сгенерируем временный, НО ЭТО НЕ ДЛЯ ПРОДА!
    if (string.IsNullOrEmpty(secretKey)) secretKey = "THIS_IS_A_DEFAULT_DEV_ONLY_KEY_REPLACE_IT_NOW_0123456789";
    Console.WriteLine("WARNING: Using a default/placeholder JWT Key. THIS IS NOT SECURE FOR PRODUCTION.");
}

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey ?? "FallbackKey_IsNotSecure_ChangeInConfig")), // Fallback на случай если проверка выше не сработала
        ClockSkew = TimeSpan.Zero // Убираем стандартное 5-минутное допустимое расхождение времени
    };
    // Для SignalR, чтобы токен передавался в query string, когда WebSocket не поддерживает заголовки
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/chathub")) // Путь к вашему SignalR хабу
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});

// Авторизация (если есть какие-то политики)
builder.Services.AddAuthorization();

// SignalR
builder.Services.AddSignalR();
// Позволяет SignalR идентифицировать пользователей по ClaimTypes.NameIdentifier (который вы установили как user.Id в JwtTokenGenerator)
builder.Services.AddSingleton<IUserIdProvider, NameIdentifierUserIdProvider>();


// CORS (Cross-Origin Resource Sharing) - настройте по своим нуждам
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMyClient", // Дайте политике осмысленное имя
        policy =>
        {
            policy.WithOrigins("http://localhost:3000", "https://your-client-domain.com") // Укажите URL вашего клиента
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials(); // Важно для SignalR с аутентификацией
        });
});


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer(); // Для Swagger

// Swagger Gen с поддержкой JWT
builder.Services.AddSwaggerGen(setup =>
{
    // Включаем XML-комментарии, если они у вас есть (нужно настроить в .csproj файле API проекта)
    // var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    // var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    // setup.IncludeXmlComments(xmlPath);

    setup.SwaggerDoc("v1", new OpenApiInfo { Title = "SigmailServer API", Version = "v1" });

    // Определяем схему безопасности для JWT
    setup.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    setup.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header,
            },
            new List<string>()
        }
    });
});

// Логгирование (базовая конфигурация уже есть, можно расширить)
builder.Services.AddLogging(loggingBuilder =>
{
    loggingBuilder.AddConsole();
    loggingBuilder.AddDebug();
});


// 2. Построение приложения
// =========================
var app = builder.Build();

// 3. Конфигурация конвейера HTTP-запросов (Middleware)
// ======================================================

// Swagger UI только в режиме разработки
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "SigmailServer API V1");
        // Опционально: для сохранения токена в Swagger UI после логина
    });
    try
    {
        using (var scope = app.Services.CreateScope())
        {
            var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>(); // Убедитесь, что ApplicationDbContext - ваш правильный DbContext
            Console.WriteLine("Attempting to apply migrations...");
            dbContext.Database.Migrate(); // Применяет миграции
            Console.WriteLine("Migrations applied successfully or no pending migrations.");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"CRITICAL ERROR: An error occurred while migrating the database: {ex.Message}");
        Console.WriteLine($"Stack Trace: {ex.StackTrace}");
        throw;
        // ВАЖНО: Рассмотрите возможность остановки приложения здесь, если миграции обязательны
        // throw; // Можно раскомментировать, чтобы приложение упало и ошибка была очевидна
    }
    app.UseDeveloperExceptionPage(); // Более детальные ошибки в разработке
}
else
{
    app.UseExceptionHandler("/Error"); // Нужен Error handling middleware или страница
    app.UseHsts(); // HTTP Strict Transport Security
}

app.UseHttpsRedirection(); // Перенаправляет HTTP на HTTPS

app.UseRouting(); // Важно, чтобы был перед CORS, Auth и Endpoints

app.UseCors("AllowMyClient"); // Применяем политику CORS

app.UseAuthentication(); // Middleware аутентификации
app.UseAuthorization(); // Middleware авторизации

// Маппинг контроллеров
app.MapControllers();

// Маппинг SignalR хаба
app.MapHub<SignalRChatHub>("/chathub"); // Укажите путь к вашему хабу


// Запуск приложения
app.Run();

