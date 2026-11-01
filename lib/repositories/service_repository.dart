import '../models/service.dart';
import '../models/service_query.dart';
import 'base_repository.dart';

abstract class ServiceRepository extends BaseRepository<Service, ServiceQuery> {}
