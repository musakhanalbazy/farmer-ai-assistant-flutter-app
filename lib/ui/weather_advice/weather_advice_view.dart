import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/weather_insight_model.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../shared/custom_bottom_nav.dart';
import 'weather_advice_viewmodel.dart';

/// VIEW
/// Field conditions header + per-crop AI insight cards
/// (irrigation, pest risk, harvesting window).
class WeatherAdviceView extends StatelessWidget {
  const WeatherAdviceView({super.key});

  Color _severityBg(String severity) {
    switch (severity) {
      case 'warning':
        return AppColors.dangerBg;
      default:
        return AppColors.cardWhite;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'warning':
        return Icons.bug_report;
      case 'info':
        return Icons.schedule;
      default:
        return Icons.water_drop_outlined;
    }
  }

  Color _severityIconBg(String severity) {
    switch (severity) {
      case 'warning':
        return const Color(0xFFF4B5B2);
      case 'info':
        return AppColors.accentGold.withValues(alpha: 0.3);
      default:
        return AppColors.accent2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherAdviceViewModel>();
    final currentConditions =
        vm.conditions ??
        const FieldConditionsModel(
          tempFahrenheit: 0,
          locationLabel: 'string',
          humidityPercent: 0,
          windMph: 0,
          windDirection: 'string',
          conditionDescription: '',
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    context.read<WeatherAdviceViewModel>().refreshAdvice(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.accent2,
                          child: Icon(
                            Icons.person,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Good Morning, Partner',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.notifications_none,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: vm.locationController,
                      decoration: InputDecoration(
                        hintText: 'Enter field or location',
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primaryDark,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.primaryDark,
                          ),
                          onPressed: () => context
                              .read<WeatherAdviceViewModel>()
                              .searchConditions(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${currentConditions.tempFahrenheit.toStringAsFixed(0)}\u00b0F',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.wb_sunny,
                                color: AppColors.accentGold,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentConditions.locationLabel,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _StatBox(
                                  label: 'HUMIDITY',
                                  value:
                                      '${currentConditions.humidityPercent}%',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatBox(
                                  label: 'WIND',
                                  value:
                                      '${currentConditions.windMph.toStringAsFixed(2)} mph ${currentConditions.windDirection}',
                                ),
                              ),
                            ],
                          ),
                          if ((currentConditions.conditionDescription)
                              .trim()
                              .isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              currentConditions.conditionDescription,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SELECT CROP FOR ANALYSIS',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.crops.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final crop = vm.crops[index];
                          final selected = crop == vm.selectedCrop;
                          return ChoiceChip(
                            label: Text(crop),
                            selected: selected,
                            onSelected: (_) => context
                                .read<WeatherAdviceViewModel>()
                                .selectCrop(crop),
                            selectedColor: AppColors.primaryDark,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: AppColors.cardWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: AppColors.accent2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context
                            .read<WeatherAdviceViewModel>()
                            .loadAdviceNow(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGold,
                          foregroundColor: AppColors.primaryDark,
                          shape: const StadiumBorder(),
                          minimumSize: const Size.fromHeight(56),
                        ),
                        child: const Text(
                          'Get AI Advice',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...vm.insights.map(
                      (insight) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _severityBg(insight.severity),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: _severityIconBg(
                                  insight.severity,
                                ),
                                radius: 18,
                                child: Icon(
                                  _severityIcon(insight.severity),
                                  size: 16,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      insight.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: insight.severity == 'warning'
                                            ? AppColors.danger
                                            : AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      insight.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: insight.severity == 'warning'
                                            ? AppColors.danger
                                            : AppColors.textMuted,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
