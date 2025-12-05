class FavoriteCity {
  final String name;
  final String country;
  final double lat;
  final double lon;
  final DateTime savedAt;

  FavoriteCity({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'country': country,
      'lat': lat,
      'lon': lon,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory FavoriteCity.fromMap(Map<String, dynamic> map) {
    return FavoriteCity(
      name: map['name'],
      country: map['country'],
      lat: map['lat'],
      lon: map['lon'],
      savedAt: DateTime.parse(map['savedAt']),
    );
  }
}