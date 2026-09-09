import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_typography.dart';
import '../shared/custom_bottom_nav.dart';
import 'profile_settings_viewmodel.dart';

/// VIEW
/// Settings screen: profile card, preferences, data & support links,
/// and logout. Pure StatelessWidget.
class ProfileSettingsView extends StatelessWidget {
  const ProfileSettingsView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<ProfileSettingsViewModel>().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
    }
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await Navigator.pushNamed(context, '/edit-profile');
    if (context.mounted) {
      await context.read<ProfileSettingsViewModel>().refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileSettingsViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const Padding(padding: EdgeInsets.only(left: 12), child: Icon(Icons.account_circle_outlined, color: AppColors.primaryDark)),
        title: const Text('Settings', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.notifications_none, color: AppColors.primaryDark), SizedBox(width: 16)],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _openEditProfile(context),
                        borderRadius: BorderRadius.circular(40),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.accent2,
                          backgroundImage: vm.profile?.photoPath != null && vm.profile!.photoPath!.isNotEmpty
                              ? (kIsWeb
                                  ? NetworkImage(vm.profile!.photoPath!)
                                  : FileImage(File(vm.profile!.photoPath!)))
                              : null,
                          child: (vm.profile?.photoPath == null || vm.profile!.photoPath!.isEmpty)
                              ? const Icon(Icons.person, size: 40, color: AppColors.primaryDark)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _openEditProfile(context),
                        child: Text(vm.profile!.fullName, style: AppTypography.headlineMd().copyWith(fontSize: 20)),
                      ),
                      Text(vm.profile!.email, style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/usage-status'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Plan: ', style: TextStyle(fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(10)),
                                child: Text(vm.profile!.planType, style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('PREFERENCES', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                _SettingsCard(children: [
                  _SettingsRow(
                    icon: Icons.language,
                    iconBg: const Color(0xFFCDEBC7),
                    title: 'Language',
                    trailingText: vm.profile!.language,
                    onTap: () => Navigator.pushNamed(context, '/language-settings'),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.notifications_none,
                    iconBg: const Color(0xFFCDEBC7),
                    title: 'Notifications',
                    onTap: () => Navigator.pushNamed(context, '/notification-settings'),
                  ),
                ]),
                const SizedBox(height: 20),
                const Text('DATA & SUPPORT', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                const SizedBox(height: 8),
                _SettingsCard(children: [
                  _SettingsRow(icon: Icons.history, iconBg: AppColors.accentGold.withValues(alpha: 0.3), title: 'Saved crop history', onTap: () {}),
                  const Divider(height: 1),
                  _SettingsRow(icon: Icons.help_outline, iconBg: const Color(0xFFCDEBC7), title: 'Help & Support', onTap: () {}),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: const Text('Log out', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.dangerBg,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(56),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        boxShadow: AppTheme.cardShadow,
                      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: iconBg, radius: 16, child: Icon(icon, size: 16, color: AppColors.primaryDark)),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText!, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
