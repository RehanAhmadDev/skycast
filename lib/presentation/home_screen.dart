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
  String _errorMessage = '';

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
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final weather = await _weatherService.fetchWeatherByCity(cityName);
      setState(() { _weather = weather; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _fetchLocation() async {
    setState(() { _isLoading = true; _searchController.clear(); });
    try {
      final weather = await _weatherService.fetchWeatherByLocation();
      setState(() { _weather = weather; _isLoading = false; });
    } catch (e) {
      setState(() { _errorMessage = "Location Error"; _isLoading = false; });
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
      // Scrolling fix karne ke liye hum SingleChildScrollView ko top par laye hain
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?q=80&w=1000',
              fit: BoxFit.cover,
            ),
          ),
          // 2. Blur Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
          // 3. Main Content (Scrollable Area)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), // Premium iOS style scroll
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 40),

                  if (_isLoading && _weather == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (_weather != null)
                    _buildWeatherUI()
                  else if (_errorMessage.isNotEmpty)
                      Text(_errorMessage, style: const TextStyle(color: Colors.white)),

                  const SizedBox(height: 30), // Bottom padding for scroll
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter city name...",
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white70),
            onPressed: _fetchLocation,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildWeatherUI() {
    return Column(
      children: [
        Text(_weather!.cityName,
            style: GoogleFonts.poppins(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 30),
        Icon(WeatherIcons.getWeatherIcon(_weather!.iconCode), size: 100, color: Colors.white),
        Text("${_weather!.temperature.round()}°",
            style: GoogleFonts.poppins(fontSize: 100, fontWeight: FontWeight.w200, color: Colors.white)),
        Text(_weather!.description.toUpperCase(),
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.white, letterSpacing: 4)),
        const SizedBox(height: 40),
        _buildDetailsCard(),
        const SizedBox(height: 30),
        _buildForecastPlaceholder(), // Scrolling check karne ke liye extra section
      ],
    );
  }

  Widget _buildDetailsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(Icons.water_drop_outlined, "${_weather!.humidity}%", "Humidity"),
              _statItem(Icons.air, "${_weather!.windSpeed} m/s", "Wind"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14)),
      ],
    );
  }

  // Sirf scrolling check karne ke liye extra design
  Widget _buildForecastPlaceholder() {
    return Column(
      children: List.generate(5, (index) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Day ${index + 1}", style: const TextStyle(color: Colors.white)),
            const Icon(Icons.wb_sunny_outlined, color: Colors.white),
            const Text("28° / 20°", style: TextStyle(color: Colors.white)),
          ],
        ),
      )),
    );
  }
}