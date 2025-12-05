
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app/controller/HomeController.dart';
import 'package:weather_app/model/current_weather_data.dart';
import 'package:weather_app/model/favorite_city.dart';
import 'package:weather_app/pages/weather_detail_page.dart';
import 'package:weather_app/service/local_storage_service.dart';
import 'package:weather_app/service/weather_service.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final LocalStorageService _storage = LocalStorageService();
  final HomeController _controller = Get.find<HomeController>();

  List<CurrentWeatherData> favoriteWeathers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      favoriteWeathers.clear();
    });

    final favoriteCities = await _storage.getFavorites();

    if (favoriteCities.isEmpty) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    // الحل الصحيح: نأخذ الوحدة الحالية من الـ Controller بدون await
    final String currentUnit = _controller.currentUnit.value;
    final String apiUnit = currentUnit == 'C' ? 'metric' : 'imperial';

    for (var city in favoriteCities) {
      try {
        final service = WeatherService(city: city.name, units: apiUnit);

        service.getCurrentWeatherData(
          onSuccess: (data) {
            if (!mounted) return;

            setState(() {
              // تجنب التكرار
              if (!favoriteWeathers.any((w) => w.id == data.id)) {
                favoriteWeathers.add(data);
              }
            });
          },
          onError: (error) {
            print('Failed to load weather for ${city.name}: $error');
          },
        );
      } catch (e) {
        print('Exception loading ${city.name}: $e');
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeFavorite(String cityName) async {
    await _storage.removeFavorite(cityName);

    setState(() {
      favoriteWeathers.removeWhere((w) => w.name == cityName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$cityName removed from favorites'),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cities'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadFavorites,
            tooltip: 'Refresh favorites',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteWeathers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 90, color: Colors.grey[400]),
                      SizedBox(height: 20),
                      Text(
                        'No favorite cities yet',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap the heart icon on any city to save it here',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: favoriteWeathers.length,
                  itemBuilder: (context, index) {
                    final weather = favoriteWeathers[index];
                    final temp = weather.main?.temp?.round() ?? 0;
                    final desc = weather.weather?[0].description ?? 'Clear';
                    final iconCode = weather.weather?[0].icon ?? '01d';

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://openweathermap.org/img/wn/$iconCode@2x.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.cloud, size: 50, color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          weather.name ?? 'Unknown City',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            // درجة الحرارة + الوحدة الصحيحة (C/F)
                            Obx(() => Text(
                                  '$temp°${_controller.currentUnit.value}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _controller.currentUnit.value == 'F'
                                        ? Colors.orange[700]
                                        : Colors.blue[700],
                                  ),
                                )),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                desc.capitalizeFirst ?? '',
                                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red, size: 30),
                          onPressed: () => _removeFavorite(weather.name!),
                        ),
                        onTap: () {
                          Get.to(() => WeatherDetailPage(cityName: weather.name!));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

// Extension لتحويل أول حرف كابيتال
extension StringExtension on String? {
  String? get capitalizeFirst {
    if (this == null || this!.isEmpty) return this;
    return this![0].toUpperCase() + this!.substring(1);
  }
}