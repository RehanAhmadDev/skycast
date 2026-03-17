import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final currentUrl = Uri.parse('${ApiConstants.baseUrl}?q=$cityName&appid=${ApiConstants.apiKey}&units=metric');
    final forecastUrl = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=${ApiConstants.apiKey}&units=metric');

    final currentRes = await http.get(currentUrl);
    final forecastRes = await http.get(forecastUrl);

    if (currentRes.statusCode == 200 && forecastRes.statusCode == 200) {
      return WeatherModel.fromJson(
        json.decode(currentRes.body),
        json.decode(forecastRes.body),
      );
    } else {
      throw Exception('Data fetch karne mein masla hai');
    }
  }

// Location wala function bhi isi tarah update kiya ja sakta hai
}