import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/chat_conversation.dart';
import '../services/chat_service.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<ChatConversation>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChatService.getMyConversations();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<ChatConversation>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucune conversation pour le moment.', style: TextStyle(color: Colors.black54)),
              ),
            );
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final c = conversations[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: c.shopCoverUrl != null && c.shopCoverUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(c.shopCoverUrl!)
                      : null,
                  child: c.shopCoverUrl == null || c.shopCoverUrl!.isEmpty
                      ? const Icon(Icons.storefront, color: Colors.black45)
                      : null,
                ),
                title: Text(c.shopName ?? 'Boutique', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  c.lastMessage ?? 'Nouvelle conversation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Text(_formatTime(c.lastMessageAt), style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatConversationPage(
                      conversationId: c.id,
                      title: c.shopName ?? 'Boutique',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
