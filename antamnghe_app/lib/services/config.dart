import 'package:flutter/foundation.dart' show kIsWeb;

class ServiceConfig {
  // Default baseUrl (will be overridden in `main.dart` when using
  // --dart-define=API_BASE_URL). Defaults chosen to match common dev setup:
  // - Web:     https://localhost:7295 (backend HTTPS dev url)
  // - Mobile:  http://10.0.2.2:5000 (Android emulator -> host localhost)
  static String baseUrl = kIsWeb
      ? 'https://localhost:7295'
      : 'http://10.0.2.2:5000';
}
