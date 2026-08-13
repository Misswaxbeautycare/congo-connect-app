import '../main.dart';
import '../models/app_notification.dart';

class NotificationService {
  static Future<List<AppNotification>> getMyNotifications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AppNotification.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<int> getUnreadCount() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return 0;
    final response = await supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (response as List).length;
  }

  static Future<void> markAsRead(String id) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', id);
  }

  static Future<void> markAllAsRead() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    await supabase.from('notifications').update({'is_read': true}).eq('user_id', userId);
  }

  /// Crée une notification pour un utilisateur donné (ex: propriétaire de boutique).
  static Future<void> notifyUser({
    required String userId,
    required String title,
    required String body,
  }) async {
    await supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'is_read': false,
    });
  }
}
