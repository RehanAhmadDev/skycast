import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../data/weather_service.dart';
import '../data/weather_model.dart';
import '../utils/weather_icons.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchWeather('Dera Ismail Khan');
    _searchController.addListener(_onSearchChanged);
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
    setState(() { _isLoading = true; });
    try {
      final weather = await _weatherService.fetchWeatherByCity(cityName);
      setState(() { _weather = weather; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.network('https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=1000', fit: BoxFit.cover)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), child: Container(color: Colors.black.withOpacity(0.4)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  if (_isLoading && _weather == null)
                    const Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator(color: Colors.white))
                  else if (_weather != null)
                    _buildWeatherUI(),
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
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(25)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: "Search City...", hintStyle: TextStyle(color: Colors.white54), prefixIcon: Icon(Icons.search, color: Colors.white70), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
      ),
    );
  }

  Widget _buildWeatherUI() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(_weather!.cityName, style: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), style: GoogleFonts.poppins(color: Colors.white70)),
        Icon(WeatherIcons.getWeatherIcon(_weather!.iconCode), size: 100, color: Colors.white),
        Text("${_weather!.temperature.round()}°", style: GoogleFonts.poppins(fontSize: 100, fontWeight: FontWeight.w200, color: Colors.white)),
        const SizedBox(height: 20),
        _buildForecastList(), // Asli forecast data
      ],
    );
  }

  Widget _buildForecastList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Next Days", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ..._weather!.forecast.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('EEEE').format(item.date), style: const TextStyle(color: Colors.white, fontSize: 16)),
              Icon(WeatherIcons.getWeatherIcon(item.iconCode), color: Colors.white),
              Text("${item.temp.round()}°C", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ],
    );
  }
}