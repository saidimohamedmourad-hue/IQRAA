class ApiConfig {
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator → localhost
  static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator / web

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
