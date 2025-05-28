using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.SignalR; // Для IUserIdProvider
using Microsoft.IdentityModel.Tokens;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using System.Text;
using System.Security.Claims; // Для ClaimTypes
using System.Text.Json.Serialization; // <--- Добавляем этот using

// Ваши пространства имен
using SigmailClient.Persistence;
using SigmailServer.Application.Services.Interfaces;
using SigmailServer.Application.Services;
using SigmailServer.Application.DTOs.MappingProfiles; // Для регистрации AutoMapper профилей
using Amazon.S3; // Для IAmazonS3
using Amazon.Runtime; // Для BasicAWSCredentials
using Amazon;
using SigmailServer;
using SigmailServer.Domain.Interfaces;
using SigmailServer.Persistence;
using SigmailServer.Persistence.FileStorage;
using SigmailServer.Persistence.MongoDB;
using SigmailServer.Persistence.PostgreSQL; // Для RegionEndpoint

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
builder.Services.AddScoped<IMessageReactionService, MessageReactionService>();

builder.Services.AddSingleton<IPasswordHasher, PasswordHasher>();
builder.Services.AddSingleton<IJwtTokenGenerator, JwtTokenGenerator>();

// AWS S3 Client
var s3Settings = builder.Configuration.GetSection("S3StorageSettings").Get<S3StorageSettings>();
if (s3Settings != null && !string.IsNullOrEmpty(s3Settings.ServiceURL)) // Проверяем наличие ServiceURL
{
    var s3Config = new AmazonS3Config
    {
        // RegionEndpoint = RegionEndpoint.GetBySystemName(s3Settings.Region), // РЕГИОН ЗАКОММЕНТИРОВАН
        ServiceURL = s3Settings.ServiceURL, // <-- Вот это для MinIO
        ForcePathStyle = true, // <-- И это часто важно для MinIO
        UseHttp = true // <--- ДОБАВЛЕНО: Явно указываем использовать HTTP
    };
    // Используем конструктор с BasicAWSCredentials и AmazonS3Config
    builder.Services.AddSingleton<IAmazonS3>(new AmazonS3Client(new BasicAWSCredentials(s3Settings.AWSAccessKeyId, s3Settings.AWSSecretAccessKey), s3Config));
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
            if (!string.IsNullOrEmpty(accessToken) && 
                (path.StartsWithSegments("/chathub") || path.StartsWithSegments("/userHub"))) // ИЗМЕНЕНО
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
builder.Services.AddSignalR()
    .AddJsonProtocol(options =>
    {
        options.PayloadSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    });
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


builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    }); // <--- Добавляем конфигурацию JSON для enum

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
        Console.Error.WriteLine($"Error applying migrations: {ex.Message}");
        // В зависимости от критичности, можно решить, останавливать ли приложение
    }
    app.UseDeveloperExceptionPage(); // Более детальные ошибки в разработке
}
else
{
    app.UseExceptionHandler("/Error"); // Нужен Error handling middleware или страница
    app.UseHsts(); // HTTP Strict Transport Security
}

// app.UseHttpsRedirection(); // Перенаправляет HTTP на HTTPS  <--- ЗАКОММЕНТИРОВАНО

app.UseRouting(); // Важно, чтобы был перед CORS, Auth и Endpoints

app.UseCors("AllowMyClient"); // Применяем политику CORS

app.UseAuthentication(); // Сначала аутентификация
app.UseAuthorization();  // Затем авторизация

app.MapControllers(); // Маппинг контроллеров API

// Маппинг хабов SignalR
app.UseEndpoints(endpoints =>
{
    endpoints.MapHub<SignalRChatHub>("/chatHub");
    endpoints.MapHub<UserHub>("/userHub");
    // Можно добавить health checks или другие эндпоинты здесь
    endpoints.MapControllers(); // Повторный вызов MapControllers здесь не нужен, если он есть выше без UseEndpoints
});

app.Run();

