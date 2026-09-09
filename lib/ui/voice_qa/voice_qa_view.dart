import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import '../../utils/app_color.dart';
import '../../utils/app_theme.dart';
import '../shared/custom_bottom_nav.dart';
import 'voice_qa_viewmodel.dart';

/// VIEW
/// Voice/text Q&A thread. StatefulWidget only for the text input
/// controller used when the mic is tapped in demo/text-fallback mode.
class VoiceQaView extends StatefulWidget {
  const VoiceQaView({super.key});

  @override
  State<VoiceQaView> createState() => _VoiceQaViewState();
}

class _VoiceQaViewState extends State<VoiceQaView> with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  AudioRecorder? _audioRecorder;
  String? _currentRecordingPath;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _audioRecorder = AudioRecorder();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _audioRecorder?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleMicTap(BuildContext context) async {
    final vm = context.read<VoiceQaViewModel>();

    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Voice recording is not supported in the browser. Please use the app on Android or iOS.',
            ),
          ),
        );
      }
      return;
    }

    final recorder = _audioRecorder;
    if (recorder == null) {
      return;
    }

    if (vm.isListening) {
      try {
        final path = await recorder.stop();
        if (path != null && path.isNotEmpty) {
          _currentRecordingPath = path;
          vm.toggleListening();
          await vm.askRecordedVoice(path);
        } else {
          vm.toggleListening();
        }
      } catch (_) {
        vm.toggleListening();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to finish voice recording.')),
          );
        }
      }
      return;
    }

    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record voice questions.')),
        );
      }
      return;
    }

    final audioFilePath =
        '${Directory.systemTemp.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      final hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone access was not granted.')),
          );
        }
        return;
      }

      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: audioFilePath,
      );
      _currentRecordingPath = audioFilePath;
      vm.toggleListening();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice recording could not start.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VoiceQaViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        boxShadow: AppTheme.cardShadow,
                      ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text('${vm.questionsRemainingToday} questions remaining today', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: vm.messages.isEmpty
                  ? const Center(
                      child: Text('Tap the mic and ask a farming question.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vm.messages.length,
                      itemBuilder: (context, index) {
                        final message = vm.messages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(20)),
                                child: Text(message.question, style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(radius: 14, backgroundColor: AppColors.accent2, child: Icon(Icons.eco, size: 14, color: AppColors.primaryDark)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardWhite,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: Text(message.answer, style: const TextStyle(height: 1.4))),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.volume_up, size: 18, color: AppColors.accentGold),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (vm.isThinking) const Padding(padding: EdgeInsets.only(bottom: 8), child: LinearProgressIndicator()),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: () => _handleMicTap(context),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulse = vm.isListening ? _pulseController.value : 0.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (vm.isListening)
                          Container(
                            width: 62 + pulse * 26,
                            height: 62 + pulse * 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentGold.withOpacity(0.35 * (1 - pulse)),
                            ),
                          ),
                        child!,
                      ],
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: vm.isListening ? AppColors.accentGold : AppColors.cardWhite,
                      shape: BoxShape.circle,
                      boxShadow: vm.isListening ? AppTheme.floatingShadow : AppTheme.cardShadow,
                    ),
                    child: Icon(Icons.graphic_eq, color: AppColors.primaryDark, size: 26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
