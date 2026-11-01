import '../models/employee.dart';
import '../models/employee_query.dart';
import 'base_repository.dart';

abstract class EmployeeRepository extends BaseRepository<Employee, EmployeeQuery> {}
