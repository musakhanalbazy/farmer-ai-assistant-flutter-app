/// MODEL
/// Pure data for the "Reset Password" OTP screen.
class OtpModel {
  String email;
  List<String> digits;
  int secondsRemaining;

  OtpModel({
    this.email = '',
    List<String>? digits,
    this.secondsRemaining = 45,
  }) : digits = digits ?? List.filled(6, '');

  String get code => digits.join();
  bool get isComplete => digits.every((d) => d.isNotEmpty);
}
