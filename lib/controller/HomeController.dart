
import 'package:get/get.dart';
import 'package:weather_app/model/current_weather_data.dart';
import 'package:weather_app/model/five_days_data.dart';
import 'package:weather_app/service/weather_service.dart';
import 'package:weather_app/service/local_storage_service.dart';

class HomeController extends GetxController {
  String city = 'Cairo';

  CurrentWeatherData? currentWeatherData;
  List<CurrentWeatherData> dataList = [];
  List<FiveDayData> fiveDaysData = [];

  bool isLoading = false;

  // ← أهم حاجة: الوحدة تتحدث تلقائيًا في كل الـ UI
  var currentUnit = 'C'.obs; // C أو F

  final List<String> cities = [
    'Cairo', 'Alexandria', 'London', 'Dubai', 'New York', 'Tokyo', 'Paris'
  ];

  HomeController();

  @override
  void onInit() {
    super.onInit();
    updateWeather();
  }

  Future<void> updateWeather({String? newCity}) async {
    if (newCity != null && newCity.isNotEmpty) {
      city = newCity.trim();
    }

    isLoading = true;
    update();

    try {
      final settings = await LocalStorageService().getSettings();
      final unit = settings['temperatureUnit'] ?? 'metric';

      // تحديث الوحدة في الـ UI فورًا
      currentUnit.value = (unit == 'imperial') ? 'F' : 'C';

      final weatherService = WeatherService(city: city, units: unit);

      // Current Weather
      weatherService.getCurrentWeatherData(
        onSuccess: (data) {
          currentWeatherData = data;
          isLoading = false;
          update();
        },
        onError: (error) {
          isLoading = false;
          update();
        },
      );

      // Forecast
      weatherService.getFiveDaysThreeHoursForcastData(
        onSuccess: (data) {
          fiveDaysData = data;
          update();
        },
      );

      // Default Cities
      dataList.clear();
      for (String c in cities) {
        final service = WeatherService(city: c, units: unit);
        service.getCurrentWeatherData(
          onSuccess: (data) {
            if (!dataList.any((d) => d.name == data.name)) {
              dataList.add(data);
              update();
            }
          },
        );
      }
    } catch (e) {
      isLoading = false;
      update();
    }
  }

  void searchCity(String cityName) {
    if (cityName.isNotEmpty) updateWeather(newCity: cityName);
  }

  void refreshWeather() => updateWeather();
}