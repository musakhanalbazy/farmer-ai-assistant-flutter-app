import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../model/otp_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns the 6-digit OTP state, the resend countdown timer, and the
/// verify() action. The View's individual digit boxes just call
/// updateDigit() and read digits back for display.
class ForgotPasswordViewModel extends ChangeNotifier {
  final Repository _repository = Repository();
  late OtpModel _model;
  Timer? _timer;

  bool isVerifying = false;
  bool isSendingCode = false;
  bool resetCodeSent = false;
  String? errorMessage;

  ForgotPasswordViewModel({String email = 'farmer.john@agri-tech.com'}) {
    _model = OtpModel(email: email);
    _startCountdown();
  }

  String get email => _model.email;
  List<String> get digits => _model.digits;
  int get secondsRemaining => _model.secondsRemaining;
  bool get canResend => _model.secondsRemaining == 0;

  void _startCountdown() {
    _timer?.cancel();
    _model.secondsRemaining = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_model.secondsRemaining == 0) {
        timer.cancel();
      } else {
        _model.secondsRemaining -= 1;
      }
      notifyListeners();
    });
  }

  void updateEmail(String value) {
    _model.email = value;
    errorMessage = null;
    notifyListeners();
  }

  void updateDigit(int index, String value) {
    _model.digits[index] = value;
    notifyListeners();
  }

  void setResetCodeSent(bool value) {
    resetCodeSent = value;
    notifyListeners();
  }

  Future<bool> sendResetCode() async {
    final email = _model.email.trim();
    if (email.isEmpty) {
      errorMessage = 'Enter your email or phone.';
      notifyListeners();
      return false;
    }

    isSendingCode = true;
    errorMessage = null;
    notifyListeners();

    final success = await _repository.sendPasswordResetCode(email);

    isSendingCode = false;
    if (!success) {
      errorMessage = 'Could not send a reset code. Please try again.';
      resetCodeSent = false;
    } else {
      resetCodeSent = true;
      _startCountdown();
    }
    notifyListeners();
    return success;
  }

  Future<void> resendCode() async {
    if (!canResend) return;
    await sendResetCode();
  }

  Future<bool> verifyCode() async {
    if (!_model.isComplete) {
      errorMessage = 'Enter the full 6-digit code.';
      notifyListeners();
      return false;
    }

    isVerifying = true;
    errorMessage = null;
    notifyListeners();

    final success = await _repository.verifyResetCode(_model.email, _model.code);

    isVerifying = false;
    if (!success) {
      errorMessage = 'Incorrect code. Please try again.';
    }
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
