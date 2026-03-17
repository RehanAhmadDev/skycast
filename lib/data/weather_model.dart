class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final List<ForecastItem> forecast; // Agle dinon ka data

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    required this.forecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> forecastJson) {
    var forecastList = (forecastJson['list'] as List)
        .where((item) => item['dt_txt'].contains("12:00:00")) // Sirf dopher ka data le rahe hain
        .map((i) => ForecastItem.fromJson(i))
        .toList();

    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      iconCode: json['weather'][0]['icon'],
      forecast: forecastList,
    );
  }
}

class ForecastItem {
  final DateTime date;
  final double temp;
  final String iconCode;

  ForecastItem({required this.date, required this.temp, required this.iconCode});

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      date: DateTime.parse(json['dt_txt']),
      temp: json['main']['temp'].toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }
}