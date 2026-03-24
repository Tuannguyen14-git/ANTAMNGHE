import 'package:flutter/foundation.dart' show kIsWeb;

class ServiceConfig {
  // Default baseUrl (will be overridden in `main.dart` when using
  // --dart-define=API_BASE_URL). Defaults chosen to match common dev setup:
  // - Web:     http://localhost:5195 (backend HTTP dev url)
  // - Mobile:  http://10.0.2.2:5195 (Android emulator -> host localhost)
  static String baseUrl = kIsWeb
      ? 'http://localhost:5195'
      : 'http://10.0.2.2:5195';
}
