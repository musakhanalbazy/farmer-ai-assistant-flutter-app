import 'package:flutter/foundation.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Holds the list of supported languages and the farmer's current
/// selection, persisting the choice back onto their profile.
class LanguageSettingsViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  bool isLoading = true;
  bool isSaving = false;

  static const List<Map<String, String>> languages = [
    {'code': 'English', 'label': 'English'},
    {'code': 'Urdu', 'label': '\u0627\u064f\u0631\u062f\u0648 (Urdu)'},
    {'code': 'Punjabi', 'label': '\u0a2a\u0a70\u0a1c\u0a3e\u0a2c\u0a40 (Punjabi)'},
    {'code': 'Hindi', 'label': '\u0939\u093f\u0928\u094d\u0926\u0940 (Hindi)'},
    {'code': 'Spanish', 'label': 'Espa\u00f1ol (Spanish)'},
  ];

  String selectedLanguage = 'English';

  LanguageSettingsViewModel() {
    _load();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();
    final profile = await _repository.getProfile();
    selectedLanguage = profile.language;
    isLoading = false;
    notifyListeners();
  }

  void selectLanguage(String code) {
    if (code == selectedLanguage) return;
    selectedLanguage = code;
    notifyListeners();
  }

  Future<bool> saveLanguage() async {
    isSaving = true;
    notifyListeners();

    final success = await _repository.updateLanguage(selectedLanguage);

    final profile = await _repository.getProfile();
    profile.language = selectedLanguage;

    isSaving = false;
    notifyListeners();
    return success;
  }
}
