import 'dart:io' show Platform;

class AppConfig {
  // Public Azure App Service base URL (HTTPS)
  static const String azureBaseUrl = 'https://<your-app>.azurewebsites.net';

  // Local dev endpoints (emulator/simulator)
  static const String androidBaseUrl = 'http://10.0.2.2:5277';
  static const String iosBaseUrl = 'http://localhost:5277';

  // Toggle this to true when pointing the app to Azure backend
  static const bool useAzure = false;

  static String get apiBaseUrl {
    if (useAzure) return azureBaseUrl;
    if (Platform.isAndroid) return androidBaseUrl;
    return iosBaseUrl; // iOS simulator default
  }

  static String get ordersHubUrl => '${apiBaseUrl}/hubs/orders';
}
