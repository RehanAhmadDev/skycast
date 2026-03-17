import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'api_constants.dart';
import 'weather_model.dart';

class WeatherService {
  // 1. Shehar ke naam se data lena
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final url = Uri.parse('${ApiConstants.baseUrl}?q=$cityName&appid=${ApiConstants.apiKey}&units=metric');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Data nahi mil saki.');
    }
  }

  // 2. GPS Location se data lena
  Future<WeatherModel> fetchWeatherByLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    final url = Uri.parse('${ApiConstants.baseUrl}?lat=${position.latitude}&lon=${position.longitude}&appid=${ApiConstants.apiKey}&units=metric');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Location data fail ho gaya.');
    }
  }
}