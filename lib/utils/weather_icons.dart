import 'package:flutter/material.dart';

class WeatherIcons {
  // Yeh function API ke icon code ko real Flutter Icons mein convert karta hai
  static IconData getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny; // Saaf mausam (Din)
      case '01n':
        return Icons.nightlight_round; // Saaf mausam (Raat)
      case '02d':
        return Icons.wb_cloudy; // Thore badal (Din)
      case '02n':
        return Icons.cloud_queue; // Thore badal (Raat)
      case '03d':
      case '03n':
        return Icons.cloud; // Darmiyane badal
      case '04d':
      case '04n':
        return Icons.cloud_circle; // Ziyada badal
      case '09d':
      case '09n':
        return Icons.umbrella; // Halki barish
      case '10d':
      case '10n':
        return Icons.water_drop; // Barish
      case '11d':
      case '11n':
        return Icons.thunderstorm; // Bijli aur garaj
      case '13d':
      case '13n':
        return Icons.ac_unit; // Barfbari (Snow)
      case '50d':
      case '50n':
        return Icons.filter_drama; // Dhund (Mist/Fog)
      default:
        return Icons.wb_cloudy; // Default icon agar kuch na mile
    }
  }
}