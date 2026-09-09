import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/plant_identification_model.dart';
import '../../repository/repository.dart';

/// ViewModel for Plant ID & Care screen.
/// Holds the selected image state and drives the identification flow.
class PlantIdCareViewModel extends ChangeNotifier {
  final _repository = Repository();

  String? selectedImagePath;
  Uint8List? selectedImageBytes;
  bool isIdentifying = false;
  String? errorMessage;
  PlantIdentificationModel? identificationResult;

  /// Pick image from gallery or camera.
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source);
      if (file == null) return;
      selectedImagePath = file.path;
      selectedImageBytes = await file.readAsBytes();
      // Reset any previous result when a new image is selected.
      identificationResult = null;
      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Unable to pick image. Please try again.';
      notifyListeners();
    }
  }

  /// Clear the selected image and result.
  void clearImage() {
    selectedImagePath = null;
    selectedImageBytes = null;
    identificationResult = null;
    errorMessage = null;
    notifyListeners();
  }

  /// Sends the selected image to POST /vision/identify-plant and
  /// navigates to the result screen with the API data.
  Future<void> identifyNow(BuildContext context) async {
    if (selectedImageBytes == null) {
      errorMessage = 'Please select an image first.';
      notifyListeners();
      return;
    }
    isIdentifying = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.identifyPlant(
      selectedImageBytes!.toList(),
      'plant_image.jpg',
    );

    identificationResult = result;
    isIdentifying = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushNamed(
        context,
        '/plant-id-result',
        arguments: {
          'imageBytes': selectedImageBytes,
          'result': result,
        },
      );
    }
  }
}