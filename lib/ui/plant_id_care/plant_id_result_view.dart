import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../model/plant_identification_model.dart';
import '../../repository/repository.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../shared/custom_bottom_nav.dart';

/// VIEW
/// Plant Identification Result screen.
/// Displays the selected plant photo, an "ID & Care" button that POSTs to
/// /vision/identify-plant, and renders the API response in well-organised,
/// beautiful cards.
class PlantIdResultView extends StatefulWidget {
  const PlantIdResultView({super.key});

  @override
  State<PlantIdResultView> createState() => _PlantIdResultViewState();
}

class _PlantIdResultViewState extends State<PlantIdResultView>
    with SingleTickerProviderStateMixin {
  final _repository = Repository();

  Uint8List? _imageBytes;
  PlantIdentificationModel? _result;
  bool _isLoading = false;
  String? _error;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      _imageBytes = args['imageBytes'] as Uint8List?;
      final result = args['result'];
      if (result is PlantIdentificationModel && _result == null) {
        _result = result;
        _fadeCtrl.forward();
      }
    } else if (args is Uint8List) {
      // Legacy: plain Uint8List argument
      _imageBytes = args;
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _repository.identifyPlant(
      _imageBytes!.toList(),
      'plant_image.jpg',
    );

    if (mounted) {
      setState(() {
        _result = result;
        _isLoading = false;
      });
      _fadeCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: BackButton(
          color: AppColors.primaryDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Results',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: const [
          Icon(Icons.more_vert, color: AppColors.primaryDark),
          SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Framed image with rounded corners ───────────────────
                Container(
                  width: double.infinity,
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: _imageBytes != null
                        ? Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(
                            color: AppColors.cardWhite,
                            child: const Icon(
                              Icons.eco,
                              color: AppColors.primaryDark,
                              size: 80,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action buttons (shown before analysis) ───────────────
                if (_result == null) ...[
                  _ActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'ID & Care',
                    filled: true,
                    onTap: _isLoading ? null : _analyzeImage,
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    icon: Icons.close,
                    label: 'Choose Different Image',
                    filled: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ],

                // ── Results section ──────────────────────────────────────
                if (_result != null) ...[
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: _ResultBody(result: _result!),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorCard(message: _error!),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Loading overlay ────────────────────────────────────────────
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: _LoadingIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// Loading indicator
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryDark),
          const SizedBox(height: 16),
          const Text(
            'Analyzing plant…',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This may take a few seconds',
            style: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.7),
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Action button (Analyze / Choose Different)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                shape: const StadiumBorder(),
              ),
            ),
    );
  }
}

// Full result body
class _ResultBody extends StatelessWidget {
  final PlantIdentificationModel result;
  const _ResultBody({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plant name & scientific name row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.plantName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (result.commonName != null)
                    Text(
                      result.commonName!,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textMuted),
                    ),
                  if (result.scientificName != null)
                    Text(
                      result.scientificName!,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
            if (result.confidence != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${result.confidence} match',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),

        // Family / region / toxicity chips
        if (result.family != null || result.nativeRegion != null || result.toxicity != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (result.family != null)
                _InfoChip(icon: Icons.category_outlined, label: result.family!),
              if (result.nativeRegion != null)
                _InfoChip(icon: Icons.public_outlined, label: result.nativeRegion!),
              if (result.toxicity != null)
                _InfoChip(
                    icon: Icons.warning_amber_rounded,
                    label: result.toxicity!,
                    color: const Color(0xFFF44336)),
            ],
          ),
        ],

        // Extra tags
        if (result.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: result.tags
                .map((t) => _InfoChip(icon: Icons.label_outline, label: t))
                .toList(),
          ),
        ],

        // Description / About
        if (result.description != null) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECF7EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.primaryDark),
                    SizedBox(width: 6),
                    Text('About',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.description!,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.55),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Care Summary
        if (result.wateringFrequency != null ||
            result.lightRequirement != null ||
            result.difficulty != null) ...[
          const _SectionTitle('Care Summary'),
          const SizedBox(height: 12),
          Row(
            children: [
              if (result.wateringFrequency != null)
                Expanded(
                  child: _CareSummaryCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFF2196F3),
                    label: 'Water',
                    value: result.wateringFrequency!,
                    note: result.wateringNote,
                  ),
                ),
              if (result.wateringFrequency != null &&
                  result.lightRequirement != null)
                const SizedBox(width: 12),
              if (result.lightRequirement != null)
                Expanded(
                  child: _CareSummaryCard(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFE9A84C),
                    label: 'Light',
                    value: result.lightRequirement!,
                    note: result.lightNote,
                  ),
                ),
            ],
          ),
          if (result.difficulty != null) ...[
            const SizedBox(height: 12),
            _CareSummaryCard(
              icon: Icons.eco_outlined,
              iconColor: AppColors.primaryDark,
              label: 'Difficulty',
              value: result.difficulty!,
              note: null,
              badge: _difficultyBadge(result.difficulty!),
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 28),
        ],

        // Care Instructions
        if (result.soil != null ||
            result.humidity != null ||
            result.temperature != null ||
            result.fertilizer != null) ...[
          const _SectionTitle('Care Instructions'),
          const SizedBox(height: 12),
          if (result.soil != null)
            _CareInstructionTile(
                icon: Icons.grass_outlined, title: 'Soil', body: result.soil!),
          if (result.humidity != null)
            _CareInstructionTile(
                icon: Icons.water_outlined,
                title: 'Humidity',
                body: result.humidity!),
          if (result.temperature != null)
            _CareInstructionTile(
                icon: Icons.thermostat_outlined,
                title: 'Temperature',
                body: result.temperature!),
          if (result.fertilizer != null)
            _CareInstructionTile(
                icon: Icons.science_outlined,
                title: 'Fertilizer',
                body: result.fertilizer!),
          const SizedBox(height: 28),
        ],

        // Seasonal Tips
        if (result.springSummerTip != null || result.fallWinterTip != null) ...[
          const _SectionTitle('Seasonal Tips'),
          const SizedBox(height: 12),
          if (result.springSummerTip != null)
            _SeasonalTip(
                icon: Icons.local_florist,
                season: 'Spring / Summer',
                body: result.springSummerTip!),
          if (result.fallWinterTip != null)
            _SeasonalTip(
                icon: Icons.ac_unit,
                season: 'Fall / Winter',
                body: result.fallWinterTip!),
          const SizedBox(height: 28),
        ],

        // Save to My Garden
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to My Garden!')),
              );
            },
            icon: const Icon(Icons.bookmark_border),
            label: const Text(
              'Save to My Garden',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Scan another plant
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text(
              'Scan Another Plant',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }

  String? _difficultyBadge(String difficulty) {
    final d = difficulty.toLowerCase();
    if (d.contains('easy') || d.contains('beginner')) return 'Beginner Friendly';
    if (d.contains('medium') || d.contains('moderate')) return 'Intermediate';
    if (d.contains('hard') || d.contains('expert') || d.contains('advanced')) {
      return 'Expert Level';
    }
    return null;
  }
}

// Error card
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFF44336)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFC62828), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Info chip (family, region, toxicity, tags)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primaryDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Section title
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
    );
  }
}

// Care summary card
class _CareSummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? note;
  final String? badge;
  final bool fullWidth;

  const _CareSummaryCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.note,
    this.badge,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: fullWidth
          ? Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE0F0E8),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark)),
                    if (badge != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F0E8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFFF3E0),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(height: 10),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark)),
                if (note != null)
                  Text(note!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
    );
  }
}

// Care instruction tile
class _CareInstructionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _CareInstructionTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFECEFEA),
            child: Icon(icon, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryDark)),
                const SizedBox(height: 4),
                Text(body,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Seasonal tip card
class _SeasonalTip extends StatelessWidget {
  final IconData icon;
  final String season;
  final String body;

  const _SeasonalTip({
    required this.icon,
    required this.season,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 18),
              const SizedBox(width: 8),
              Text(
                season,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
