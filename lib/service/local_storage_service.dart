
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:weather_app/model/favorite_city.dart';

class LocalStorageService {
  // Singleton Pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Keys
  static const String _favoritesKey = 'favorite_cities_v2'; // غيرت الاسم عشان ما يتعارضش مع القديم
  static const String _settingsKey = 'app_settings';

  // ====================== Favorites ======================

  /// حفظ مدينة مفضلة (كاملة مع lat/lon/country)
  Future<void> saveFavorite(FavoriteCity city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    // تجنب التكرار (بناءً على الاسم + الدولة)
    final exists = favorites.any((c) =>
        c.name.toLowerCase() == city.name.toLowerCase() &&
        c.country == city.country);

    if (!exists) {
      favorites.add(city);
      final jsonList = favorites.map((c) => c.toMap()).toList();
      await prefs.setString(_favoritesKey, jsonEncode(jsonList));
    }
  }

  /// جلب كل المدن المفضلة
  Future<List<FavoriteCity>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => FavoriteCity.fromMap(json)).toList();
    } catch (e) {
      print('Error parsing favorites: $e');
      return [];
    }
  }

  /// حذف مدينة من المفضلة
  Future<void> removeFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((c) => c.name.toLowerCase() == cityName.toLowerCase());

    final jsonList = favorites.map((c) => c.toMap()).toList();
    await prefs.setString(_favoritesKey, jsonEncode(jsonList));
  }

  /// مسح جميع المفضلات (للإعدادات)
  Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }

  /// هل المدينة مفضلة؟
  Future<bool> isFavorite(String cityName) async {
    final favorites = await getFavorites();
    return favorites.any((c) => c.name.toLowerCase() == cityName.toLowerCase());
  }

  // ====================== Settings ======================

  /// حفظ الإعدادات
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings));
  }

  /// جلب الإعدادات (مع قيم افتراضية)
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(settingsJson));
      } catch (e) {
        print('Error parsing settings: $e');
      }
    }

    // القيم الافتراضية
    return {
      'temperatureUnit': 'metric',
      'language': 'en',
      'useGps': false,
    };
  }
}