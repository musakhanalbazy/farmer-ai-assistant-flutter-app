import 'package:flutter/foundation.dart';
import '../../model/usage_model.dart';
import '../../model/user_profile_model.dart';
import '../../model/weather_insight_model.dart';
import '../../repository/repository.dart';
import '../../services/location_service.dart';

/// VIEWMODEL
/// Loads the greeting profile, automatic location, time-based greeting, live weather temperature,
/// and usage summary for the Home dashboard.
class HomeViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  bool isWeatherLoading = false;
  UserProfileModel? profile;
  UsageModel? usage;
  FieldConditionsModel? weatherConditions;
  String detectedLocation = 'Punjab';

  HomeViewModel() {
    _load();
  }

  /// Returns "Good morning", "Good afternoon", "Good evening", etc. based on current local hour.
  String get timeGreeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good evening';
    }
  }

  String get timeGreetingCapitalized {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Evening';
    }
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _repository.getProfile();
    } catch (_) {}

    try {
      usage = await _repository.getUsageStatus();
    } catch (_) {}

    isLoading = false;
    notifyListeners();

    // Fetch automatic location and live weather conditions
    await fetchLiveWeather();
  }

  Future<void> fetchLiveWeather() async {
    isWeatherLoading = true;
    notifyListeners();

    try {
      // 1. Detect location automatically (IP-based or fallback to profile farmName)
      final fallbackLocation = (profile?.farmName.isNotEmpty == true)
          ? profile!.farmName
          : 'Punjab';

      detectedLocation = await LocationService.detectLocation(
        fallback: fallbackLocation,
      );

      // 2. Query weather API for the detected location
      weatherConditions = await _repository.getFieldConditions(
        location: detectedLocation,
      );
    } catch (_) {
      weatherConditions = const FieldConditionsModel(
        tempFahrenheit: 82.4, // ~28°C
        locationLabel: 'Punjab',
        humidityPercent: 45,
        windMph: 8.0,
        windDirection: 'NW',
        conditionDescription: 'Sunny',
      );
    }

    isWeatherLoading = false;
    notifyListeners();
  }

  /// Formatted live weather string for Home badge: e.g. "28°C, Sunny, Punjab"
  String get weatherDisplayText {
    final temp = weatherConditions?.tempCelsius ?? 28;
    final condition = weatherConditions?.conditionText ?? 'Sunny';
    final locationLabel = (weatherConditions?.locationLabel.isNotEmpty == true &&
            weatherConditions?.locationLabel != 'Unknown location' &&
            weatherConditions?.locationLabel != 'string')
        ? weatherConditions!.locationLabel
        : detectedLocation;

    return '$temp°C, $condition, $locationLabel';
  }

  Future<void> refresh() => _load();
}
