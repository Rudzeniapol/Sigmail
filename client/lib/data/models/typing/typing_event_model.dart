class TypingEventModel {
  final String chatId;
  final String userId;
  final String username;
  final bool isTyping; // true для UserTypingInChat, false для UserStoppedTypingInChat

  TypingEventModel({
    required this.chatId,
    required this.userId,
    required this.username,
    required this.isTyping,
  });

  @override
  String toString() {
    return 'TypingEventModel(chatId: $chatId, userId: $userId, username: $username, isTyping: $isTyping)';
  }
} 