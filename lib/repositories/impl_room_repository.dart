import '../core/hotel_data_store.dart';
import '../models/page_result.dart';
import '../models/room.dart';
import '../models/room_query.dart';
import 'room_repository.dart';

class ImplRoomRepository implements RoomRepository {
  final HotelDataStore _store;
  ImplRoomRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Room>> getAll(RoomQuery query) => _store.getRooms(query);

  @override
  Future<Room> getById(String id) => _store.getRoomById(id);

  @override
  Future<Room> create(Room item) => _store.saveRoom(item);

  @override
  Future<Room> update(String id, Room item) => _store.saveRoom(item.copyWith(id: id));

  @override
  Future<void> updateStatus(String id, RoomStatus status) => _store.updateRoomStatus(id, status);

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteRoom(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreRoom(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
