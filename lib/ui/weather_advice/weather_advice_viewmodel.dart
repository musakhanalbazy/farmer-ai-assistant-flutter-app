import 'package:flutter/material.dart';
import '../../model/weather_insight_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Loads field conditions + AI insights for the selected crop.
/// Re-fetches insights whenever the selected crop changes.
class WeatherAdviceViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  final List<String> crops = const ['Wheat', 'Rice', 'Cotton', 'Corn'];
  String selectedCrop = 'Wheat';
  String locationInput = '';
  final TextEditingController locationController = TextEditingController();

  bool isLoading = false;
  FieldConditionsModel? conditions;
  List<WeatherInsightModel> insights = [];

  WeatherAdviceViewModel() {
    locationController.text = locationInput;
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getFieldConditions(
          location: locationController.text.trim(),
          cropType: selectedCrop,
        ),
        _repository.getWeatherInsights(selectedCrop),
      ]);

      conditions = results[0] as FieldConditionsModel;
      insights = results[1] as List<WeatherInsightModel>;

    } catch (_) {
      conditions = const FieldConditionsModel(
        tempFahrenheit: 0,
        locationLabel: 'string',
        humidityPercent: 0,
        windMph: 0,
        windDirection: 'string',
        conditionDescription: '',
      );
      insights = const [
        WeatherInsightModel(
          title: 'AI Advice',
          description:
              'No advice returned yet. Try another field or refresh the data.',
          severity: 'info',
        ),
      ];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> selectCrop(String crop) async {
    if (crop == selectedCrop) return;
    selectedCrop = crop;
    notifyListeners();
  }

  Future<void> refreshAdvice() async {
    final query = locationController.text.trim();
    if (query.isNotEmpty) {
      locationInput = query;
    }
    await _load();
  }

  Future<void> loadAdviceNow() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getWeatherAdvice(
        location: locationController.text.trim(),
        cropType: selectedCrop,
      );

      final rawAdvice = response['advice'] is List
          ? response['advice'] as List
          : response['recommendations'] is List
              ? response['recommendations'] as List
              : response['insights'] is List
                  ? response['insights'] as List
                  : const <dynamic>[];

      insights = rawAdvice.isNotEmpty
          ? rawAdvice.map((item) {
              if (item is Map) {
                final title = (item['title'] ?? item['label'] ?? 'Advice').toString();
                final description = (item['description'] ?? item['message'] ?? item['advice'] ?? item['text'] ?? '').toString();
                final severity = (item['severity'] ?? 'info').toString();
                return WeatherInsightModel(
                  title: title,
                  description: description,
                  severity: severity,
                );
              }

              return WeatherInsightModel(
                title: 'Advice',
                description: item.toString(),
                severity: 'info',
              );
            }).toList()
          : const [
              WeatherInsightModel(
                title: 'AI Advice',
                description: 'No advice returned yet. Try another field or refresh the data.',
                severity: 'info',
              ),
            ];
    } catch (_) {
      insights = const [
        WeatherInsightModel(
          title: 'AI Advice',
          description: 'No advice returned yet. Try another field or refresh the data.',
          severity: 'info',
        ),
      ];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchConditions() async {
    final query = locationController.text.trim();
    if (query.isNotEmpty) {
      locationInput = query;
    }
    await _load();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }
}
