import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_typography.dart';
import 'onboarding_viewmodel.dart';

/// VIEW
/// StatefulWidget only for the PageController (UI-lifecycle object).
/// Page content and the "which page am I on" state live in the ViewModel.
class OnboardingScreenView extends StatefulWidget {
  const OnboardingScreenView({super.key});

  @override
  State<OnboardingScreenView> createState() => _OnboardingScreenViewState();
}

class _OnboardingScreenViewState extends State<OnboardingScreenView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToAuth() => Navigator.pushReplacementNamed(context, '/sign-up');

  void _handleNext(OnboardingViewModel vm) {
    if (vm.isLastPage) {
      _goToAuth();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goToAuth,
                  child: const Text('Skip', style: TextStyle(color: AppColors.textMuted)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => context.read<OnboardingViewModel>().updatePage(i),
                  itemCount: vm.pages.length,
                  itemBuilder: (context, index) {
                    final page = vm.pages[index];
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    page.imageAsset,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        index == 0
                                            ? Icons.qr_code_scanner
                                            : index == 1
                                                ? Icons.mic
                                                : Icons.cloud_queue,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        page.badgeLabel,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineMd(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd(color: AppColors.textMuted),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  vm.pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: vm.currentPage == i ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: vm.currentPage == i ? AppColors.accentGold : AppColors.accent2,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleNext(vm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vm.isLastPage ? 'Get Started' : 'Next', style: AppTypography.labelMd(color: AppColors.onPrimary)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18, color: AppColors.onPrimary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
