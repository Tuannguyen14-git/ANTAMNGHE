import 'package:flutter/foundation.dart' show kIsWeb;

class ServiceConfig {
  static const String productionBaseUrl = 'https://antamnghe-api.onrender.com';

  // Default baseUrl (will be overridden in `main.dart` when using
  // --dart-define=API_BASE_URL). Production points at Render by default.
  // For local development, pass API_BASE_URL explicitly.
  static String baseUrl = kIsWeb
      ? productionBaseUrl
      : productionBaseUrl;
}
