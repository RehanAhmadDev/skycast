class WeatherBackgrounds {
  static String getBackgroundUrl(String? iconCode) {
    // Agar data na ho toh default image
    if (iconCode == null) {
      return 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=1000';
    }

    switch (iconCode) {
      case '01d': // Sunny Day
        return 'https://images.unsplash.com/photo-1601297183314-004fd21b8b6f?q=80&w=1000';
      case '01n': // Clear Night
        return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=1000';
      case '02d':
      case '03d':
      case '04d': // Cloudy Day
        return 'https://images.unsplash.com/photo-1534088568595-a066f410cbda?q=80&w=1000';
      case '02n':
      case '03n':
      case '04n': // Cloudy Night
        return 'https://images.unsplash.com/photo-1532074534361-bb09a38cf917?q=80&w=1000';
      case '09d':
      case '09n':
      case '10d':
      case '10n': // Rain
        return 'https://images.unsplash.com/photo-1519692933481-e162a57d6721?q=80&w=1000';
      case '11d':
      case '11n': // Thunderstorm
        return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0ce3c?q=80&w=1000';
      case '13d':
      case '13n': // Snow
        return 'https://images.unsplash.com/photo-1542601098-3adb3baeb1ec?q=80&w=1000';
      case '50d':
      case '50n': // Fog / Mist
        return 'https://images.unsplash.com/photo-1485236715568-ddc5ee6ca227?q=80&w=1000';
      default:
        return 'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=1000';
    }
  }
}