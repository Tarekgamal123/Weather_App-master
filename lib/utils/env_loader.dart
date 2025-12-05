import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvLoader {
  static bool _isLoaded = false;
  
  static Future<void> load() async {
    if (_isLoaded) return;
    
    try {
      print('📦 Loading environment variables from assets/.env...');
      
      // Load .env file from assets
      await dotenv.load(fileName: "assets/.env");
      _isLoaded = true;
      
      print('✅ Environment variables loaded successfully');
      
      // Validate required variables
      final apiKey = dotenv.env['WEATHER_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('WEATHER_API_KEY is missing in assets/.env');
      }
      
      // Print loaded values (hiding full API key for security)
      print('📱 API Key: ${apiKey.substring(0, 8)}...');
      print('🌐 Base URL: ${dotenv.env['BASE_URL']}');
      print('🌡️ Default Units: ${dotenv.env['DEFAULT_UNITS']}');
      
    } catch (e) {
      print('❌ Failed to load environment variables: $e');
      print('💡 Troubleshooting:');
      print('   1. Make sure assets/.env file exists');
      print('   2. Check .env is added to assets in pubspec.yaml');
      print('   3. File should contain: WEATHER_API_KEY=your_key_here');
      print('   4. Run: flutter clean && flutter pub get');
      rethrow;
    }
  }
  
  // Getters for environment variables
  static String get apiKey {
    if (!_isLoaded) {
      throw Exception('Environment variables not loaded. Call EnvLoader.load() first');
    }
    return dotenv.env['WEATHER_API_KEY'] ?? '';
  }
  
  static String get baseUrl {
    if (!_isLoaded) {
      throw Exception('Environment variables not loaded. Call EnvLoader.load() first');
    }
    return dotenv.env['BASE_URL'] ?? 'https://api.openweathermap.org/data/2.5';
  }
  
  static String get defaultUnits {
    if (!_isLoaded) {
      throw Exception('Environment variables not loaded. Call EnvLoader.load() first');
    }
    return dotenv.env['DEFAULT_UNITS'] ?? 'metric';
  }
  
  static bool get isApiKeyValid {
    final key = apiKey;
    return key.isNotEmpty && key.length > 20;
  }
  
  static bool get isLoaded => _isLoaded;
}