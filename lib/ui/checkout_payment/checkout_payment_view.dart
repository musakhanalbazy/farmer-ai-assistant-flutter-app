import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_typography.dart';
import 'checkout_payment_viewmodel.dart';

/// VIEW
/// Plan summary + card-entry form for upgrading to Pro. Reached from
/// the "Go Pro" paywall once a plan has been chosen.
class CheckoutPaymentView extends StatefulWidget {
  const CheckoutPaymentView({super.key});

  @override
  State<CheckoutPaymentView> createState() => _CheckoutPaymentViewState();
}

class _CheckoutPaymentViewState extends State<CheckoutPaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _handlePay(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<CheckoutPaymentViewModel>();
    final success = await vm.submitPayment(
      cardholderName: _nameController.text.trim(),
      cardNumber: _cardController.text.trim(),
    );
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful \u2014 welcome to Pro!')),
      );
      Navigator.pop(context);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  InputDecoration _decoration(String label, {Widget? suffixIcon}) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: AppColors.cardWhite,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.background),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.background),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CheckoutPaymentViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHigh,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Checkout', style: AppTypography.headlineLgMobile()),
                      const SizedBox(height: 6),
                      const Text(
                        'Complete your subscription upgrade.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                      ),
                      const SizedBox(height: 20),
                      // --- Plan summary card, with a soft gold "organic" flourish ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold.withOpacity(0.35),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDark,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(Icons.eco, color: AppColors.accentGold, size: 24),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(vm.plan.label, style: AppTypography.headlineMd().copyWith(fontSize: 20)),
                                            const Text('Precision analytics & AI', style: TextStyle(color: AppColors.textMuted)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    _PlanPrice(priceLabel: vm.plan.priceLabel),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // --- Payment details card ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.credit_card, color: AppColors.primaryDark, size: 20),
                                const SizedBox(width: 8),
                                Text('Payment Details', style: AppTypography.headlineMd().copyWith(fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _decoration('Cardholder Name'),
                              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _cardController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                              decoration: _decoration('Card Number', suffixIcon: const Icon(Icons.credit_card, color: AppColors.textMuted, size: 18)),
                              validator: (v) => (v == null || v.trim().length < 12) ? 'Enter a valid card number' : null,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [LengthLimitingTextInputFormatter(5)],
                                    decoration: _decoration('MM/YY'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    obscureText: true,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                                    decoration: _decoration('CVV', suffixIcon: const Icon(Icons.help_outline, color: AppColors.textMuted, size: 18)),
                                    validator: (v) => (v == null || v.trim().length < 3) ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(color: AppColors.background),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: vm.isProcessing ? null : () => _handlePay(context),
                  child: vm.isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Complete Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanPrice extends StatelessWidget {
  final String priceLabel;
  const _PlanPrice({required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    // priceLabel looks like "$9.99 / mo" — split so the amount can be
    // rendered large while the unit stays small, matching the design.
    final match = RegExp(r'^\$?([\d.,]+)\s*/?\s*(\w+)?').firstMatch(priceLabel);
    final amount = match?.group(1) ?? priceLabel;
    final unit = match?.group(2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('\$', style: AppTypography.headlineMd().copyWith(fontSize: 20)),
        Text(amount, style: AppTypography.displayLg().copyWith(fontSize: 36)),
        if (unit != null) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('/ $unit', style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ),
        ],
      ],
    );
  }
}
