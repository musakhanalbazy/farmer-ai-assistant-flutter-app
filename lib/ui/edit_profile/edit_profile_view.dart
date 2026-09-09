import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import 'edit_profile_viewmodel.dart';

/// VIEW
/// Avatar + Full Name / Email / Farm Name form for editing the
/// signed-in user's profile.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _controllersFilled = false;
  String? _selectedPhotoPath;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    String finalPath = picked.path;
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final saved = await File(picked.path).copy('${directory.path}/$fileName');
      finalPath = saved.path;
    }

    if (!mounted) return;
    setState(() {
      _selectedPhotoPath = finalPath;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _farmController.dispose();
    super.dispose();
  }

  void _fillControllersOnce(EditProfileViewModel vm) {
    if (_controllersFilled || vm.profile == null) return;
    _nameController.text = vm.profile!.fullName;
    _emailController.text = vm.profile!.email;
    _farmController.text = vm.profile!.farmName;
    _selectedPhotoPath ??= vm.profile!.photoPath;
    _controllersFilled = true;
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<EditProfileViewModel>();
    final success = await vm.saveProfile(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      farmName: _farmController.text.trim(),
      photoPath: _selectedPhotoPath,
    );
    if (!context.mounted) return;
    if (success && _selectedPhotoPath != null && _selectedPhotoPath!.isNotEmpty) {
      await vm.uploadProfileImage(_selectedPhotoPath!);
    }
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
    final vm = context.watch<EditProfileViewModel>();
    _fillControllersOnce(vm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryDark),
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: vm.isLoading || vm.profile == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accent2,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: _selectedPhotoPath != null && _selectedPhotoPath!.isNotEmpty
                                      ? ClipOval(
                                          child: kIsWeb
                                              ? Image.network(
                                                  _selectedPhotoPath!,
                                                  fit: BoxFit.cover,
                                                  width: 104,
                                                  height: 104,
                                                )
                                              : Image.file(
                                                  File(_selectedPhotoPath!),
                                                  fit: BoxFit.cover,
                                                  width: 104,
                                                  height: 104,
                                                ),
                                        )
                                      : const Icon(Icons.person, size: 48, color: AppColors.primaryDark),
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.edit, size: 16, color: AppColors.primaryDark),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Tap to change photo', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    textCapitalization: TextCapitalization.words,
                                    decoration: _decoration('Full Name'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _decoration('Email Address'),
                                    validator: (v) =>
                                        (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _farmController,
                                    textCapitalization: TextCapitalization.words,
                                    decoration: _decoration('Farm Name'),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: vm.isSaving ? null : () => _handleSave(context),
                        child: vm.isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                            : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
