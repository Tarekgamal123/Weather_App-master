
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/controller/HomeController.dart';
import 'package:weather_app/service/local_storage_service.dart';
import 'package:weather_app/model/favorite_city.dart';

class WeatherDetailPage extends StatefulWidget {
  final String cityName;
  const WeatherDetailPage({required this.cityName, Key? key}) : super(key: key);

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  final HomeController controller = Get.find<HomeController>();
  final LocalStorageService storage = LocalStorageService();
  late Future<bool> isFavoriteFuture;

  @override
  void initState() {
    super.initState();
    _refreshFavoriteStatus();
  }

  void _refreshFavoriteStatus() {
    isFavoriteFuture = storage.isFavorite(widget.cityName);
  }

  Future<void> _toggleFavorite() async {
    final weather = controller.currentWeatherData;
    if (weather == null) return;

    final bool currentlyFav = await isFavoriteFuture;

    if (currentlyFav) {
      await storage.removeFavorite(widget.cityName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.cityName} removed from favorites'), backgroundColor: Colors.red[600]),
      );
    } else {
      final coord = weather.coord;
      final sys = weather.sys;
      final fav = FavoriteCity(
        name: widget.cityName,
        country: sys?.country ?? '',
        lat: coord?.lat ?? 0.0,
        lon: coord?.lon ?? 0.0,
        savedAt: DateTime.now(),
      );
      await storage.saveFavorite(fav);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.cityName} added to favorites ♥'), backgroundColor: Colors.green[600]),
      );
    }
    setState(() => _refreshFavoriteStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName),
        actions: [
          FutureBuilder<bool>(
            future: isFavoriteFuture,
            builder: (context, snapshot) {
              final bool isFav = snapshot.data ?? false;
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFav), color: isFav ? Colors.red : null),
                ),
                onPressed: _toggleFavorite,
              );
            },
          ),
        ],
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (controller.currentWeatherData == null) {
            return Center(child: Text('No weather data'));
          }

          final w = controller.currentWeatherData!;
          final main = w.main;
          final wind = w.wind;
          final sys = w.sys;
          final timezone = w.timezone ?? 0;
          final iconUrl = 'https://openweathermap.org/img/wn/${w.weather?[0].icon}@4x.png';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Image.network(iconUrl, width: 180, height: 180,
                    errorBuilder: (_, __, ___) => Icon(Icons.cloud_off, size: 100)),
                SizedBox(height: 10),

                // درجة الحرارة مع الوحدة الصحيحة
                Obx(() => Text(
                  '${main?.temp?.round() ?? '-'}°${controller.currentUnit.value}',
                  style: TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
                )),

                Text(w.weather?[0].description?.toUpperCase() ?? '', style: TextStyle(fontSize: 22, color: Colors.grey[700])),

                SizedBox(height: 10),
                Obx(() => Text('Feels like ${main?.feelsLike?.round() ?? '-'}°${controller.currentUnit.value}',
                    style: TextStyle(fontSize: 18, color: Colors.grey))),

                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Text('H: ${main?.tempMax?.round() ?? '-'}°${controller.currentUnit.value}', style: TextStyle(fontSize: 20))),
                    SizedBox(width: 30),
                    Obx(() => Text('L: ${main?.tempMin?.round() ?? '-'}°${controller.currentUnit.value}', style: TextStyle(fontSize: 20))),
                  ],
                ),

                SizedBox(height: 30),
                Divider(),

                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _card(Icons.water_drop, 'Humidity', '${main?.humidity ?? '-'}%'),
                    _card(Icons.air, 'Wind', '${wind?.speed ?? '-'} m/s'),
                    _card(Icons.speed, 'Pressure', '${main?.pressure ?? '-'} hPa'),
                    _card(Icons.visibility, 'Visibility', '${(w.visibility ?? 0) ~/ 1000} km'),
                    _card(Icons.wb_sunny, 'Sunrise', _formatTime(sys?.sunrise, timezone)),
                    _card(Icons.nightlight, 'Sunset', _formatTime(sys?.sunset, timezone)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  String _formatTime(int? timestamp, int offset) {
    if (timestamp == null) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        .add(Duration(seconds: offset));
    return DateFormat('h:mm a').format(date);
  }
}