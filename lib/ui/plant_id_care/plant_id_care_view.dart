import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../shared/custom_bottom_nav.dart';
import 'plant_id_care_viewmodel.dart';

/// VIEW
/// Plant ID & Care landing screen — lets the user snap or upload a photo.
/// As soon as an image is picked the app navigates directly to the result screen.
class PlantIdCareView extends StatefulWidget {
  const PlantIdCareView({super.key});

  @override
  State<PlantIdCareView> createState() => _PlantIdCareViewState();
}

class _PlantIdCareViewState extends State<PlantIdCareView> {
  /// Show a bottom-sheet so the user can choose camera vs. gallery.
  void _showImageSourceMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryDark,
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndNavigate(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryDark,
                  child: Icon(Icons.photo_library, color: Colors.white, size: 20),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickAndNavigate(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image then immediately push the result screen.
  Future<void> _pickAndNavigate(ImageSource source) async {
    final vm = context.read<PlantIdCareViewModel>();
    await vm.pickImage(source);
    if (!mounted) return;
    if (vm.selectedImageBytes != null) {
      Navigator.pushNamed(
        context,
        '/plant-id-result',
        arguments: {
          'imageBytes': vm.selectedImageBytes,
          'result': null, // Result will be fetched on the result screen
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlantIdCareViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text(
          'Plant ID & Care',
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.more_vert, color: AppColors.primaryDark),
          SizedBox(width: 12),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: SafeArea(
        child: vm.isIdentifying
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : _buildBody(vm),
      ),
    );
  }

  Widget _buildBody(PlantIdCareViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),

          // ── Static logo — never changes ───────────────────────────────
          const _StaticHeroLogo(),

          const SizedBox(height: 32),

          // ── Title & subtitle ─────────────────────────────────────────
          const Text(
            'Plant Identification',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Snap or upload a photo to identify any\nplant and receive personalized care\ninstructions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.55,
            ),
          ),

          if (vm.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              vm.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ],

          const SizedBox(height: 40),

          // ── Select Image button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showImageSourceMenu,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text(
                'Select Image',
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static logo hero — always shows the Farmer AI icon, never swapped.
// ─────────────────────────────────────────────────────────────────────────────
class _StaticHeroLogo extends StatelessWidget {
  const _StaticHeroLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent2,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}