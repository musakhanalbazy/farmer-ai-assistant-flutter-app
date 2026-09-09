import 'package:flutter/foundation.dart';
import '../../model/signup_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns the sign-up form fields, validation rules, and the
/// createAccount() action. Single source of truth for form validity.
class SignUpViewModel extends ChangeNotifier {
  final SignUpModel _model = SignUpModel();
  final Repository _repository = Repository();

  bool isLoading = false;
  String? errorMessage;

  String get fullName => _model.fullName;
  String get emailOrPhone => _model.emailOrPhone;
  bool get agreeToTerms => _model.agreeToTerms;

  void updateFullName(String value) {
    _model.fullName = value;
    notifyListeners();
  }

  void updateEmailOrPhone(String value) {
    _model.emailOrPhone = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _model.password = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _model.confirmPassword = value;
    notifyListeners();
  }

  void toggleAgreeToTerms(bool value) {
    _model.agreeToTerms = value;
    notifyListeners();
  }

  String? validateFullName(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Enter your full name' : null;
  }

  String? validateEmailOrPhone(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Enter your email or phone' : null;
  }

  String? validatePassword(String? value) {
    return (value == null || value.length < 6) ? 'Min 6 characters' : null;
  }

  String? validateConfirmPassword(String? value) {
    return (value != _model.password) ? 'Passwords do not match' : null;
  }

  Future<bool> createAccount() async {
    if (!_model.agreeToTerms) {
      errorMessage = 'Please agree to the Terms of Service and Privacy Policy.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await _repository.signUp(_model.toJson());

    isLoading = false;
    if (!success) {
      errorMessage = 'An account with this email or phone already exists.';
    }
    notifyListeners();
    return success;
  }
}
