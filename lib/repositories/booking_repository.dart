import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/room.dart';
import 'base_repository.dart';

abstract class BookingRepository extends BaseRepository<Booking, BookingQuery> {

  Future<List<Booking>> checkOverlap({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeBookingId,
  });

  Future<List<Room>> getAvailableRooms({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomTypeId,
  });
}
