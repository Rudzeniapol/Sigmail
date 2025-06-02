# Sigmail Project

A modern cross-platform chat application with real-time messaging, file attachments, and group/private chats. Built with Flutter (client) and ASP.NET Core (backend).

## Features
- Real-time chat (SignalR)
- Group and private chats
- File attachments (images, documents, etc.)
- User authentication (JWT, refresh tokens)
- User status and presence
- Modern UI (Flutter)
- MinIO S3-compatible file storage
- PostgreSQL and MongoDB for data storage

## Project Structure
- `client/` — Flutter client app (Android, iOS, Web, Desktop)
- `SigmailServer/` — ASP.NET Core backend
  - `SigmailServer.API/` — Web API and SignalR hubs
  - `SigmailServer.Application/` — Business logic, services, DTOs
  - `SigmailServer.Domain/` — Domain models, interfaces
  - `SigmailServer.Persistence/` — Data access, repositories, migrations

## Quick Start

### Prerequisites
- Flutter SDK (3.x)
- .NET 9 SDK
- Docker (for MinIO, PostgreSQL, MongoDB)

### Running Backend
1. Go to `SigmailServer/` folder.
2. Start infrastructure (MinIO, PostgreSQL, MongoDB) with Docker Compose:
   ```powershell
   docker compose up -d
   ```
3. Run the backend:
   ```powershell
   cd SigmailServer.API
   dotnet run
   ```

### Running Client
1. Go to `client/` folder.
2. Install dependencies:
   ```powershell
   flutter pub get
   ```
3. Run the app (choose your platform):
   ```powershell
   flutter run
   ```

## Configuration
- Backend configs: `SigmailServer.API/appsettings.json`, `compose.yaml`
- Client API URL: `client/lib/core/config/app_config.dart`

## Main Technologies
- Flutter, Dart
- ASP.NET Core, C#
- SignalR
- PostgreSQL, MongoDB
- MinIO (S3-compatible)
- Docker Compose

## License
MIT

---
**Course Project, 2nd Year, 2025**
