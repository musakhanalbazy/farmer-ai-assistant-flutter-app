import 'package:flutter/foundation.dart';
import '../../model/crop_scan_result_model.dart';
import '../../repository/repository.dart';
import '../../services/app_url.dart';
import '../../services/user_storage_service.dart';

/// VIEWMODEL
/// Runs the AI crop-scan analysis for a captured/selected image and
/// exposes loading/result/error state for the View to render.
class CropScanResultViewModel extends ChangeNotifier {
  final Repository _repository = Repository();
  final UserStorageService _userStorage = UserStorageService();

  bool isAnalyzing = false;
  CropScanResultModel? result;
  String? errorMessage;
  bool savedToHistory = false;
  String? selectedImagePath;
  Uint8List? selectedImageBytes;
  String? liveScanUrl;
  String? liveScanToken;

  void setSelectedImage(String imagePath, [Uint8List? imageBytes]) {
    selectedImagePath = imagePath;
    selectedImageBytes = imageBytes;
    notifyListeners();
  }

  void clearSelectedImage() {
    selectedImagePath = null;
    selectedImageBytes = null;
    notifyListeners();
  }

  Future<void> analyzeImage() async {
    if (selectedImageBytes == null) {
      errorMessage = 'No image selected. Please select an image first.';
      notifyListeners();
      return;
    }

    isAnalyzing = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Generate a filename from the path or use a default name
      final fileName = selectedImagePath?.split('/').last ?? 'image.jpg';
      result = await _repository.analyzeCropImage(selectedImageBytes!, fileName);
    } catch (_) {
      errorMessage = 'Could not analyze this image. Please try again.';
    }

    isAnalyzing = false;
    notifyListeners();
  }

  Future<void> startLiveScan() async {
    try {
      liveScanToken = await _userStorage.getAuthToken();
      if (liveScanToken == null || liveScanToken!.isEmpty) {
        errorMessage = 'Login session expired. Please sign in again.';
        notifyListeners();
        return;
      }

      liveScanUrl = AppUrls.objectDetectionVideoFeed;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error starting live scan: ${e.toString()}';
    }
    notifyListeners();
  }

  void stopLiveScan() {
    liveScanUrl = null;
    liveScanToken = null;
    notifyListeners();
  }

  void saveToHistory() {
    savedToHistory = true;
    notifyListeners();
  }
}
