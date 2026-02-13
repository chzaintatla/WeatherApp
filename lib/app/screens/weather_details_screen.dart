import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab13/app/data/models/weather_model.dart';
import 'package:lab13/app/data/models/forecast_model.dart';
import 'package:lab13/app/data/service/weather_service.dart';

class WeatherDetailsScreen extends StatefulWidget {
  final String cityName;

  const WeatherDetailsScreen({super.key, required this.cityName});

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen>
    with SingleTickerProviderStateMixin {
  Weather? _currentWeather;
  ForecastWeather? _forecast;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isCelsius = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadWeatherData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final weatherService = WeatherService();

    try {
      final weather = await weatherService.getCurrentWeather(widget.cityName);
      final forecast = await weatherService.getForecast(widget.cityName);

      if (weather == null) {
        setState(() {
          _errorMessage = 'City not found. Please check the name and try again.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _currentWeather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String? iconCode) {
    if (iconCode == null) return '☁️';
    switch (iconCode) {
      case '01d':
      case '01n':
        return '☀️';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '☁️';
    }
  }

  List<Color> _getThemeColors() {
    if (_currentWeather?.weather?.first.icon == null) {
      return [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
    }
    String code = _currentWeather!.weather!.first.icon!;
    if (code.contains('01')) { // Clear sky
      return [const Color(0xFF2980B9), const Color(0xFF6DD5FA), const Color(0xFFFFFFFF)];
    } else if (code.contains('02') || code.contains('03') || code.contains('04')) { // Clouds
      return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
    } else if (code.contains('09') || code.contains('10')) { // Rain
      return [const Color(0xFF203A43), const Color(0xFF2C5364)];
    } else if (code.contains('11')) { // Thunderstorm
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    } else if (code.contains('13')) { // Snow
      return [const Color(0xFF83a4d4), const Color(0xFFb6fbff)];
    }
    return [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)];
  }

  double _convertTemp(double? temp) {
    if (temp == null) return 0;
    if (_isCelsius) return temp;
    return (temp * 9 / 5) + 32;
  }

  List<ForecastItem> _getDailyForecasts() {
    if (_forecast?.list == null) return [];
    
    Map<String, ForecastItem> dailyForecasts = {};
    
    for (var item in _forecast!.list!) {
      if (item.dtTxt != null) {
        String date = item.dtTxt!.split(' ')[0];
        if (!dailyForecasts.containsKey(date)) {
          dailyForecasts[date] = item;
        }
      }
    }
    
    return dailyForecasts.values.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getThemeColors(),
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _errorMessage != null
                  ? _buildErrorUI()
                  : RefreshIndicator(
                      onRefresh: _loadWeatherData,
                      color: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                _buildHeader(),
                                const SizedBox(height: 40),
                                _buildMainWeatherInfo(),
                                const SizedBox(height: 40),
                                _buildInfoCards(),
                                const SizedBox(height: 40),
                                _buildForecastSection(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            const Text(
              'SkyCast',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            Text(
              _currentWeather?.cityName?.toUpperCase() ?? widget.cityName.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Updated: ${DateFormat('HH:mm').format(DateTime.now())}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            _isCelsius ? Icons.thermostat : Icons.device_thermostat,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isCelsius = !_isCelsius;
            });
          },
        ),
        const Icon(Icons.menu, color: Colors.white, size: 24),
      ],
    );
  }

  Widget _buildMainWeatherInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'WEATHER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'FORECAST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_convertTemp(_currentWeather?.main?.temp).round()}°${_isCelsius ? 'C' : 'F'}',
              style: const TextStyle(
                fontSize: 86,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              _getWeatherIcon(_currentWeather?.weather?.first.icon),
              style: const TextStyle(fontSize: 80),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGlassCard(
                'Humidity:',
                '${_currentWeather?.main?.humidity ?? '--'}%',
                Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildGlassCard(
                'Wind Speed:',
                '${_currentWeather?.wind?.speed?.toStringAsFixed(1) ?? '--'} km/h',
                Icons.air_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildGlassCard(
                'Pressure:',
                '${_currentWeather?.main?.pressure ?? '--'} hPa',
                Icons.compress_rounded,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildGlassCard(
                'Feels Like:',
                '${_convertTemp(_currentWeather?.main?.feelsLike).round()}°',
                Icons.thermostat_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    final forecasts = _getDailyForecasts();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Mon',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Tue',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Wed',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Thu',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '5 Day',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: forecasts.map((f) => _buildForecastItem(f)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(ForecastItem forecast) {
    return Column(
      children: [
        Text(
          _getWeatherIcon(forecast.weather?.first.icon),
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '${_convertTemp(forecast.main?.temp).round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 64),
          const SizedBox(height: 24),
          Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
