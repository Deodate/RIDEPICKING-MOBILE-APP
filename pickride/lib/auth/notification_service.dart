import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createDriverNotification({
    required String driverId,
    required String bookingId,
    required String message,
  }) async {
    try {
      await _supabase.from('driver_notifications').insert({
        'driver_id': driverId,
        'booking_id': bookingId,
        'message': message,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      print('Error creating notification: $error');
      throw Exception('Failed to create notification');
    }
  }

  Future<List<Map<String, dynamic>>> getDriverNotifications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('driver_notifications')
          .select('*, bookings(*)')
          .eq('driver_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching notifications: $error');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from('driver_notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (error) {
      print('Error marking notification as read: $error');
      throw Exception('Failed to mark notification as read');
    }
  }
}
