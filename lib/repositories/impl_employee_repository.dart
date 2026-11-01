import '../core/hotel_data_store.dart';
import '../models/employee.dart';
import '../models/employee_query.dart';
import '../models/page_result.dart';
import 'employee_repository.dart';

class ImplEmployeeRepository implements EmployeeRepository {
  final HotelDataStore _store;
  ImplEmployeeRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Employee>> getAll(EmployeeQuery query) => _store.getEmployees(query);

  @override
  Future<Employee> getById(String id) => _store.getEmployeeById(id);

  @override
  Future<Employee> create(Employee item) => _store.saveEmployee(item);

  @override
  Future<Employee> update(String id, Employee item) => _store.saveEmployee(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteEmployee(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreEmployee(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
