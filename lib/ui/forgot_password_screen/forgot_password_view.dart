import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_typography.dart';
import 'forgot_password_viewmodel.dart';

/// VIEW
/// Reset-password OTP entry. StatefulWidget only for the 6
/// TextEditingControllers/FocusNodes driving auto-advance between boxes.
class ForgotPasswordScreenView extends StatefulWidget {
  const ForgotPasswordScreenView({super.key});

  @override
  State<ForgotPasswordScreenView> createState() => _ForgotPasswordScreenViewState();
}

class _ForgotPasswordScreenViewState extends State<ForgotPasswordScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _emailController.text = context.read<ForgotPasswordViewModel>().email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(BuildContext context, int index, String value) {
    context.read<ForgotPasswordViewModel>().updateDigit(index, value);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleSendCode(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<ForgotPasswordViewModel>();
    final success = await vm.sendResetCode();
    if (success && context.mounted) {
      // Keep the user on the same screen to enter the verification code.
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    }
  }

  Future<void> _handleVerify(BuildContext context) async {
    final vm = context.read<ForgotPasswordViewModel>();
    final success = await vm.verifyCode();
    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final minutes = (vm.secondsRemaining ~/ 60).toString();
    final seconds = (vm.secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accent2,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 24),
              Text('Reset Password', style: AppTypography.headlineMd()),
              const SizedBox(height: 8),
              const Text(
                "We've sent a 6-digit code to your registered device. Enter it below to secure your account.",
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              if (!vm.resetCodeSent) ...[
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: vm.updateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email or Phone',
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email or phone';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isSendingCode ? null : () => _handleSendCode(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: vm.isSendingCode
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Send Reset Code', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sent to', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          Text(vm.email, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => vm.setResetCodeSent(false),
                        child: const Text('Change', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 44,
                      height: 56,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardWhite,
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
                        ),
                        onChanged: (value) => _onDigitChanged(context, index, value),
                      ),
                    );
                  }),
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.danger))),
                ],
                const SizedBox(height: 16),
                Center(
                  child: vm.canResend
                      ? TextButton(
                          onPressed: () => context.read<ForgotPasswordViewModel>().resendCode(),
                          child: const Text('Resend code', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                        )
                      : Text(
                          "Didn't receive code? Resend in $minutes:$seconds",
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: vm.isVerifying ? null : () => _handleVerify(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: vm.isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
