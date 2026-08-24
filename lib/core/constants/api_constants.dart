import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  /// Production Backend or Cloudflare Worker URL
  static const String _productionUrl = 'https://fitlens-backend.your-domain.com';

  /// Public Secure HTTPS Tunnel (Accessible from anywhere worldwide on Wi-Fi or 4G/5G)
  static const String publicTunnelUrl = 'https://fitlens-api-uzair.loca.lt';
  
  /// Your PC's Local Network IP Address
  static const String hostMachineLanIp = 'http://172.28.18.147:3000';
  
  /// Android Emulator Loopback
  static const String emulatorIp = 'http://10.0.2.2:3000';

  /// Localhost (Web / Desktop / USB with adb reverse)
  static const String localhostUrl = 'http://localhost:3000';

  /// Custom override URL set by the user in Settings
  static String? customServerUrl;

  /// Initializes any saved custom server URL from local storage
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      customServerUrl = prefs.getString('custom_backend_url');
    } catch (_) {}
  }

  /// Sets a new custom server URL and saves to local storage
  static Future<void> setCustomServerUrl(String? url) async {
    customServerUrl = url?.trim().isEmpty == true ? null : url?.trim();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (customServerUrl != null) {
        await prefs.setString('custom_backend_url', customServerUrl!);
      } else {
        await prefs.remove('custom_backend_url');
      }
    } catch (_) {}
  }

  /// Determines the appropriate backend URL based on platform & environment
  static String get backendBaseUrl {
    if (customServerUrl != null && customServerUrl!.isNotEmpty) {
      return customServerUrl!;
    }

    if (kReleaseMode) {
      return _productionUrl;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      // Physical Android phone connects seamlessly via Public Tunnel or Wi-Fi IP
      return publicTunnelUrl;
    }

    // Web, iOS simulator, macOS, Windows
    return localhostUrl;
  }

  /// Standard HTTP headers (includes tunnel bypass)
  static Map<String, String> get defaultHeaders => {
    'bypass-tunnel-reminder': 'true',
    'User-Agent': 'FitLensApp/1.0',
  };

  /// Standard HTTP timeout duration for network requests
  static const Duration requestTimeout = Duration(seconds: 20);
}
