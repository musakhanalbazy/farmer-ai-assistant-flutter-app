import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_typography.dart';
import 'sign_up_viewmodel.dart';

/// VIEW
/// StatefulWidget only for the form state key and text controllers.
/// Every value change is pushed to the ViewModel via onChanged.
class SignUpScreenView extends StatefulWidget {
  const SignUpScreenView({super.key});

  @override
  State<SignUpScreenView> createState() => _SignUpScreenViewState();
}

class _SignUpScreenViewState extends State<SignUpScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<SignUpViewModel>();
    final success = await vm.createAccount();
    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text('Farmer AI', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Join the Community', style: AppTypography.headlineMd()),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to get personalized field insights and AI assistance.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.apple),
                  label: const Text('Continue with Apple'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR CONTINUE WITH EMAIL', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  onChanged: vm.updateFullName,
                  decoration: _decoration('Full Name'),
                  validator: vm.validateFullName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  onChanged: vm.updateEmailOrPhone,
                  decoration: _decoration('Email or Phone'),
                  validator: vm.validateEmailOrPhone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: vm.updatePassword,
                  decoration: _decoration('Password').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: vm.validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  onChanged: vm.updateConfirmPassword,
                  decoration: _decoration('Confirm Password'),
                  validator: vm.validateConfirmPassword,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: vm.agreeToTerms,
                      activeColor: AppColors.primaryDark,
                      onChanged: (val) => vm.toggleAgreeToTerms(val ?? false),
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          children: [
                            TextSpan(text: 'Terms of Service', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(vm.errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: vm.isLoading ? null : () => _handleCreateAccount(context),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Create Account', style: AppTypography.labelMd(color: AppColors.onPrimary)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18, color: AppColors.onPrimary),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/sign-in'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(color: AppColors.textMuted),
                        children: [TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark))],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
