class MainWeather {
  final double? temp;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final int? humidity;

  MainWeather({
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.humidity,
  });

  factory MainWeather.fromJson(dynamic json) {
    if (json == null) {
      return MainWeather();
    }

    // SIMPLE PARSING - NO CONVERSION
    // The API will return Celsius directly because of units=metric
    return MainWeather(
      temp: _toDouble(json['temp']),
      feelsLike: _toDouble(json['feels_like']),
      tempMin: _toDouble(json['temp_min']),
      tempMax: _toDouble(json['temp_max']),
      pressure: _toInt(json['pressure']),
      humidity: _toInt(json['humidity']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}