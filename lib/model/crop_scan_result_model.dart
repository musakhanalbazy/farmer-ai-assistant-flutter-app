/// MODEL
/// Pure data describing one AI crop-disease scan result.
class CropScanResultModel {
  final String pathogenName;
  final String severity;
  final String description;
  final List<String> treatmentSteps;
  final List<String> preventionTips;
  final String imagePath;

  const CropScanResultModel({
    required this.pathogenName,
    required this.severity,
    required this.description,
    required this.treatmentSteps,
    required this.preventionTips,
    required this.imagePath,
  });

  factory CropScanResultModel.fromJson(Map<String, dynamic> json) {
    final payload = json;
    final pathogenName = payload['pathogenName'] ?? payload['pathogen_name'] ?? payload['disease'] ?? 'Unknown Pathogen';
    final severity = payload['severity'] ?? 'Unknown';
    final description = payload['description'] ?? payload['analysis'] ?? payload['findings'] ?? '';
    final treatmentSteps = _parseList(payload['treatmentSteps'] ?? payload['treatment_steps'] ?? payload['treatments'] ?? []);
    final preventionTips = _parseList(payload['preventionTips'] ?? payload['prevention_tips'] ?? payload['prevention'] ?? []);

    return CropScanResultModel(
      pathogenName: pathogenName.toString(),
      severity: severity.toString(),
      description: description.toString(),
      treatmentSteps: treatmentSteps,
      preventionTips: preventionTips,
      imagePath: '',
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) {
      return value.map((item) => item is String ? item : item.toString()).toList();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }
}
