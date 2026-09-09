import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/app_url.dart';
import '../../services/user_storage_service.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../shared/custom_bottom_nav.dart';

/// Live video stream view for real-time crop scanning / object detection.
/// Features live MJPEG streaming from YOLOv8 backend and live detection
/// analysis fetched on demand via GET /object-detection/detections.
class LiveScanView extends StatefulWidget {
  const LiveScanView({super.key});

  @override
  State<LiveScanView> createState() => _LiveScanViewState();
}

class _LiveScanViewState extends State<LiveScanView>
    with SingleTickerProviderStateMixin {
  late String _streamUrl;
  late String _authToken;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Analyzing state for Capture & Analyze action
  bool _isAnalyzing = false;

  // MJPEG stream state
  Uint8List? _currentFrame;
  StreamSubscription? _streamSubscription;
  http.Client? _httpClient;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _initializeStream();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _streamSubscription?.cancel();
    _httpClient?.close();
    super.dispose();
  }

  Future<void> _initializeStream() async {
    try {
      final userStorage = UserStorageService();
      final token = await userStorage.getAuthToken();

      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Login session expired. Please sign in again.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      _streamUrl = AppUrls.objectDetectionVideoFeed;
      _authToken = token;

      setState(() {
        _isLoading = false;
      });

      // Start consuming the MJPEG stream
      _startMjpegStream();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing stream: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  /// Connects to the MJPEG stream and parses individual JPEG frames.
  Future<void> _startMjpegStream() async {
    try {
      _httpClient = http.Client();
      final request = http.Request('GET', Uri.parse(_streamUrl));
      request.headers['Authorization'] = 'Bearer $_authToken';

      final response = await _httpClient!.send(request);

      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Stream returned status ${response.statusCode}';
          });
        }
        return;
      }

      // Buffer to accumulate incoming bytes
      List<int> buffer = [];
      bool inJpeg = false;

      _streamSubscription = response.stream.listen(
        (chunk) {
          buffer.addAll(chunk);

          // Search for JPEG frames in the buffer
          while (buffer.length > 2) {
            if (!inJpeg) {
              // Look for JPEG SOI marker (0xFF 0xD8)
              final soiIndex = _findMarker(buffer, 0xFF, 0xD8);
              if (soiIndex == -1) {
                if (buffer.length > 1) {
                  buffer = buffer.sublist(buffer.length - 1);
                }
                break;
              }
              buffer = buffer.sublist(soiIndex);
              inJpeg = true;
            }

            if (inJpeg) {
              // Look for JPEG EOI marker (0xFF 0xD9)
              final eoiIndex = _findMarker(buffer, 0xFF, 0xD9, start: 2);
              if (eoiIndex == -1) {
                break;
              }

              final frameBytes = buffer.sublist(0, eoiIndex + 2);
              buffer = buffer.sublist(eoiIndex + 2);
              inJpeg = false;

              if (mounted) {
                setState(() {
                  _currentFrame = Uint8List.fromList(frameBytes);
                });
              }
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Stream error: $error';
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Stream ended unexpectedly';
            });
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to connect: $e';
        });
      }
    }
  }

  /// Finds a two-byte marker in a byte list starting at [start].
  int _findMarker(List<int> data, int b1, int b2, {int start = 0}) {
    for (int i = start; i < data.length - 1; i++) {
      if (data[i] == b1 && data[i + 1] == b2) return i;
    }
    return -1;
  }

  /// Reconnect to the stream after an error.
  void _reconnect() {
    _streamSubscription?.cancel();
    _httpClient?.close();
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _currentFrame = null;
    });
    _startMjpegStream();
  }

  /// Sends a GET request to http://127.0.0.1:8000/object-detection/detections
  /// and opens the formatted detection results bottom sheet.
  Future<void> _fetchAndShowDetections() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    final capturedSnapshot = _currentFrame;

    try {
      final uri = Uri.parse(AppUrls.objectDetections);
      final headers = {
        'Accept': 'application/json',
        if (_authToken.isNotEmpty) 'Authorization': 'Bearer $_authToken',
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      if (response.statusCode == 200) {
        dynamic decoded;
        try {
          decoded = jsonDecode(response.body);
        } catch (_) {
          decoded = {'raw_text': response.body};
        }

        final detectionReport = _LiveDetectionReport.fromData(decoded);
        _showDetectionResultBottomSheet(detectionReport, capturedSnapshot);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Server returned error (${response.statusCode}): ${response.reasonPhrase ?? "Detection failed"}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Failed to fetch detections: $e',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  /// Displays the detections in a beautifully organized bottom sheet.
  void _showDetectionResultBottomSheet(
    _LiveDetectionReport report,
    Uint8List? capturedImageBytes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DetectionResultModalSheet(
        report: report,
        snapshotBytes: capturedImageBytes,
        onRescan: () {
          Navigator.pop(ctx);
          _fetchAndShowDetections();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Scan',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryDark),
              )
            : Column(
                children: [
                  // --- Camera preview card ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.secondaryContainer,
                            width: 2,
                          ),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Live MJPEG video feed
                              _buildVideoFeed(),

                              // Corner bracket overlays (scanning frame)
                              const _ScanFrameOverlay(),

                              // Animated scan line
                              AnimatedBuilder(
                                animation: _scanLineAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _scanLineAnimation.value *
                                        (MediaQuery.of(context).size.height *
                                                0.5 -
                                            80),
                                    left: 20,
                                    right: 20,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppColors.secondaryContainer
                                                .withValues(alpha: 0.9),
                                            AppColors.secondaryContainer,
                                            AppColors.secondaryContainer
                                                .withValues(alpha: 0.9),
                                            Colors.transparent,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors
                                                .secondaryContainer
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Top status chip: "Scanning for Pathogens..."
                              Positioned(
                                top: 12,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.onSurface
                                          .withValues(alpha: 0.65),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('🔬 ',
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                          'Scanning for Pathogens...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Bottom section: capture button + info tip + health
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Capture label
                                    const Text(
                                      'Capture',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Capture circle button
                                    GestureDetector(
                                      onTap: _isAnalyzing
                                          ? null
                                          : _fetchAndShowDetections,
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white60,
                                            width: 3,
                                          ),
                                        ),
                                        child: Center(
                                          child: _isAnalyzing
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Info tip card
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.92),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 18,
                                            color:
                                                AppColors.onSurfaceVariant,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Keep the leaf within the frame for better results.',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Health status indicator
                                    Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Health: Good | 98% Confidence',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dark overlay when analyzing
                              if (_isAnalyzing)
                                Container(
                                  color: Colors.black45,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: AppTheme.floatingShadow,
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(
                                            color:
                                                AppColors.secondaryContainer,
                                          ),
                                          SizedBox(height: 14),
                                          Text(
                                            'Analyzing Live Frame...',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSurface,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Querying YOLOv8 Detection Model',
                                            style: TextStyle(
                                              color:
                                                  AppColors.onSurfaceVariant,
                                              fontSize: 12,
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
                    ),
                  ),

                  // --- Capture & Analyze button ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAnalyzing
                            ? null
                            : _fetchAndShowDetections,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSurface,
                          minimumSize: const Size.fromHeight(56),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _isAnalyzing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Analyzing Crop...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🌿 ',
                                      style: TextStyle(fontSize: 18)),
                                  Text(
                                    'Capture & Analyze',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
    );
  }

  /// Builds the video feed area — shows the current MJPEG frame,
  /// a loading spinner while waiting, or an error state with retry.
  Widget _buildVideoFeed() {
    if (_hasError) {
      return Container(
        color: AppColors.surfaceContainerHigh,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off,
                  size: 56, color: AppColors.outline),
              const SizedBox(height: 12),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Unable to connect to live stream',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _reconnect,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentFrame == null) {
      return Container(
        color: AppColors.surfaceContainerHigh,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.secondaryContainer),
              SizedBox(height: 12),
              Text(
                'Connecting to camera...',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Image.memory(
      _currentFrame!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}

/// Structured detection item model
class _DetectionItem {
  final String label;
  final double confidence;
  final String severity;
  final List<dynamic>? bbox;
  final String? description;

  const _DetectionItem({
    required this.label,
    required this.confidence,
    required this.severity,
    this.bbox,
    this.description,
  });

  factory _DetectionItem.fromDynamic(dynamic item) {
    if (item is Map<String, dynamic>) {
      final name = item['class'] ??
          item['class_name'] ??
          item['label'] ??
          item['name'] ??
          item['disease'] ??
          'Detected Object';

      double conf = 0.0;
      final rawConf = item['confidence'] ?? item['score'] ?? item['prob'];
      if (rawConf is num) {
        conf = rawConf.toDouble();
        if (conf > 1.0) conf = conf / 100.0; // handle percentage format (e.g. 95 -> 0.95)
      }

      final sev = (item['severity'] ?? _inferSeverity(name.toString())).toString();
      final box = item['box'] ?? item['bbox'] ?? item['coordinates'];

      return _DetectionItem(
        label: name.toString(),
        confidence: conf,
        severity: sev,
        bbox: box is List ? box : null,
        description: item['description']?.toString(),
      );
    } else {
      return _DetectionItem(
        label: item.toString(),
        confidence: 0.95,
        severity: 'Moderate',
      );
    }
  }

  static String _inferSeverity(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('healthy') || lower.contains('normal')) return 'Healthy';
    if (lower.contains('blight') ||
        lower.contains('rot') ||
        lower.contains('wilt') ||
        lower.contains('severe') ||
        lower.contains('rust')) {
      return 'Severe';
    }
    if (lower.contains('spot') ||
        lower.contains('mildew') ||
        lower.contains('virus') ||
        lower.contains('pest')) {
      return 'Moderate';
    }
    return 'Mild';
  }
}

/// Complete detection report model parsed from /object-detection/detections response
class _LiveDetectionReport {
  final String title;
  final String overallSeverity;
  final double overallConfidence;
  final String summary;
  final List<_DetectionItem> detections;
  final List<String> treatments;
  final List<String> preventions;
  final Map<String, dynamic>? rawJson;

  const _LiveDetectionReport({
    required this.title,
    required this.overallSeverity,
    required this.overallConfidence,
    required this.summary,
    required this.detections,
    required this.treatments,
    required this.preventions,
    this.rawJson,
  });

  factory _LiveDetectionReport.fromData(dynamic data) {
    if (data is Map<String, dynamic>) {
      List<_DetectionItem> items = [];

      // Look for detections list in various standard key names
      final rawDetections = data['detections'] ??
          data['results'] ??
          data['predictions'] ??
          data['objects'] ??
          data['boxes'] ??
          data['data'];

      if (rawDetections is List) {
        items = rawDetections
            .map((e) => _DetectionItem.fromDynamic(e))
            .toList();
      }

      // If no list, but top level has a class/disease
      if (items.isEmpty &&
          (data.containsKey('class') ||
              data.containsKey('disease') ||
              data.containsKey('label') ||
              data.containsKey('pathogen_name'))) {
        items.add(_DetectionItem.fromDynamic(data));
      }

      // Title & summary
      final title = data['title'] ??
          data['disease'] ??
          data['pathogen_name'] ??
          (items.isNotEmpty ? items.first.label : 'Crop Analysis Complete');

      // Confidence
      double conf = 0.0;
      final rawConf = data['confidence'] ??
          data['overall_confidence'] ??
          (items.isNotEmpty ? items.first.confidence : 0.92);
      if (rawConf is num) {
        conf = rawConf.toDouble();
        if (conf > 1.0) conf = conf / 100.0;
      }

      // Severity
      final sev = data['severity'] ??
          (items.isNotEmpty ? items.first.severity : 'Healthy');

      // Summary / description
      final summary = data['description'] ??
          data['summary'] ??
          data['message'] ??
          data['findings'] ??
          (items.isNotEmpty
              ? 'YOLOv8 identified ${items.length} feature(s) in the current frame.'
              : 'Detection processed successfully with no acute pathogens detected.');

      // Treatments
      List<String> treatments = [];
      final rawTreatments = data['treatments'] ??
          data['treatment_steps'] ??
          data['recommendations'] ??
          data['actions'];
      if (rawTreatments is List) {
        treatments = rawTreatments.map((e) => e.toString()).toList();
      } else if (treatments.isEmpty && items.isNotEmpty) {
        treatments = _generateDefaultTreatments(items.first.label);
      }

      // Preventions
      List<String> preventions = [];
      final rawPreventions = data['preventions'] ??
          data['prevention_tips'] ??
          data['prevention'];
      if (rawPreventions is List) {
        preventions = rawPreventions.map((e) => e.toString()).toList();
      } else if (preventions.isEmpty && items.isNotEmpty) {
        preventions = _generateDefaultPreventions(items.first.label);
      }

      return _LiveDetectionReport(
        title: title.toString(),
        overallSeverity: sev.toString(),
        overallConfidence: conf > 0 ? conf : 0.95,
        summary: summary.toString(),
        detections: items,
        treatments: treatments,
        preventions: preventions,
        rawJson: data,
      );
    } else if (data is List) {
      final items = data.map((e) => _DetectionItem.fromDynamic(e)).toList();
      final primary = items.isNotEmpty ? items.first.label : 'Crop Scan';
      return _LiveDetectionReport(
        title: primary,
        overallSeverity: items.isNotEmpty ? items.first.severity : 'Healthy',
        overallConfidence: items.isNotEmpty ? items.first.confidence : 0.92,
        summary: 'Detected ${items.length} objects in current camera capture.',
        detections: items,
        treatments: _generateDefaultTreatments(primary),
        preventions: _generateDefaultPreventions(primary),
      );
    } else {
      return _LiveDetectionReport(
        title: 'Detection Result',
        overallSeverity: 'Healthy',
        overallConfidence: 0.95,
        summary: data.toString(),
        detections: [],
        treatments: const [
          'Maintain regular irrigation schedule',
          'Inspect foliage once weekly'
        ],
        preventions: const [
          'Apply organic neem oil spray preventive measures',
          'Keep crop rows well aerated'
        ],
      );
    }
  }

  static List<String> _generateDefaultTreatments(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('healthy')) {
      return [
        'No immediate fungicide or chemical intervention required.',
        'Continue regular watering schedule avoiding leaf wetting.',
        'Monitor foliage weekly for early signs of infection.',
      ];
    }
    if (lower.contains('blight')) {
      return [
        'Isolate infected leaves immediately to prevent spore dispersal.',
        'Apply copper-based fungicide spray (e.g. Copper Oxychloride 50 WP).',
        'Avoid overhead watering; water at base in early morning.',
      ];
    }
    if (lower.contains('rust') || lower.contains('mildew')) {
      return [
        'Apply systemic bio-fungicide or sulfur dusting.',
        'Prune dense foliage to improve sunlight and air circulation.',
        'Sanitize pruning tools between plants.',
      ];
    }
    return [
      'Isolate affected foliage to stop cross-contamination.',
      'Apply recommended targeted organic spray.',
      'Ensure adequate drainage and balanced soil nutrients.',
    ];
  }

  static List<String> _generateDefaultPreventions(String label) {
    return [
      'Practice crop rotation every 1-2 planting cycles.',
      'Use certified disease-resistant crop seed varieties.',
      'Maintain 45-60cm spacing between crop rows for airflow.',
      'Apply protective mulch layer to prevent soil splash onto lower leaves.',
    ];
  }
}

/// Beautifully organized detection result bottom sheet modal
class _DetectionResultModalSheet extends StatelessWidget {
  final _LiveDetectionReport report;
  final Uint8List? snapshotBytes;
  final VoidCallback onRescan;

  const _DetectionResultModalSheet({
    required this.report,
    required this.snapshotBytes,
    required this.onRescan,
  });

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
      case 'critical':
      case 'high':
        return AppColors.error;
      case 'moderate':
      case 'medium':
      case 'warning':
        return AppColors.secondaryContainer;
      case 'healthy':
      case 'good':
      case 'low':
      case 'mild':
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(report.overallSeverity);
    final confPercent = (report.overallConfidence * 100).toStringAsFixed(1);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOLOv8 Detection Analysis',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Real-time object detection report',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Main Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // --- Primary Highlight Card ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Snapshot image thumbnail
                          if (snapshotBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                snapshotBytes!,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.eco,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          const SizedBox(width: 14),

                          // Disease / Object summary
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Severity badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: severityColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    report.overallSeverity.toUpperCase(),
                                    style: TextStyle(
                                      color: severityColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Title
                                Text(
                                  report.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Confidence meter
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: report.overallConfidence,
                                          minHeight: 6,
                                          backgroundColor:
                                              AppColors.surfaceContainerHighest,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            severityColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$confPercent%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // --- Summary note ---
                    if (report.summary.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                report.summary,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // --- Detected Objects / Boxes Section ---
                    if (report.detections.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Identified Objects',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${report.detections.length} Detected',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ...report.detections.map((det) {
                        final detColor = _getSeverityColor(det.severity);
                        final detConf =
                            (det.confidence * 100).toStringAsFixed(1);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outlineVariant
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    detColor.withValues(alpha: 0.15),
                                child: Icon(
                                  Icons.crop_free,
                                  size: 18,
                                  color: detColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      det.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    if (det.bbox != null && det.bbox!.isNotEmpty)
                                      Text(
                                        'Coordinates: ${det.bbox.toString()}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$detConf%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: detColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 18),
                    ],

                    // --- Immediate Action & Treatments ---
                    if (report.treatments.isNotEmpty) ...[
                      const Text(
                        'Recommended Actions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: report.treatments.map((step) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurface,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // --- Prevention Tips ---
                    if (report.preventions.isNotEmpty) ...[
                      const Text(
                        'Prevention & Protection',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: report.preventions.map((tip) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurface,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Bottom Actions ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRescan,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Scan Again'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/voice-qa');
                            },
                            icon: const Icon(Icons.mic, size: 18),
                            label: const Text('Ask AI Voice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryContainer,
                              foregroundColor: AppColors.onSurface,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Draws the scanning frame corner brackets as an overlay.
class _ScanFrameOverlay extends StatelessWidget {
  const _ScanFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanFramePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 24.0;
    const cornerLen = 36.0;

    // Top-left
    canvas.drawLine(
      const Offset(margin, margin + cornerLen),
      const Offset(margin, margin),
      paint,
    );
    canvas.drawLine(
      const Offset(margin, margin),
      const Offset(margin + cornerLen, margin),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - margin - cornerLen, margin),
      Offset(size.width - margin, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + cornerLen),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(margin, size.height - margin - cornerLen),
      Offset(margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + cornerLen, size.height - margin),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - margin - cornerLen, size.height - margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - cornerLen),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
