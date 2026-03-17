// lib/utils/weather_animations.dart

class WeatherAnimations {
  static String getWeatherAnimation(String? iconCode) {
    // Default Animation (Sunny)
    const String sunny = 'https://raw.githubusercontent.com/abuanwar072/Flutter-Weather-App-UI/master/assets/lottie/sunny.json';
    const String rainy = 'https://raw.githubusercontent.com/abuanwar072/Flutter-Weather-App-UI/master/assets/lottie/rainy.json';
    const String cloudy = 'https://raw.githubusercontent.com/abuanwar072/Flutter-Weather-App-UI/master/assets/lottie/cloudy.json';
    const String thunder = 'https://raw.githubusercontent.com/abuanwar072/Flutter-Weather-App-UI/master/assets/lottie/thunder.json';
    const String snow = 'https://raw.githubusercontent.com/abuanwar072/Flutter-Weather-App-UI/master/assets/lottie/snow.json';

    if (iconCode == null) return sunny;

    switch (iconCode) {
      case '01d':
      case '01n': return sunny;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n': return cloudy;
      case '09d':
      case '09n':
      case '10d':
      case '10n': return rainy;
      case '11d':
      case '11n': return thunder;
      case '13d':
      case '13n': return snow;
      case '50d':
      case '50n': return cloudy; // Mist/Fog
      default: return sunny;
    }
  }
}