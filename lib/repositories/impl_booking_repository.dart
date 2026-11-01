import '../core/hotel_data_store.dart';
import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';
import '../models/room.dart';
import '../models/room_query.dart';
import 'booking_repository.dart';

class ImplBookingRepository implements BookingRepository {
  final HotelDataStore _store;
  ImplBookingRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Booking>> getAll(BookingQuery query) => _store.getBookings(query);

  @override
  Future<Booking> getById(String id) => _store.getBookingById(id);

  @override
  Future<Booking> create(Booking item) => _store.saveBooking(item);

  @override
  Future<Booking> update(String id, Booking item) => _store.saveBooking(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteBooking(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreBooking(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }

  @override
  Future<List<Booking>> checkOverlap({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeBookingId,
  }) async {
    return _store.checkDateConflicts(
      roomId: roomId,
      checkIn: checkIn,
      checkOut: checkOut,
      excludeBookingId: excludeBookingId,
    );
  }

  @override
  Future<List<Room>> getAvailableRooms({
    required DateTime checkIn,
    required DateTime checkOut,
    String? roomTypeId,
  }) async {
    final res = await _store.getRooms(RoomQuery(
      perPage: 100,
      roomTypeId: roomTypeId,
      checkInDate: checkIn,
      checkOutDate: checkOut,
    ));
    return res.items;
  }
}
