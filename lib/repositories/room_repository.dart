import '../models/room.dart';
import '../models/room_query.dart';
import 'base_repository.dart';

abstract class RoomRepository extends BaseRepository<Room, RoomQuery> {
  Future<void> updateStatus(String id, RoomStatus status);
}
