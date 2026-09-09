/// MODEL
/// One actionable insight card on the Weather Advice screen
/// (irrigation timing, pest risk, harvesting window, etc).
class WeatherInsightModel {
  final String title;
  final String description;
  final String severity; // 'normal' | 'warning' | 'info'

  const WeatherInsightModel({
    required this.title,
    required this.description,
    this.severity = 'normal',
  });
}

/// Current field conditions shown at the top of the Weather Advice screen
/// and on the Home dashboard weather badge.
class FieldConditionsModel {
  final double tempFahrenheit;
  final double? tempCelsiusOverride;
  final String locationLabel;
  final int humidityPercent;
  final double windMph;
  final String windDirection;
  final String conditionDescription;

  const FieldConditionsModel({
    required this.tempFahrenheit,
    this.tempCelsiusOverride,
    required this.locationLabel,
    required this.humidityPercent,
    required this.windMph,
    required this.windDirection,
    this.conditionDescription = '',
  });

  /// Temperature in Celsius (either directly provided or converted from Fahrenheit)
  int get tempCelsius {
    if (tempCelsiusOverride != null) {
      return tempCelsiusOverride!.round();
    }
    if (tempFahrenheit > 0) {
      // If temp is above 60, it's likely in Fahrenheit, convert to Celsius
      if (tempFahrenheit > 50) {
        return ((tempFahrenheit - 32) * 5 / 9).round();
      }
      return tempFahrenheit.round();
    }
    return 28; // Standard default fallback
  }

  String get conditionText {
    if (conditionDescription.trim().isNotEmpty) {
      return conditionDescription.trim();
    }
    return 'Sunny';
  }

  factory FieldConditionsModel.fromJson(Map<String, dynamic> json) {
    final payload = json['conditions'] is Map
        ? Map<String, dynamic>.from(json['conditions'] as Map)
        : json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    final tempC = payload['temp_celsius'] ?? payload['tempCelsius'] ?? payload['temp_c'];
    final temp = payload['temp_fahrenheit'] ??
        payload['tempFahrenheit'] ??
        payload['temp_f'] ??
        payload['temp'] ??
        payload['temperature'] ??
        0;
    final humidity =
        payload['humidity_percent'] ?? payload['humidityPercent'] ?? 0;
    final wind = payload['wind_mph'] ?? payload['windMph'] ?? 0;

    return FieldConditionsModel(
      tempFahrenheit: (temp is num)
          ? temp.toDouble()
          : double.tryParse(temp.toString()) ?? 0,
      tempCelsiusOverride: (tempC is num)
          ? tempC.toDouble()
          : (tempC != null ? double.tryParse(tempC.toString()) : null),
      locationLabel: (payload['location_label'] ??
                  payload['locationLabel'] ??
                  payload['location'] ??
                  'Punjab')
              .toString(),
      humidityPercent: (humidity is num)
          ? humidity.toInt()
          : int.tryParse(humidity.toString()) ?? 0,
      windMph: (wind is num)
          ? wind.toDouble()
          : double.tryParse(wind.toString()) ?? 0,
      windDirection: (payload['wind_direction'] ??
                  payload['windDirection'] ??
                  'N')
              .toString(),
      conditionDescription:
          (payload['condition_description'] ??
                  payload['conditionDescription'] ??
                  payload['condition'] ??
                  payload['weather'] ??
                  '')
              .toString(),
    );
  }
}
