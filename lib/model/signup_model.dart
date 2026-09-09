/// MODEL
/// Pure data for the "Join the Community" sign-up screen.
class SignUpModel {
  String fullName;
  String emailOrPhone;
  String password;
  String confirmPassword;
  bool agreeToTerms;

  SignUpModel({
    this.fullName = '',
    this.emailOrPhone = '',
    this.password = '',
    this.confirmPassword = '',
    this.agreeToTerms = false,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName.trim(),
        'email_or_phone': emailOrPhone.trim(),
        'password': password,
      };
}
