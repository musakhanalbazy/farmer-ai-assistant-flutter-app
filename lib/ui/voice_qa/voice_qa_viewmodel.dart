import 'package:flutter/foundation.dart';
import '../../model/chat_message_model.dart';
import '../../repository/repository.dart';

/// VIEWMODEL
/// Owns the conversation history, the daily question quota, and the
/// askQuestion() action. The View only triggers the mic/send action
/// and renders whatever is here.
class VoiceQaViewModel extends ChangeNotifier {
  final Repository _repository = Repository();

  final List<ChatMessageModel> messages = [];
  int questionsRemainingToday = 2;
  bool isListening = false;
  bool isThinking = false;

  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty || questionsRemainingToday <= 0) return;

    isThinking = true;
    notifyListeners();

    final answer = await _repository.askQuestion(question);

    messages.add(ChatMessageModel(question: question, answer: answer));
    questionsRemainingToday -= 1;
    isThinking = false;
    notifyListeners();
  }

  Future<void> askRecordedVoice(String audioPath, {String label = 'Voice note'}) async {
    if (audioPath.trim().isEmpty || questionsRemainingToday <= 0) return;

    isThinking = true;
    isListening = false;
    notifyListeners();

    final answer = await _repository.askQuestion(
      label,
      audioPath: audioPath,
    );

    messages.add(ChatMessageModel(question: label, answer: answer));
    questionsRemainingToday -= 1;
    isThinking = false;
    notifyListeners();
  }

  void toggleListening() {
    isListening = !isListening;
    notifyListeners();
  }
}
