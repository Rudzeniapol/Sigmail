part of 'typing_status_bloc.dart';

sealed class TypingStatusState extends Equatable {
  final Map<String, Set<UserTypingInfo>> typingUsersByChatId;
  
  const TypingStatusState(this.typingUsersByChatId);

  @override
  List<Object> get props => [typingUsersByChatId];
}

class TypingStatusInitial extends TypingStatusState {
  const TypingStatusInitial() : super(const {});
}

class TypingStatusUpdated extends TypingStatusState {
  const TypingStatusUpdated(super.typingUsersByChatId);
}

// Helper для получения печатающих пользователей для конкретного чата
extension TypingStatusStateExtensions on TypingStatusState {
  Set<UserTypingInfo> getUsersTypingInChat(String chatId) {
    return typingUsersByChatId[chatId] ?? const {};
  }

  // Получить строку для отображения, например, "user1, user2 are typing..."
  // или "user1 is typing..."
  String getTypingDisplayMessage(String chatId, String currentUserId) {
    final users = getUsersTypingInChat(chatId)
        .where((user) => user.userId != currentUserId) // Не показывать "You are typing..."
        .toList();

    if (users.isEmpty) {
      return '';
    }

    if (users.length == 1) {
      return '${users.first.username} is typing...';
    }

    if (users.length == 2) {
      return '${users[0].username} and ${users[1].username} are typing...';
    }

    return '${users[0].username} and ${users.length - 1} others are typing...';
  }
} 