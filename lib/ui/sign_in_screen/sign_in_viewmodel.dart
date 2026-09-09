import 'package:flutter/foundation.dart';
import '../../model/login_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns email/password state, validation, and the login() action.
class SignInViewModel extends ChangeNotifier {
  final LoginModel _model = LoginModel();
  final Repository _repository = Repository();

  bool isLoading = false;
  String? errorMessage;

  void updateEmailOrPhone(String value) {
    _model.emailOrPhone = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    _model.password = value;
    notifyListeners();
  }

  String? validateEmailOrPhone(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Enter your email or phone' : null;
  }

  String? validatePassword(String? value) {
    return (value == null || value.isEmpty) ? 'Enter your password' : null;
  }

  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await _repository.login(_model.emailOrPhone, _model.password);

    isLoading = false;
    if (!success) {
      errorMessage = 'Invalid email/phone or password.';
    }
    notifyListeners();
    return success;
  }
}
