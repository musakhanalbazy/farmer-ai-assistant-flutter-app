import 'dart:convert';
import 'package:http/http.dart' as http;

/// SERVICE
/// Automatically detects user's location (City, Region/Country) using IP geolocation.
class LocationService {
  static String? _cachedLocation;

  /// Returns "City, Region" (e.g. "Lahore, Punjab") or fallback if unavailable.
  static Future<String> detectLocation({String fallback = 'Punjab'}) async {
    if (_cachedLocation != null && _cachedLocation!.isNotEmpty) {
      return _cachedLocation!;
    }

    try {
      final uri = Uri.parse('http://ip-api.com/json/?fields=status,city,regionName,country');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['status'] == 'success') {
          final city = data['city']?.toString() ?? '';
          final region = data['regionName']?.toString() ?? data['country']?.toString() ?? '';

          if (city.isNotEmpty && region.isNotEmpty) {
            _cachedLocation = '$city, $region';
          } else if (city.isNotEmpty) {
            _cachedLocation = city;
          } else if (region.isNotEmpty) {
            _cachedLocation = region;
          }
          if (_cachedLocation != null && _cachedLocation!.isNotEmpty) {
            return _cachedLocation!;
          }
        }
      }
    } catch (_) {
      // Ignore network timeout / offline error and return fallback
    }

    return fallback;
  }
}
