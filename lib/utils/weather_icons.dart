import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny;
      case '01n': return Icons.nightlight_round;
      case '02d': return Icons.wb_cloudy;
      case '02n': return Icons.cloud_queue;
      case '03d':
      case '03n': return Icons.cloud;
      case '04d':
      case '04n': return Icons.cloud_circle;
      case '09d':
      case '09n': return Icons.umbrella;
      case '10d':
      case '10n': return Icons.water_drop;
      case '11d':
      case '11n': return Icons.thunderstorm;
      case '13d':
      case '13n': return Icons.ac_unit;
      case '50d':
      case '50n': return Icons.filter_drama;
      default: return Icons.wb_cloudy;
    }
  }
}