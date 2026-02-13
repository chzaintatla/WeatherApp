import 'package:lab13/app/data/models/weather_model.dart';
import 'package:lab13/app/data/models/forecast_model.dart';
import 'package:lab13/app/data/provider/weather_api.dart';

class WeatherService {
  final _api = WeatherApi();

  Future<Weather?> getCurrentWeather(String cityName) async {
    return _api.getCurrentWeather(cityName);
  }

  Future<ForecastWeather?> getForecast(String cityName) async {
    return _api.getForecast(cityName);
  }
}
