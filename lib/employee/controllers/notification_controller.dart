import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationController extends GetxController {
  final _supabase = Supabase.instance.client;
  
  // Observable list of notifications
  var notifications = <Map<String, dynamic>>[].obs;
  
  // Observable unread count
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Stream notifications from Supabase
    _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('employee_id', user.id)
        .order('created_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
      notifications.value = data;
      _updateUnreadCount();
    }, onError: (error) {
      print("Error streaming notifications: $error");
    });
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => n['is_read'] == false).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('employee_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      print("Error marking all notifications as read: $e");
    }
  }
}
