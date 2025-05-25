FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["SigmailServer.API/SigmailServer.API.csproj", "SigmailServer.API/"]
COPY ["SigmailServer.Domain/SigmailServer.Domain.csproj", "SigmailServer.Domain/"]
COPY ["SigmailServer.Persistence/SigmailServer.Persistence.csproj", "SigmailServer.Persistence/"]
COPY ["SigmailServer.Application/SigmailServer.Application.csproj", "SigmailServer.Application/"]
RUN dotnet restore "SigmailServer.API/SigmailServer.API.csproj"
COPY . .
WORKDIR "/src/SigmailServer.API"
RUN dotnet build "SigmailServer.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Development
RUN dotnet publish "SigmailServer.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SigmailServer.API.dll"]
