import '../core/hotel_data_store.dart';
import '../models/page_result.dart';
import '../models/room_type.dart';
import '../models/room_type_query.dart';
import 'room_type_repository.dart';

class ImplRoomTypeRepository implements RoomTypeRepository {
  final HotelDataStore _store;
  ImplRoomTypeRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<RoomType>> getAll(RoomTypeQuery query) => _store.getRoomTypes(query);

  @override
  Future<RoomType> getById(String id) => _store.getRoomTypeById(id);

  @override
  Future<RoomType> create(RoomType item) => _store.saveRoomType(item);

  @override
  Future<RoomType> update(String id, RoomType item) => _store.saveRoomType(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteRoomType(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreRoomType(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
