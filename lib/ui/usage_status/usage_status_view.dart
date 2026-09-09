import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_typography.dart';
import '../shared/custom_bottom_nav.dart';
import 'usage_status_viewmodel.dart';

/// VIEW
/// "Your Usage" screen: per-feature usage bars against the current
/// plan's limits, plus an upsell card into the Go Pro screen.
class UsageStatusView extends StatelessWidget {
  const UsageStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsageStatusViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text('Your Usage', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.notifications_none, color: AppColors.primaryDark), SizedBox(width: 16)],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : vm.usage == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load usage status', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => vm.refresh(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primaryDark,
                  onRefresh: () => vm.refresh(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('CURRENT BILLING CYCLE', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                                Text(vm.usage!.planName, style: AppTypography.headlineMd().copyWith(fontSize: 22)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)),
                            child: Text('Resets in ${vm.usage!.daysUntilReset} days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _UsageCard(
                        icon: Icons.document_scanner_outlined,
                        title: 'Crop Scans',
                        used: vm.usage!.cropScansUsed,
                        limit: vm.usage!.cropScansLimit,
                        progressColor: AppColors.primaryDark,
                        footnote: '${(vm.usage!.cropScansLimit - vm.usage!.cropScansUsed).clamp(0, vm.usage!.cropScansLimit)} scans remaining',
                      ),
                      const SizedBox(height: 14),
                      _UsageCard(
                        icon: Icons.mic_none,
                        title: 'Voice Queries',
                        used: vm.usage!.voiceQueriesUsed,
                        limit: vm.usage!.voiceQueriesLimit,
                        progressColor: AppColors.accentGold,
                        footnote: vm.usage!.voiceQueriesUsed >= vm.usage!.voiceQueriesLimit
                            ? 'Limit reached'
                            : '${(vm.usage!.voiceQueriesLimit - vm.usage!.voiceQueriesUsed).clamp(0, vm.usage!.voiceQueriesLimit)} queries remaining',
                        footnoteColor: vm.usage!.voiceQueriesUsed >= vm.usage!.voiceQueriesLimit ? AppColors.warning : null,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                              color: AppColors.cardWhite,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                              boxShadow: AppTheme.cardShadow,
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.primaryDark),
                                    SizedBox(width: 8),
                                    Text('Weather Advice', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    vm.usage!.weatherAdviceUnlimited ? 'UNLIMITED' : 'LIMITED',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enjoy unrestricted access to hyper-local forecasting and climate AI insights for your fields.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primaryDark, Color(0xFF16432A)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.floatingShadow,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: const Icon(Icons.workspace_premium_outlined, color: AppColors.accentGold, size: 32),
                            ),
                            const SizedBox(height: 12),
                            Text('Unlock Unlimited Potential', textAlign: TextAlign.center, style: AppTypography.headlineMd(color: Colors.white).copyWith(fontSize: 20)),
                            const SizedBox(height: 8),
                            const Text(
                              'Never worry about limits again. Get unlimited scans, advanced voice AI analysis, and multi-field tracking.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/go-pro'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGold,
                                  foregroundColor: AppColors.primaryDark,
                                  shape: const StadiumBorder(),
                          minimumSize: const Size.fromHeight(56),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Go Pro Today', style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int used;
  final int limit;
  final Color progressColor;
  final String footnote;
  final Color? footnoteColor;

  const _UsageCard({
    required this.icon,
    required this.title,
    required this.used,
    required this.limit,
    required this.progressColor,
    required this.footnote,
    this.footnoteColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        boxShadow: AppTheme.cardShadow,
                      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('$used / $limit', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.accent2,
              color: progressColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(footnote, style: TextStyle(fontSize: 12, color: footnoteColor ?? AppColors.textMuted)),
        ],
      ),
    );
  }
}
