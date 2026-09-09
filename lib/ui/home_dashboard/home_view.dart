import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_typography.dart';
import '../shared/custom_bottom_nav.dart';
import 'home_viewmodel.dart';

/// VIEW
/// The main dashboard matching the precision farmer UI:
/// - Top bar with profile avatar and notification bell with indicator
/// - Personalized greeting with weather status badge
/// - Asymmetric feature cards (Crop Disease Detection, Voice Q&A, Weather)
/// - Plant ID & Care card
/// - Recent Activity list
class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final fullName = vm.profile?.fullName.trim() ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : 'Partner';

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : RefreshIndicator(
                onRefresh: () => context.read<HomeViewModel>().refresh(),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // Top App Header
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFC8E6C9),
                          child: Icon(Icons.person, color: AppColors.primaryDark, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${vm.timeGreetingCapitalized}, ${fullName.isNotEmpty ? fullName : 'Partner'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primaryDark, size: 24),
                              onPressed: () => Navigator.pushNamed(context, '/notification-settings'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5573C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Greeting Headline
                    Text.rich(
                      TextSpan(
                        text: '${vm.timeGreeting}, $firstName ',
                        style: AppTypography.headlineMd().copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        children: const [
                          TextSpan(text: '👏'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Live Weather & Location Badge
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/weather-advice'),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFF2A32B)),
                              const SizedBox(width: 8),
                              Text(
                                vm.weatherDisplayText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                              const SizedBox(width: 6),
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Asymmetric Cards Grid
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left: Crop Disease Detection Card
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(context, '/crop-scan-result'),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B3B2B),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1B3B2B).withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      right: -12,
                                      bottom: 12,
                                      child: Opacity(
                                        opacity: 0.08,
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 88,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_outlined,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 38),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Crop Disease\nDetection',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                height: 1.25,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Snap a photo for\ninstant analysis',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.75),
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Right Column: Voice Q&A + Weather
                          Expanded(
                            child: Column(
                              children: [
                                // Voice Q&A Card
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pushNamed(context, '/voice-qa'),
                                    borderRadius: BorderRadius.circular(22),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDF0DC),
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: AppTheme.cardShadow,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF2A32B),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.mic,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Voice Q&A',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Ask naturally',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Weather Card
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pushNamed(context, '/weather-advice'),
                                    borderRadius: BorderRadius.circular(22),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardWhite,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                        ),
                                        boxShadow: AppTheme.cardShadow,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFECEFEA),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.wb_twilight_outlined,
                                              color: AppColors.primaryDark,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Weather',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Local tips',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Plant ID & Care Full-Width Card
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/plant-id-care'),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          ),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: Color(0xFFBFE7D4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_florist_outlined,
                                color: AppColors.primaryDark,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plant ID & Care',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Identify any plant and get\npersonalized care tips',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Activity Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'View all',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Activity Items
                    _ActivityCard(
                      thumbnail: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 22),
                      ),
                      title: 'Tomato Leaf Analysis',
                      statusDotColor: const Color(0xFF4CAF50),
                      statusText: 'Healthy',
                      timeText: '2 hours ago',
                      onTap: () => Navigator.pushNamed(context, '/crop-scan-result'),
                    ),
                    const SizedBox(height: 10),

                    _ActivityCard(
                      thumbnail: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE9C8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.pest_control_outlined, color: Color(0xFF8A5A00), size: 22),
                      ),
                      title: 'Pest Risk Query',
                      statusDotColor: const Color(0xFFF2A32B),
                      statusText: 'Answered',
                      timeText: 'Yesterday',
                      onTap: () => Navigator.pushNamed(context, '/voice-qa'),
                    ),
                    const SizedBox(height: 10),

                    _ActivityCard(
                      thumbnail: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.grass, color: Colors.white, size: 22),
                      ),
                      title: 'Wheat Field Scan',
                      statusDotColor: const Color(0xFFF2A32B),
                      statusText: 'Needs Water',
                      timeText: '3 days ago',
                      onTap: () => Navigator.pushNamed(context, '/crop-scan-result'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Widget thumbnail;
  final String title;
  final Color statusDotColor;
  final String statusText;
  final String timeText;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.thumbnail,
    required this.title,
    required this.statusDotColor,
    required this.statusText,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.25),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            thumbnail,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusDotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$statusText · $timeText',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
