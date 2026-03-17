import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'api_constants.dart';
import 'weather_model.dart';

class WeatherService {
  Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final url = Uri.parse('${ApiConstants.baseUrl}?q=$cityName&appid=${ApiConstants.apiKey}&units=metric');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('City not found');
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  Future<WeatherModel> fetchWeatherByLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw Exception('Permission denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    final url = Uri.parse('${ApiConstants.baseUrl}?lat=${position.latitude}&lon=${position.longitude}&appid=${ApiConstants.apiKey}&units=metric');

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load location weather');
    }
  }
}