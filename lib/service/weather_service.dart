import 'package:weather_app/api/api_repository.dart';
import 'package:weather_app/model/current_weather_data.dart';
import 'package:weather_app/model/five_days_data.dart';
import 'package:weather_app/service/local_storage_service.dart';
import 'package:weather_app/utils/env_loader.dart'; // ✅ ADDED

class WeatherService {
  final String city;
  final String units;

  // ✅ Use EnvLoader for environment variables
  String get baseUrl => EnvLoader.baseUrl;
  String get apiKey => EnvLoader.apiKey;

  WeatherService({required this.city, String? units}) 
      : units = units ?? EnvLoader.defaultUnits;

  // Static factory method to create service with current settings
  static Future<WeatherService> create(String city) async {
    try {
      final settings = await LocalStorageService().getSettings();
      final unit = settings['temperatureUnit'] ?? EnvLoader.defaultUnits;
      return WeatherService(city: city, units: unit);
    } catch (e) {
      print('❌ Error creating WeatherService: $e');
      // Fallback to default units
      return WeatherService(city: city, units: EnvLoader.defaultUnits);
    }
  }

  // Helper method to validate API key is loaded
  void _validateApiKey() {
    if (!EnvLoader.isApiKeyValid) {
      throw Exception('API Key not found or invalid. Please check your assets/.env file');
    }
  }

  void getCurrentWeatherData({
    Function()? beforeSend,
    Function(CurrentWeatherData data)? onSuccess,
    Function(dynamic error)? onError,
  }) async {
    try {
      // Validate API key before making request
      _validateApiKey();
      
      if (beforeSend != null) beforeSend();

      final url = '$baseUrl/weather?q=$city&units=$units&lang=en&appid=$apiKey';
      
      // Log safe URL (without API key)
      final safeUrl = url.replaceAll(apiKey, '***HIDDEN***');
      print('🌤️ Fetching current weather: $safeUrl');

      ApiRepository(url: url).get(
        onSuccess: (data) {
          print('✅ Current weather data received for $city');
          onSuccess?.call(CurrentWeatherData.fromJson(data));
        },
        onError: (error) {
          print('❌ Weather API Error for $city: $error');
          onError?.call(error);
        },
      );
    } catch (e) {
      print('❌ Error in getCurrentWeatherData: $e');
      onError?.call(e.toString());
    }
  }

  void getFiveDaysThreeHoursForcastData({
    Function()? beforeSend,
    Function(List<FiveDayData> data)? onSuccess,
    Function(dynamic error)? onError,
  }) async {
    try {
      // Validate API key before making request
      _validateApiKey();
      
      if (beforeSend != null) beforeSend();

      final url = '$baseUrl/forecast?q=$city&units=$units&lang=en&appid=$apiKey';
      
      // Log safe URL
      final safeUrl = url.replaceAll(apiKey, '***HIDDEN***');
      print('📅 Fetching 5-day forecast: $safeUrl');

      ApiRepository(url: url).get(
        onSuccess: (data) {
          print('✅ 5-day forecast data received for $city');
          final forecastList = (data['list'] as List)
              .map((item) => FiveDayData.fromJson(item))
              .toList();
          onSuccess?.call(forecastList);
        },
        onError: (error) {
          print('❌ Forecast API Error for $city: $error');
          onError?.call(error);
        },
      );
    } catch (e) {
      print('❌ Error in getFiveDaysThreeHoursForcastData: $e');
      onError?.call(e.toString());
    }
  }
  
  // Optional: Helper method to get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
  
  // Optional: Validate city name
  static bool isValidCityName(String city) {
    return city.trim().isNotEmpty && city.length >= 2;
  }
}