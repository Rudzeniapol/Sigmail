import 'package:flutter/material.dart';
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/data/models/user/user_simple_model.dart';

class ChatParticipantsScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatParticipantsScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    // Отфильтровываем null участников, если вдруг такие есть
    final List<UserSimpleModel> participants = chat.members?.where((member) => member != null).toList() ?? [];
    final String chatName = chat.name ?? 'Групповой чат';

    return Scaffold(
      appBar: AppBar(
        title: Text('Участники: $chatName'),
      ),
      body: participants.isEmpty
          ? const Center(
              child: Text('В этом чате нет участников или информация недоступна.'),
            )
          : ListView.builder(
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  leading: CircleAvatar(
                    // TODO: Использовать profileImageUrl, если он есть
                    // backgroundImage: participant.profileImageUrl != null && participant.profileImageUrl!.isNotEmpty
                    //     ? NetworkImage(participant.profileImageUrl!)
                    //     : null,
                    child: Text(participant.username.isNotEmpty ? participant.username[0].toUpperCase() : '?'),
                  ),
                  title: Text(participant.username),
                  // Можно добавить subtitle с email или другой информацией, если она есть в UserSimpleModel
                  // subtitle: Text(participant.email ?? ''), // Если бы email был в UserSimpleModel
                );
              },
            ),
    );
  }
} 