// lib/presentation/home_screen.dart

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ⬅️ Riverpod Import
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../providers/weather_provider.dart'; // ⬅️ Provider Import
import '../utils/weather_icons.dart';
import '../utils/weather_animations.dart';
import '../utils/weather_backgrounds.dart';

// StatefulWidget ko ConsumerStatefulWidget mein badal diya
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (_searchController.text.trim().length > 2) {
        // ⬅️ Provider ke zariye fetchWeather call karna
        ref.read(weatherProvider.notifier).fetchWeather(_searchController.text.trim());
      }
    });
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
    // ⬅️ Provider se data sun-na (watch karna)
    final weatherState = ref.watch(weatherProvider);
    final weather = weatherState.weather;
    final isLoading = weatherState.isLoading;
    final errorMessage = weatherState.errorMessage;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: Image.network(
                WeatherBackgrounds.getBackgroundUrl(weather?.iconCode),
                key: ValueKey(weather?.iconCode),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(isLoading),
                  const SizedBox(height: 30),

                  if (isLoading && weather == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (weather != null)
                    _buildWeatherContent(weather)
                  else if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(errorMessage, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
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

  Widget _buildSearchBar(bool isLoading) {
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                ),
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                // ⬅️ Provider ke zariye GPS location call karna
                onPressed: () {
                  _searchController.clear();
                  ref.read(weatherProvider.notifier).fetchWeatherByLocation();
                },
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(weather) {
    return Column(
      children: [
        Text(weather.cityName, style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(DateFormat('EEEE, d MMMM').format(DateTime.now()), style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
        const SizedBox(height: 10),

        SizedBox(
          height: 220,
          child: Lottie.network(
            WeatherAnimations.getWeatherAnimation(weather.iconCode),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(WeatherIcons.getWeatherIcon(weather.iconCode), size: 100, color: Colors.white),
          ),
        ),

        Text("${weather.temperature.round()}°", style: GoogleFonts.poppins(fontSize: 100, fontWeight: FontWeight.w200, color: Colors.white)),
        Text(weather.description.toUpperCase(), style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w300)),

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
              _buildStatItem(Icons.water_drop_outlined, "${weather.humidity}%", "Humidity"),
              Container(width: 1, height: 40, color: Colors.white12),
              _buildStatItem(Icons.air_rounded, "${weather.windSpeed} km/h", "Wind"),
            ],
          ),
        ),

        const SizedBox(height: 40),
        _buildForecastList(weather),
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

  Widget _buildForecastList(weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text("7-Day Forecast", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        ...weather.forecast.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 100, child: Text(DateFormat('EEEE').format(item.date), style: GoogleFonts.poppins(color: Colors.white, fontSize: 16))),
              Icon(WeatherIcons.getWeatherIcon(item.iconCode), color: Colors.white70, size: 28),
              Text("${item.temp.round()}°", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        )).toList(),
      ],
    );
  }
}