class FiveDayData {
  final String? dateTime;
  final int? temp;

  FiveDayData({this.dateTime, this.temp});

  factory FiveDayData.fromJson(dynamic json) {
    if (json == null) {
      return FiveDayData();
    }

    var f = json['dt_txt'].split(' ')[0].split('-')[2];
    var l = json['dt_txt'].split(' ')[1].split(':')[0];
    var fandl = '$f-$l';
    
    // FIXED: Remove -273.15 conversion because API returns Celsius with units=metric
    return FiveDayData(
      dateTime: '$fandl',
      // BEFORE: temp: (double.parse(json['main']['temp'].toString()) - 273.15).round(),
      // AFTER: Just round the Celsius temperature
      temp: double.parse(json['main']['temp'].toString()).round(),
    );
  }
}