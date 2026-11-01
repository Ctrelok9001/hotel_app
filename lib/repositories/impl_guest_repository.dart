import '../core/hotel_data_store.dart';
import '../models/guest.dart';
import '../models/guest_query.dart';
import '../models/page_result.dart';
import 'guest_repository.dart';

class ImplGuestRepository implements GuestRepository {
  final HotelDataStore _store;
  ImplGuestRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Guest>> getAll(GuestQuery query) => _store.getGuests(query);

  @override
  Future<Guest> getById(String id) => _store.getGuestById(id);

  @override
  Future<Guest> create(Guest item) => _store.saveGuest(item);

  @override
  Future<Guest> update(String id, Guest item) => _store.saveGuest(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteGuest(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreGuest(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
