import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import 'splash_viewmodel.dart';

/// VIEW
/// Full-bleed hero background + animated logo card & text (slides up from bottom)
/// + Powered by AI footer. Stays visible for 3 seconds before navigating.
class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.8), // Start from bottom towards center
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _navigateNext());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    final vm = context.read<SplashViewModel>();
    await Future.delayed(const Duration(seconds: 3));
    final route = await vm.resolveStartRoute();
    if (mounted) Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Farmland hero background image
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Subtle dark overlay to ensure text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),

          // Centered Logo & Branding with bottom-to-middle animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Container Card
                    Container(
                      width: 136,
                      height: 136,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF5),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title: Farmer
                    Text(
                      'Farmer',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle: AI Assistant
                    Text(
                      'AI Assistant',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEDB148),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Footer: Powered by AI
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Powered by AI',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


