import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ⬅️ Naya Import
import '../data/weather_service.dart';
import '../data/weather_model.dart';
import '../utils/weather_icons.dart';
import '../utils/weather_animations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  WeatherModel? _weather;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLastCity(); // ⬅️ App khulte hi last city load hogi
    _searchController.addListener(_onSearchChanged);
  }

  // 💾 Memory se last city nikalne ka logic
  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    // Agar koi city save nahi hai toh default 'Dera Ismail Khan' use hoga
    final lastCity = prefs.getString('saved_city') ?? 'Dera Ismail Khan';
    _fetchWeather(lastCity);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (_searchController.text.trim().length > 2) {
        _fetchWeather(_searchController.text.trim());
      }
    });
  }

  Future<void> _fetchWeather(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.fetchWeatherByCity(cityName);

      // 💾 Naya shehar search hone par usay memory mein Save karna
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_city', weather.cityName);

      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (_weather == null) _errorMessage = "City not found";
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=1000',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 30),

                  if (_isLoading && _weather == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (_weather != null)
                    _buildWeatherContent()
                  else if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(_errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search city...",
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      children: [
        Text(
          _weather!.cityName,
          style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(DateTime.now()),
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 220,
          child: Lottie.network(
            WeatherAnimations.getWeatherAnimation(_weather!.iconCode),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(WeatherIcons.getWeatherIcon(_weather!.iconCode), size: 100, color: Colors.white);
            },
          ),
        ),

        Text(
          "${_weather!.temperature.round()}°",
          style: GoogleFonts.poppins(fontSize: 100, fontWeight: FontWeight.w200, color: Colors.white),
        ),
        Text(
          _weather!.description.toUpperCase(),
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w300),
        ),

        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.water_drop_outlined, "${_weather!.humidity}%", "Humidity"),
              Container(width: 1, height: 40, color: Colors.white12),
              _buildStatItem(Icons.air_rounded, "${_weather!.windSpeed} km/h", "Wind"),
            ],
          ),
        ),

        const SizedBox(height: 40),
        _buildForecastList(),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 30),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildForecastList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            "7-Day Forecast",
            style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        ..._weather!.forecast.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                    DateFormat('EEEE').format(item.date),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)
                ),
              ),
              Icon(WeatherIcons.getWeatherIcon(item.iconCode), color: Colors.white70, size: 28),
              Text(
                  "${item.temp.round()}°",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}