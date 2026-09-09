/// MODEL
/// A single turn in the Voice Q&A conversation.
class ChatMessageModel {
  final String question;
  final String answer;
  final DateTime askedAt;

  ChatMessageModel({
    required this.question,
    required this.answer,
    DateTime? askedAt,
  }) : askedAt = askedAt ?? DateTime.now();
}
