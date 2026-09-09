/// MODEL
/// The farmer's alert opt-ins, shown on the "Notification Preferences"
/// screen and grouped there into Field Intelligence / Environment /
/// Account Settings sections.
class NotificationPreferencesModel {
  bool cropScanResults;
  bool dailyFarmingTips;
  bool weatherAlerts;
  bool accountUpdates;

  NotificationPreferencesModel({
    this.cropScanResults = true,
    this.dailyFarmingTips = false,
    this.weatherAlerts = true,
    this.accountUpdates = true,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) => NotificationPreferencesModel(
        cropScanResults: json['cropScanResults'] as bool? ?? true,
        dailyFarmingTips: json['dailyFarmingTips'] as bool? ?? false,
        weatherAlerts: json['weatherAlerts'] as bool? ?? true,
        accountUpdates: json['accountUpdates'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'cropScanResults': cropScanResults,
        'dailyFarmingTips': dailyFarmingTips,
        'weatherAlerts': weatherAlerts,
        'accountUpdates': accountUpdates,
      };
}
