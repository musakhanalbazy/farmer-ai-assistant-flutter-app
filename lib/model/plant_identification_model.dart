/// MODEL
/// Represents the full response from POST /vision/identify-plant.
/// All fields are nullable so the UI can gracefully handle partial responses.
class PlantIdentificationModel {
  final String plantName;
  final String? commonName;
  final String? scientificName;
  final String? family;
  final String? confidence;
  final String? description;
  final String? difficulty;

  // Care summary
  final String? wateringFrequency;
  final String? wateringNote;
  final String? lightRequirement;
  final String? lightNote;

  // Care instructions
  final String? soil;
  final String? humidity;
  final String? temperature;
  final String? fertilizer;

  // Seasonal tips
  final String? springSummerTip;
  final String? fallWinterTip;

  // Extra info
  final String? toxicity;
  final String? nativeRegion;
  final List<String> tags;

  const PlantIdentificationModel({
    required this.plantName,
    this.commonName,
    this.scientificName,
    this.family,
    this.confidence,
    this.description,
    this.difficulty,
    this.wateringFrequency,
    this.wateringNote,
    this.lightRequirement,
    this.lightNote,
    this.soil,
    this.humidity,
    this.temperature,
    this.fertilizer,
    this.springSummerTip,
    this.fallWinterTip,
    this.toxicity,
    this.nativeRegion,
    this.tags = const [],
  });

  /// Parse the raw JSON map returned by the backend.
  /// Handles multiple possible nesting styles.
  factory PlantIdentificationModel.fromJson(Map<String, dynamic> json) {
    // Helper: resolve first non-empty string from candidate keys in a map.
    String? str(List<String> keys, [Map<String, dynamic>? source]) {
      final m = source ?? json;
      for (final k in keys) {
        final v = m[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return null;
    }

    // The response may be flat or wrapped under a nested key.
    final data = json['plant'] is Map
        ? Map<String, dynamic>.from(json['plant'] as Map)
        : json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json['result'] is Map
                ? Map<String, dynamic>.from(json['result'] as Map)
                : json;

    // Care instructions may live in a nested sub-object.
    final care = data['care'] is Map
        ? Map<String, dynamic>.from(data['care'] as Map)
        : data['care_instructions'] is Map
            ? Map<String, dynamic>.from(data['care_instructions'] as Map)
            : <String, dynamic>{};

    final seasonal = data['seasonal_tips'] is Map
        ? Map<String, dynamic>.from(data['seasonal_tips'] as Map)
        : data['seasons'] is Map
            ? Map<String, dynamic>.from(data['seasons'] as Map)
            : <String, dynamic>{};

    // Tags
    List<String> tags = [];
    final rawTags = data['tags'] ?? data['characteristics'] ?? data['traits'];
    if (rawTags is List) {
      tags = rawTags.map((e) => e.toString()).toList();
    }

    // Confidence: backend may return "0.93" → show "93%"
    String? confidence = str(['confidence', 'confidence_score', 'score'], data);
    if (confidence != null) {
      final num? n = double.tryParse(confidence);
      if (n != null && n <= 1) {
        confidence = '${(n * 100).toStringAsFixed(0)}%';
      } else if (n != null) {
        confidence = '${n.toStringAsFixed(0)}%';
      }
    }

    String? careStr(List<String> keys) {
      final v = str(keys, care);
      return v ?? str(keys, data);
    }

    String? seasonalStr(List<String> keys) {
      final v = str(keys, seasonal);
      return v ?? str(keys, data);
    }

    return PlantIdentificationModel(
      plantName: str(['plant_name', 'name', 'identified_plant', 'label'], data) ??
          'Unknown Plant',
      commonName: str(['common_name', 'common', 'popular_name'], data),
      scientificName: str(['scientific_name', 'latin_name', 'botanical_name'], data),
      family: str(['family', 'plant_family'], data),
      confidence: confidence,
      description: str(['description', 'about', 'info', 'overview'], data),
      difficulty: careStr(['difficulty', 'care_level', 'level']),
      wateringFrequency: careStr(['watering', 'water', 'watering_frequency']),
      wateringNote: careStr(['watering_note', 'water_note', 'watering_tip']),
      lightRequirement: careStr(['light', 'light_requirement', 'sunlight']),
      lightNote: careStr(['light_note', 'light_tip']),
      soil: careStr(['soil', 'soil_type', 'potting_mix']),
      humidity: careStr(['humidity', 'moisture']),
      temperature: careStr(['temperature', 'temp']),
      fertilizer: careStr(['fertilizer', 'fertilizing', 'feeding']),
      springSummerTip: seasonalStr(
          ['spring_summer', 'spring', 'warm_season', 'growing_season']),
      fallWinterTip: seasonalStr(
          ['fall_winter', 'fall', 'winter', 'cold_season', 'dormant']),
      toxicity: str(['toxicity', 'toxic', 'is_toxic'], data),
      nativeRegion: str(['native_region', 'origin', 'native_to'], data),
      tags: tags,
    );
  }
}
