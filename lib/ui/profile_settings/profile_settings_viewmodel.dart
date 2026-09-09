import 'package:flutter/foundation.dart';
import '../../model/user_profile_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Loads and holds the signed-in user's profile + preferences,
/// and exposes the logout() action.
class ProfileSettingsViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  UserProfileModel? profile;

  ProfileSettingsViewModel() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    profile = await _repository.getProfile();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    isLoading = true;
    notifyListeners();
    profile = await _repository.getProfile();
    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() => _repository.logout();
}
