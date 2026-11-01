import '../models/guest.dart';
import '../models/guest_query.dart';
import 'base_repository.dart';

abstract class GuestRepository extends BaseRepository<Guest, GuestQuery> {}
