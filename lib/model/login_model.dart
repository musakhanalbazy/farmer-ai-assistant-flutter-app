/// MODEL
/// Pure data for the "Welcome Back" sign-in screen.
class LoginModel {
  String emailOrPhone;
  String password;

  LoginModel({
    this.emailOrPhone = '',
    this.password = '',
  });

  Map<String, dynamic> toJson() => {
        'email_or_phone': emailOrPhone.trim(),
        'password': password,
      };
}
