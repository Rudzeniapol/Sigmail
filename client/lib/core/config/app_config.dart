class AppConfig {
  // Базовый URL для API
  static const String baseUrl = 'http://172.17.80.111:5000/api'; // Для Android эмулятора
  // Если бы вы хотели легко переключаться:
  // static const String baseUrlHost = 'http://localhost:5000/api'; // Для Desktop/Web
  // static const String baseUrlEmulator = 'http://10.0.2.2:5000/api'; // Для Android эмулятора

  // Базовый URL для SignalR
  static const String signalRBaseUrl = 'http://172.17.80.111:5000'; // Для Android эмулятора
  // static const String signalRBaseUrlHost = 'http://localhost:5000'; // Для Desktop/Web
  // static const String signalRBaseUrlEmulator = 'http://10.0.2.2:5000'; // Для Android эмулятора
  static const String userHubUrl = '/userHub'; // Только путь
  static const String chatHubUrl = '/chatHub'; // Только путь

  // Можно добавить другие глобальные константы сюда
  // Например, ключи для SharedPreferences, настройки по умолчанию и т.д.
} 