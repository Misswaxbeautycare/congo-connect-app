import '../main.dart';
import '../models/chat_conversation.dart';

class ChatService {
  /// Récupère (ou crée) la conversation entre l'utilisateur connecté et
  /// une boutique donnée. Retourne l'id de la conversation.
  static Future<String> getOrCreateConversation(String shopId) async {
    final userId = supabase.auth.currentUser!.id;
    final existing = await supabase
        .from('conversations')
        .select('id')
        .eq('shop_id', shopId)
        .eq('client_id', userId)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final created = await supabase
        .from('conversations')
        .insert({'shop_id': shopId, 'client_id': userId})
        .select('id')
        .single();
    return created['id'] as String;
  }

  /// Toutes les conversations de l'utilisateur connecté : celles où il est
  /// client, et celles de ses boutiques (où il est le commerçant).
  static Future<List<ChatConversation>> getMyConversations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final myShops = await supabase.from('shops').select('id').eq('owner_id', userId);
    final myShopIds = (myShops as List).map((s) => s['id'] as String).toList();

    final orFilter = myShopIds.isEmpty
        ? 'client_id.eq.$userId'
        : 'client_id.eq.$userId,shop_id.in.(${myShopIds.join(",")})';

    final response = await supabase
        .from('conversations')
        .select('*, shops(name, cover_url)')
        .or(orFilter)
        .order('last_message_at', ascending: false);

    return (response as List)
        .map((item) => ChatConversation.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ChatMessage>> getMessages(String conversationId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return (response as List).map((item) => ChatMessage.fromMap(item as Map<String, dynamic>)).toList();
  }

  static Future<void> sendMessage(String conversationId, String content) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
    });
    await supabase.from('conversations').update({
      'last_message': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
