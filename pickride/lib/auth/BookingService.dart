import 'package:pickride/auth/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  Future<void> updateStatus(String bookingId, String newStatus) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': newStatus})
          .eq('id', bookingId);
      
      if (newStatus == 'Confirmed') {
        await assignDriverToBooking(bookingId: bookingId);
      }
    } catch (error) {
      print('Error updating booking status: $error');
      throw Exception('Failed to update booking status');
    }
  }

  Future<void> assignDriverToBooking({required String bookingId}) async {
    try {
      final bookingResponse = await _supabase
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();

      final driversResponse = await _supabase
          .from('users')
          .select()
          .eq('role', 'driver')
          .not('id', 'in', (
            select: 'assigned_driver_id',
            table: 'bookings',
            where: 'status=Confirmed'
          ));

      if (driversResponse.isEmpty) {
        throw Exception('No available drivers found');
      }

      final selectedDriver = driversResponse.first;
      
      await _supabase.from('bookings').update({
        'assigned_driver_id': selectedDriver['id'],
        'assigned_driver_name': selectedDriver['full_name'],
      }).eq('id', bookingId);

      await _notificationService.createDriverNotification(
        driverId: selectedDriver['id'],
        bookingId: bookingId,
        message: 'New booking assigned: ${bookingResponse['destination']}',
      );
    } catch (error) {
      print('Error assigning driver: $error');
      throw Exception('Failed to assign driver');
    }
  }
}
