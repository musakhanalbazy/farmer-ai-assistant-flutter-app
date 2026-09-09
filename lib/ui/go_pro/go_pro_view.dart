import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/subscription_plan_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_typography.dart';
import '../checkout_payment/checkout_payment_view.dart';
import '../checkout_payment/checkout_payment_viewmodel.dart';
import 'go_pro_viewmodel.dart';

/// VIEW
/// The "Go Pro" paywall modal — plan picker + feature comparison table
/// + trial CTA. Presented as a full screen (pushed, not a dialog) so
/// it can be reached from any upsell entry point in the app.
class GoProView extends StatelessWidget {
  const GoProView({super.key});

  void _handleEnterPaymentDetails(BuildContext context) {
    final vm = context.read<GoProViewModel>();
    final selected = vm.plans.firstWhere((p) => p.id == vm.selectedPlanId, orElse: () => vm.plans.first);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CheckoutPaymentViewModel()
            ..setPlan(SubscriptionPlanModel(
              id: selected.id,
              label: '${selected.label} Plan',
              priceLabel: selected.priceLabel,
              badge: selected.badge,
            )),
          child: const CheckoutPaymentView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoProViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.close, color: Colors.white, size: 18)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.45), blurRadius: 28, spreadRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.workspace_premium, color: AppColors.primaryDark, size: 30),
                      ),
                      const SizedBox(height: 16),
                      Text('Go Pro', style: AppTypography.displayLg(color: Colors.white).copyWith(fontSize: 32)),
                      const SizedBox(height: 6),
                      const Text('Unlimited AI for your farm', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 24),
                      if (vm.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.accentGold),
                          ),
                        )
                      else
                        ...vm.plans.map((plan) {
                          final selected = plan.id == vm.selectedPlanId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: InkWell(
                              onTap: () => context.read<GoProViewModel>().selectPlan(plan.id),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(24),
                                  border: selected ? Border.all(color: AppColors.accentGold, width: 2) : null,
                                  boxShadow: selected
                                      ? [BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 1)]
                                      : null,
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                          color: selected ? AppColors.accentGold : Colors.white70,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(plan.label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: selected ? AppColors.primaryDark : Colors.white)),
                                              Text(plan.priceLabel, style: TextStyle(color: selected ? AppColors.textMuted : Colors.white70)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (plan.badge != null && plan.badge!.isNotEmpty)
                                      Positioned(
                                        top: -24,
                                        right: -4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(12)),
                                          child: Text(plan.badge!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            const Text('PLAN FEATURES', style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
                            const SizedBox(height: 14),
                            _FeatureRow(label: 'Daily AI Scans', freeValue: '3', proValue: 'Unltd'),
                            const Divider(color: Colors.white24, height: 24),
                            _FeatureRow(label: 'Detailed Reports', freeValue: null, proValue: null, freeCheck: false, proCheck: true),
                            const Divider(color: Colors.white24, height: 24),
                            _FeatureRow(label: 'Ad-free Experience', freeValue: null, proValue: null, freeCheck: false, proCheck: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleEnterPaymentDetails(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryDark,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Continue to Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.white54),
                  SizedBox(width: 6),
                  Text('Secure payment', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final String? freeValue;
  final String? proValue;
  final bool? freeCheck;
  final bool? proCheck;

  const _FeatureRow({
    required this.label,
    this.freeValue,
    this.proValue,
    this.freeCheck,
    this.proCheck,
  });

  Widget _cell(String? value, bool? check, {required bool isPro}) {
    if (value != null) {
      return Text(value, style: TextStyle(color: isPro ? AppColors.accentGold : Colors.white70, fontWeight: isPro ? FontWeight.bold : FontWeight.normal));
    }
    return Icon(
      check == true ? Icons.check : Icons.close,
      size: 16,
      color: check == true ? AppColors.accentGold : Colors.white38,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(color: Colors.white))),
        Expanded(child: Center(child: _cell(freeValue, freeCheck, isPro: false))),
        Expanded(child: Center(child: _cell(proValue, proCheck, isPro: true))),
      ],
    );
  }
}
