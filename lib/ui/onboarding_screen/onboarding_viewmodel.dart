import 'package:flutter/foundation.dart';
import '../../model/onboarding_page_model.dart';

/// VIEWMODEL
/// Owns the onboarding page content and the current page index.
/// The View's PageController just mirrors [currentPage] back here.
class OnboardingViewModel extends ChangeNotifier {
  int currentPage = 0;

  final List<OnboardingPageModel> pages = const [
    OnboardingPageModel(
      badgeLabel: 'AI Scanning',
      title: 'Detect crop diseases instantly',
      description: 'Identify pests and diseases in seconds just by taking a photo.',
      imageAsset: 'assets/images/onboarding_scan.jpg',
    ),
    OnboardingPageModel(
      badgeLabel: 'Voice Assistant',
      title: 'Ask your farm questions out loud',
      description: 'Get instant, localized answers on watering, pests, and more.',
      imageAsset: 'assets/images/onboarding_voice.jpg',
    ),
    OnboardingPageModel(
      badgeLabel: 'Weather Insights',
      title: 'Plan around hyper-local weather',
      description: 'Irrigation, pest risk, and harvesting windows tailored to your field.',
      imageAsset: 'assets/images/onboarding_weather.png',
    ),
  ];

  bool get isLastPage => currentPage == pages.length - 1;

  void updatePage(int index) {
    currentPage = index;
    notifyListeners();
  }
}
