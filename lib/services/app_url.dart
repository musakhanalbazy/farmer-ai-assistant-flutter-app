/// SERVICES
/// Every backend endpoint the app calls, in one place.
/// Point [baseUrl] at your real backend once it exists —
/// nothing in the Repository or ViewModels needs to change.
class AppUrls {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // --- Auth ---
  static const String login = '$baseUrl/auth/signin';
  static const String signup = '$baseUrl/auth/signup';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';

  // --- Crop scan ---
  static const String scanCrop = '$baseUrl/crop/scan';
  static const String analyzeCrop = '$baseUrl/vision/analyze-crop';

  // --- Plant identification ---
  static const String identifyPlant = '$baseUrl/vision/identify-plant';
  static const String objectDetectionVideoFeed = '$baseUrl/object-detection/video_feed';
  static const String objectDetections = '$baseUrl/object-detection/detections';

  // --- Voice Q&A ---
  static const String askQuestion = '$baseUrl/voice/ask';

  // --- Weather ---
  static const String weatherAdvice = '$baseUrl/weather/advice';
  static const String weatherCurrent = weatherAdvice;

  // --- Usage & billing ---
  static const String usageStatus = '$baseUrl/billing/usage';
  static const String billingPlans = '$baseUrl/billing/plans';
  static const String subscribe = '$baseUrl/billing/subscribe';

  // --- Profile ---
  static const String profile = '$baseUrl/profile';
  static const String profileImage = '$baseUrl/profile/image';
  static const String profileLanguage = '$baseUrl/profile/language';
  static const String profileNotifications = '$baseUrl/profile/notifications';
}
