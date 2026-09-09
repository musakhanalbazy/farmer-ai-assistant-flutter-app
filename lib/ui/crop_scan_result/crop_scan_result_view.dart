import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../shared/custom_bottom_nav.dart';
import 'crop_scan_result_viewmodel.dart';
// import 'live_scan_view.dart';

/// VIEW
/// Shows AI analysis of a scanned crop-leaf photo: detected pathogen,
/// severity, treatment steps, and prevention tips. Kicks off analysis
/// on first frame if no result is loaded yet (mock "captured" photo).
class CropScanResultView extends StatefulWidget {
  const CropScanResultView({super.key});

  @override
  State<CropScanResultView> createState() => _CropScanResultViewState();
}

class _CropScanResultViewState extends State<CropScanResultView> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        // For web, XFile has getBytes(), for mobile use File().readAsBytes()
        final bytes = await pickedFile.readAsBytes();
        context.read<CropScanResultViewModel>().setSelectedImage(pickedFile.path, bytes);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to pick image. Please try again.')),
        );
      }
    }
  }

  void _showImageSourceMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveScanComingSoon() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_outlined, color: AppColors.accentGold, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feature Coming Soon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Live real-time crop scanning will be available in an upcoming update!',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return AppColors.danger;
      case 'moderate':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CropScanResultViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text('Scan Results', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        actions: const [Icon(Icons.more_vert, color: AppColors.primaryDark), SizedBox(width: 12)],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: SafeArea(
        child: vm.isAnalyzing
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : vm.selectedImagePath == null && vm.result == null
                // Empty state: no image selected, no result
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent2,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Crop Disease Detection',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Capture or select a crop photo to get AI-powered disease analysis',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _showImageSourceMenu,
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showLiveScanComingSoon();
                                // Next page for live image stream is commented out until feature release:
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => const LiveScanView()),
                                // );
                              },
                              icon: const Icon(Icons.videocam_outlined),
                              label: const Text('Live Scan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                              ),
                            ),
                          ),
                          if (vm.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              vm.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : vm.selectedImagePath != null && vm.result == null
                // Image selected but not analyzed yet: show image and analyze button
                ? ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: vm.selectedImageBytes != null
                            ? Image.memory(
                                vm.selectedImageBytes!,
                                height: 300,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 300,
                                width: double.infinity,
                                color: AppColors.accent2,
                                child: const Icon(Icons.image, size: 50, color: AppColors.primaryDark),
                              ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => vm.analyzeImage(),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Analyze Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<CropScanResultViewModel>().clearSelectedImage(),
                          icon: Icon(Icons.clear),
                          label: const Text('Choose Different Image'),
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  )
                : vm.result == null
                ? Center(child: Text(vm.errorMessage ?? 'Unable to analyze image.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: vm.selectedImageBytes != null
                            ? Image.memory(
                                vm.selectedImageBytes!,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 250,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF7BA86E), Color(0xFF3F6B3C)],
                                  ),
                                ),
                                child: const Icon(Icons.eco, color: Colors.white24, size: 90),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.accent2, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: AppColors.success, size: 16),
                            SizedBox(width: 6),
                            Text('Analysis Complete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('DETECTED PATHOGEN', style: TextStyle(fontSize: 11, color: AppColors.textMuted, letterSpacing: 0.5)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _severityColor(vm.result!.severity).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, size: 8, color: _severityColor(vm.result!.severity)),
                                      const SizedBox(width: 6),
                                      Text(vm.result!.severity, style: TextStyle(color: _severityColor(vm.result!.severity), fontWeight: FontWeight.w600, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(vm.result!.pathogenName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.success)),
                            const SizedBox(height: 10),
                            Text(vm.result!.description, style: const TextStyle(color: AppColors.textMuted, height: 1.4)),
                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Icon(Icons.healing, size: 18, color: AppColors.primaryDark),
                                SizedBox(width: 8),
                                Text('Treatment Steps', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              ],
                            ),
                            const Divider(height: 20),
                            ...vm.result!.treatmentSteps.map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Icon(Icons.play_arrow, size: 16, color: AppColors.accentGold),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(step, style: const TextStyle(height: 1.4))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryDark),
                                SizedBox(width: 8),
                                Text('Prevention Tips', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: vm.result!.preventionTips.map((tip) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                                    child: Text(tip, style: const TextStyle(fontSize: 12)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _showLiveScanComingSoon,
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Live Scan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(56),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<CropScanResultViewModel>().saveToHistory();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to history')),
                            );
                          },
                          icon: const Icon(Icons.bookmark_border),
                          label: const Text('Save to History'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: AppColors.primaryDark,
                            shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(56),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share with Agronomist'),
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
