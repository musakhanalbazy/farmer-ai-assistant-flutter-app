import 'package:flutter/foundation.dart';
import '../../model/notification_preferences_model.dart';
import '../../model/user_profile_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Loads the farmer's alert opt-ins and persists each toggle change
/// back through the repository.
class NotificationSettingsViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  NotificationPreferencesModel prefs = NotificationPreferencesModel();
  UserProfileModel? profile;

  NotificationSettingsViewModel() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    final results = await Future.wait([
      _repository.getNotificationPreferences(),
      _repository.getProfile(),
    ]);
    prefs = results[0] as NotificationPreferencesModel;
    profile = results[1] as UserProfileModel;
    isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() => _repository.updateNotificationPreferences(prefs);

  void toggleCropScanResults(bool value) {
    prefs.cropScanResults = value;
    notifyListeners();
    _persist();
  }

  void toggleDailyFarmingTips(bool value) {
    prefs.dailyFarmingTips = value;
    notifyListeners();
    _persist();
  }

  void toggleWeatherAlerts(bool value) {
    prefs.weatherAlerts = value;
    notifyListeners();
    _persist();
  }

  void toggleAccountUpdates(bool value) {
    prefs.accountUpdates = value;
    notifyListeners();
    _persist();
  }
}
