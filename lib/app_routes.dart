import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Splash
import 'ui/splash_screen/splash_view.dart';
import 'ui/splash_screen/splash_viewmodel.dart';

// Onboarding
import 'ui/onboarding_screen/onboarding_view.dart';
import 'ui/onboarding_screen/onboarding_viewmodel.dart';

// Sign Up
import 'ui/sign_up_screen/sign_up_view.dart';
import 'ui/sign_up_screen/sign_up_viewmodel.dart';

// Sign In
import 'ui/sign_in_screen/sign_in_view.dart';
import 'ui/sign_in_screen/sign_in_viewmodel.dart';

// Forgot Password
import 'ui/forgot_password_screen/forgot_password_view.dart';
import 'ui/forgot_password_screen/forgot_password_viewmodel.dart';

// Home Dashboard
import 'ui/home_dashboard/home_view.dart';
import 'ui/home_dashboard/home_viewmodel.dart';

// Crop Scan Result
import 'ui/crop_scan_result/crop_scan_result_view.dart';
import 'ui/crop_scan_result/crop_scan_result_viewmodel.dart';

// Voice Q&A
import 'ui/voice_qa/voice_qa_view.dart';
import 'ui/voice_qa/voice_qa_viewmodel.dart';

// Weather Advice
import 'ui/weather_advice/weather_advice_view.dart';
import 'ui/weather_advice/weather_advice_viewmodel.dart';

// Profile Settings
import 'ui/profile_settings/profile_settings_view.dart';
import 'ui/profile_settings/profile_settings_viewmodel.dart';

// Usage Status
import 'ui/usage_status/usage_status_view.dart';
import 'ui/usage_status/usage_status_viewmodel.dart';

// Go Pro
import 'ui/go_pro/go_pro_view.dart';
import 'ui/go_pro/go_pro_viewmodel.dart';

// Checkout / Payment
import 'ui/checkout_payment/checkout_payment_view.dart';
import 'ui/checkout_payment/checkout_payment_viewmodel.dart';

// Edit Profile
import 'ui/edit_profile/edit_profile_view.dart';
import 'ui/edit_profile/edit_profile_viewmodel.dart';

// Language Settings
import 'ui/language_settings/language_settings_view.dart';
import 'ui/language_settings/language_settings_viewmodel.dart';

// Notification Settings
import 'ui/notification_settings/notification_settings_view.dart';
import 'ui/notification_settings/notification_settings_viewmodel.dart';

// Plant ID & Care
import 'ui/plant_id_care/plant_id_care_view.dart';
import 'ui/plant_id_care/plant_id_care_viewmodel.dart';
import 'ui/plant_id_care/plant_id_result_view.dart';

/// Every route is wired the same way as the reference project: wrap
/// the View in a ChangeNotifierProvider that owns a fresh ViewModel.
/// Screens that share state across a flow would use
/// ChangeNotifierProvider.value with a shared instance instead.
class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/splash': (context) => ChangeNotifierProvider(
          create: (_) => SplashViewModel(),
          child: const SplashScreenView(),
        ),
    '/onboarding': (context) => ChangeNotifierProvider(
          create: (_) => OnboardingViewModel(),
          child: const OnboardingScreenView(),
        ),
    '/sign-up': (context) => ChangeNotifierProvider(
          create: (_) => SignUpViewModel(),
          child: const SignUpScreenView(),
        ),
    '/sign-in': (context) => ChangeNotifierProvider(
          create: (_) => SignInViewModel(),
          child: const SignInScreenView(),
        ),
    '/forgot-password': (context) => ChangeNotifierProvider(
          create: (_) => ForgotPasswordViewModel(),
          child: const ForgotPasswordScreenView(),
        ),
    '/home': (context) => ChangeNotifierProvider(
          create: (_) => HomeViewModel(),
          child: const HomeScreenView(),
        ),
    '/crop-scan-result': (context) => ChangeNotifierProvider(
          create: (_) => CropScanResultViewModel(),
          child: const CropScanResultView(),
        ),
    '/voice-qa': (context) => ChangeNotifierProvider(
          create: (_) => VoiceQaViewModel(),
          child: const VoiceQaView(),
        ),
    '/weather-advice': (context) => ChangeNotifierProvider(
          create: (_) => WeatherAdviceViewModel(),
          child: const WeatherAdviceView(),
        ),
    '/profile-settings': (context) => ChangeNotifierProvider(
          create: (_) => ProfileSettingsViewModel(),
          child: const ProfileSettingsView(),
        ),
    '/usage-status': (context) => ChangeNotifierProvider(
          create: (_) => UsageStatusViewModel(),
          child: const UsageStatusView(),
        ),
    '/go-pro': (context) => ChangeNotifierProvider(
          create: (_) => GoProViewModel(),
          child: const GoProView(),
        ),
    '/checkout-payment': (context) => ChangeNotifierProvider(
          create: (_) => CheckoutPaymentViewModel(),
          child: const CheckoutPaymentView(),
        ),
    '/edit-profile': (context) => ChangeNotifierProvider(
          create: (_) => EditProfileViewModel(),
          child: const EditProfileView(),
        ),
    '/language-settings': (context) => ChangeNotifierProvider(
          create: (_) => LanguageSettingsViewModel(),
          child: const LanguageSettingsView(),
        ),
    '/notification-settings': (context) => ChangeNotifierProvider(
          create: (_) => NotificationSettingsViewModel(),
          child: const NotificationSettingsView(),
        ),
    '/plant-id-care': (context) => ChangeNotifierProvider(
          create: (_) => PlantIdCareViewModel(),
          child: const PlantIdCareView(),
        ),
    '/plant-id-result': (context) => const PlantIdResultView(),
  };
}
