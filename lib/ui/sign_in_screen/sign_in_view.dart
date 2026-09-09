import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_typography.dart';
import '../../utils/app_theme.dart';
import 'sign_in_viewmodel.dart';

/// VIEW
/// "Welcome Back" login card. StatefulWidget only for form-lifecycle
/// objects; all state mutation flows through the ViewModel.
class SignInScreenView extends StatefulWidget {
  const SignInScreenView({super.key});

  @override
  State<SignInScreenView> createState() => _SignInScreenViewState();
}

class _SignInScreenViewState extends State<SignInScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<SignInViewModel>();
    final success = await vm.login();
    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignInViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to manage your fields and insights.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      onChanged: vm.updateEmailOrPhone,
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      validator: vm.validateEmailOrPhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: vm.updatePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: vm.validatePassword,
                    ),
                    if (vm.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(vm.errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('Forgot password?', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: vm.isLoading ? null : () => _handleSignIn(context),
                        child: vm.isLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                              )
                            : Text('Sign In', style: AppTypography.labelMd(color: AppColors.onPrimary)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/sign-up'),
                      child: const Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppColors.textMuted),
                          children: [TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
