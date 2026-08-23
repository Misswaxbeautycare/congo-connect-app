class ChatConversation {
  final String id;
  final String shopId;
  final String clientId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? shopName;
  final String? shopCoverUrl;

  ChatConversation({
    required this.id,
    required this.shopId,
    required this.clientId,
    this.lastMessage,
    this.lastMessageAt,
    this.shopName,
    this.shopCoverUrl,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    final shop = map['shops'] as Map?;
    return ChatConversation(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      clientId: map['client_id'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.tryParse(map['last_message_at'] as String)
          : null,
      shopName: shop?['name'] as String?,
      shopCoverUrl: shop?['cover_url'] as String?,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime? createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String? ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
