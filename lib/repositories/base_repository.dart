import '../models/page_result.dart';

abstract class BaseRepository<T, Q> {
  Future<PageResult<T>> getAll(Q query);
  Future<T> getById(String id);
  Future<T> create(T item);
  Future<T> update(String id, T item);
  Future<void> delete(String id, {bool hard = false});
  Future<void> restore(String id);
  Future<void> batchDelete(List<String> ids, {bool hard = false});
}
