import 'package:flutter/material.dart';
import '../../utils/app_color.dart';

/// SHARED WIDGET
/// The 5-tab bottom bar (Home / Scan / Voice / Weather / Profile)
/// matching the exact design with the prominent center Voice action.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  static const _items = [
    _NavItem('Home', Icons.home_outlined, Icons.home, '/home'),
    _NavItem('Scan', Icons.crop_free, Icons.crop_free, '/crop-scan-result'),
    _NavItem('Voice', Icons.mic, Icons.mic, '/voice-qa'),
    _NavItem('Weather', Icons.wb_sunny_outlined, Icons.wb_sunny, '/weather-advice'),
    _NavItem('Profile', Icons.person_outline, Icons.person, '/profile-settings'),
  ];

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    Navigator.pushReplacementNamed(context, _items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;

            // Center Voice Button
            if (index == 2) {
              return InkWell(
                onTap: () => _handleTap(context, index),
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B3B2B),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x331B3B2B),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          color: selected ? AppColors.primaryDark : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Selected Nav Item Pill
            if (selected) {
              return InkWell(
                onTap: () => _handleTap(context, index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE4C4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.selectedIcon,
                        size: 20,
                        color: const Color(0xFF8A5A00),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A5A00),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Unselected Nav Item
            return InkWell(
              onTap: () => _handleTap(context, index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _NavItem(this.label, this.icon, this.selectedIcon, this.route);
}
