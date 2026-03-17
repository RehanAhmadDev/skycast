// lib/providers/weather_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../data/weather_service.dart';
import '../data/weather_model.dart';

// 1. State Class (Jo UI ko batayegi ke kya dikhana hai)
class WeatherState {
  final WeatherModel? weather;
  final bool isLoading;
  final String errorMessage;

  WeatherState({this.weather, this.isLoading = false, this.errorMessage = ''});

  WeatherState copyWith({WeatherModel? weather, bool? isLoading, String? errorMessage}) {
    return WeatherState(
      weather: weather ?? this.weather,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Notifier Class (Asli Logic yahan hai)
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _weatherService = WeatherService();

  WeatherNotifier() : super(WeatherState()) {
    _loadLastCity(); // App khulte hi memory se city load karega
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('saved_city') ?? 'Dera Ismail Khan';
    fetchWeather(lastCity);
  }

  Future<void> fetchWeather(String cityName) async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      final weather = await _weatherService.fetchWeatherByCity(cityName);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_city', weather.cityName);

      state = state.copyWith(weather: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.weather == null ? "City not found" : "",
      );
    }
  }

  Future<void> fetchWeatherByLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Kripya GPS (Location) on karein.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission nahi mili.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission settings se allow karein.');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final weather = await _weatherService.fetchWeatherByLocation(position.latitude, position.longitude);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_city', weather.cityName);

      state = state.copyWith(weather: weather, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }
}

// 3. Provider (Jise UI use karega)
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});