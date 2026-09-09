import 'package:flutter/foundation.dart';
import '../../model/user_profile_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Loads the signed-in user's profile so the Edit Profile form can be
/// pre-filled, and exposes saveProfile() to persist edits.
class EditProfileViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  bool isSaving = false;
  UserProfileModel? profile;

  EditProfileViewModel() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    profile = await _repository.getProfile();
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile({
    required String fullName,
    required String email,
    required String farmName,
    String? photoPath,
  }) async {
    isSaving = true;
    notifyListeners();

    final updated = UserProfileModel(
      fullName: fullName,
      email: email,
      farmName: farmName,
      planType: profile?.planType ?? 'FREE',
      language: profile?.language ?? 'English',
      notificationsEnabled: profile?.notificationsEnabled ?? true,
      photoPath: photoPath ?? profile?.photoPath,
    );
    final success = await _repository.updateProfile(updated);
    if (success) profile = updated;

    isSaving = false;
    notifyListeners();
    return success;
  }

  Future<bool> uploadProfileImage(String photoPath) async {
    isSaving = true;
    notifyListeners();

    final success = await _repository.updateProfileImage(photoPath);
    if (success) {
      profile = await _repository.getProfile();
    }

    isSaving = false;
    notifyListeners();
    return success;
  }
}
