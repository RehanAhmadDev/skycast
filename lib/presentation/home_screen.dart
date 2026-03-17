import 'package:flutter/material.dart';
import '../data/weather_service.dart';
import '../data/weather_model.dart';
import '../utils/weather_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Ab yahan error nahi aayega kyunke import theek hai
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  WeatherModel? _weather;
  bool _isLoading = false;
  String _errorMessage = '';

  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _fetchWeather('Dera Ismail Khan');

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: Colors.blue.shade900,
      end: Colors.blue.shade400,
    ).animate(_backgroundController);
  }

  Future<void> _fetchWeather(String cityName) async {
    if (cityName.trim().isEmpty) return;
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final weather = await _weatherService.fetchWeatherByCity(cityName);
      setState(() { _weather = weather; _isLoading = false; });
    } catch (e) {
      setState(() {
        _errorMessage = 'City nahi mil saki ya internet band hai.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() { _isLoading = true; _errorMessage = ''; _searchController.clear(); });
    try {
      final weather = await _weatherService.fetchWeatherByLocation();
      setState(() { _weather = weather; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = 'Location permission nahi mili.'; _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundAnimation.value,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search city...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                              prefixIcon: const Icon(Icons.search, color: Colors.white),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onSubmitted: _fetchWeather,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _fetchCurrentLocation,
                        icon: const Icon(Icons.my_location, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (_isLoading)
                    const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.white)))
                  else if (_errorMessage.isNotEmpty)
                    Expanded(child: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center)))
                  else if (_weather != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(_weather!.cityName, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 20),
                              Icon(WeatherIcons.getWeatherIcon(_weather!.iconCode), size: 120, color: Colors.yellowAccent),
                              const SizedBox(height: 10),
                              Text('${_weather!.temperature.round()}°C', style: const TextStyle(fontSize: 90, fontWeight: FontWeight.w200, color: Colors.white)),
                              Text(_weather!.description.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white70, letterSpacing: 2)),
                              const SizedBox(height: 50),
                              Container(
                                padding: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStat(Icons.water_drop, '${_weather!.humidity}%', 'Humidity'),
                                    Container(width: 1, height: 40, color: Colors.white24),
                                    _buildStat(Icons.air, '${_weather!.windSpeed} m/s', 'Wind'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}