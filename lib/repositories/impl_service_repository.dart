import '../core/hotel_data_store.dart';
import '../models/page_result.dart';
import '../models/service.dart';
import '../models/service_query.dart';
import 'service_repository.dart';

class ImplServiceRepository implements ServiceRepository {
  final HotelDataStore _store;
  ImplServiceRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Service>> getAll(ServiceQuery query) => _store.getServices(query);

  @override
  Future<Service> getById(String id) => _store.getServiceById(id);

  @override
  Future<Service> create(Service item) => _store.saveService(item);

  @override
  Future<Service> update(String id, Service item) => _store.saveService(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteService(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreService(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
