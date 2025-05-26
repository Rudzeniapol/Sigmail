class UserTypingInfo {
  final String userId;
  final String username;

  UserTypingInfo({required this.userId, required this.username});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTypingInfo &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserTypingInfo(userId: $userId, username: $username)';
  }
} 