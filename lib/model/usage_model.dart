/// MODEL
/// Current billing-cycle usage against the user's plan limits.
class UsageModel {
  final String planName;
  final int daysUntilReset;
  final int cropScansUsed;
  final int cropScansLimit;
  final int voiceQueriesUsed;
  final int voiceQueriesLimit;
  final bool weatherAdviceUnlimited;

  const UsageModel({
    required this.planName,
    required this.daysUntilReset,
    required this.cropScansUsed,
    required this.cropScansLimit,
    required this.voiceQueriesUsed,
    required this.voiceQueriesLimit,
    this.weatherAdviceUnlimited = true,
  });

  factory UsageModel.fromJson(Map<String, dynamic> rawJson) {
    final json = (rawJson['data'] is Map<String, dynamic>)
        ? rawJson['data'] as Map<String, dynamic>
        : (rawJson['usage'] is Map<String, dynamic>)
            ? rawJson['usage'] as Map<String, dynamic>
            : (rawJson['billing'] is Map<String, dynamic>)
                ? rawJson['billing'] as Map<String, dynamic>
                : rawJson;

    int parseInt(dynamic val, int defaultVal) {
      if (val == null) return defaultVal;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? defaultVal;
    }

    bool parseBool(dynamic val, bool defaultVal) {
      if (val == null) return defaultVal;
      if (val is bool) return val;
      if (val is String) {
        final lower = val.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
      }
      return defaultVal;
    }

    final planName = json['plan_name'] ??
        json['planName'] ??
        json['plan'] ??
        json['name'] ??
        json['plan_type'] ??
        json['planType'] ??
        'Free Plan';

    final daysUntilReset = parseInt(
      json['days_until_reset'] ??
          json['daysUntilReset'] ??
          json['days_left'] ??
          json['daysLeft'] ??
          json['reset_days'],
      12,
    );

    final cropScansUsed = parseInt(
      json['crop_scans_used'] ??
          json['cropScansUsed'] ??
          json['scans_used'] ??
          json['scansUsed'] ??
          json['crop_scans'] ??
          json['cropScans'],
      0,
    );

    final cropScansLimit = parseInt(
      json['crop_scans_limit'] ??
          json['cropScansLimit'] ??
          json['scans_limit'] ??
          json['scansLimit'] ??
          json['crop_limit'] ??
          json['cropLimit'],
      5,
    );

    final voiceQueriesUsed = parseInt(
      json['voice_queries_used'] ??
          json['voiceQueriesUsed'] ??
          json['voice_used'] ??
          json['voiceUsed'] ??
          json['queries_used'] ??
          json['queriesUsed'],
      0,
    );

    final voiceQueriesLimit = parseInt(
      json['voice_queries_limit'] ??
          json['voiceQueriesLimit'] ??
          json['voice_limit'] ??
          json['voiceLimit'] ??
          json['queries_limit'] ??
          json['queriesLimit'],
      10,
    );

    final weatherAdviceUnlimited = parseBool(
      json['weather_advice_unlimited'] ??
          json['weatherAdviceUnlimited'] ??
          json['weather_unlimited'] ??
          json['weatherUnlimited'],
      true,
    );

    return UsageModel(
      planName: planName.toString(),
      daysUntilReset: daysUntilReset,
      cropScansUsed: cropScansUsed,
      cropScansLimit: cropScansLimit,
      voiceQueriesUsed: voiceQueriesUsed,
      voiceQueriesLimit: voiceQueriesLimit,
      weatherAdviceUnlimited: weatherAdviceUnlimited,
    );
  }
}
