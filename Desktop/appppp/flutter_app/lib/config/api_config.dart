import 'package:flutter/foundation.dart';

/// URL de l'API.
///
/// - **Debug** : IP locale par défaut (modifiable via `--dart-define=API_BASE_URL_DEV=...`).
/// - **Release (stores)** : obligatoire `--dart-define=API_BASE_URL=https://votre-domaine.com/api`.
class ApiConfig {
  static String get baseUrl {
    const prod = String.fromEnvironment('API_BASE_URL');
    if (prod.isNotEmpty) return prod;

    if (kReleaseMode) {
      throw StateError(
        'Build release sans API_BASE_URL. Exemple :\n'
        'flutter build appbundle --dart-define=API_BASE_URL=https://api.example.com/api',
      );
    }

    const dev = String.fromEnvironment(
      'API_BASE_URL_DEV',
      defaultValue: 'http://10.16.243.52:8000/api',
    );
    return dev;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
