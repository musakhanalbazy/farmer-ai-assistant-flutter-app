import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_typography.dart';
import 'language_settings_viewmodel.dart';

/// VIEW
/// "Select Language" screen: a list of large, tappable language
/// options. Selecting one saves it to the profile immediately.
class LanguageSettingsView extends StatelessWidget {
  const LanguageSettingsView({super.key});

  Future<void> _handleSelect(BuildContext context, String code) async {
    final vm = context.read<LanguageSettingsViewModel>();
    vm.selectLanguage(code);
    final success = await vm.saveLanguage();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Language updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LanguageSettingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text('Select Language', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  const Text(
                    'Choose your preferred language for the application. You can change this later in settings.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  ...LanguageSettingsViewModel.languages.map((lang) {
                    final selected = lang['code'] == vm.selectedLanguage;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: vm.isSaving ? null : () => _handleSelect(context, lang['code']!),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryDark.withOpacity(0.06) : AppColors.cardWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? AppColors.primaryDark : AppColors.surfaceContainerHighest,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lang['label']!,
                                style: AppTypography.bodyLg(color: AppColors.onSurface),
                              ),
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: selected ? AppColors.primaryDark : AppColors.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
