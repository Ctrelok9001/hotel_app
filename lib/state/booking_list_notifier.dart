import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/page_result.dart';
import '../repositories/booking_repository.dart';
import 'load_status.dart';

class BookingListNotifier extends ChangeNotifier {
  final BookingRepository _repository;

  BookingQuery _query = const BookingQuery();
  PageResult<Booking> _data = PageResult.empty();
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  final Set<String> _selectedIds = {};

  BookingListNotifier(this._repository);

  BookingQuery get query => _query;
  PageResult<Booking> get data => _data;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedIds => _selectedIds;

  bool get isLoading => _status == LoadStatus.loading;
  bool get isSuccess => _status == LoadStatus.success;
  bool get isEmpty => _status == LoadStatus.empty;
  bool get isError => _status == LoadStatus.error;

  void toggleSelect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedIds.addAll(_data.items.map((e) => e.id));
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  Future<void> load({BookingQuery? query}) async {
    if (query != null) _query = query;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.getAll(_query);
      _data = res;
      _status = res.items.isEmpty ? LoadStatus.empty : LoadStatus.success;
      _selectedIds.clear();
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setQuery(BookingQuery newQuery) {
    _query = newQuery;
    load();
  }

  Future<void> delete(String id, {bool hard = false}) async {
    await _repository.delete(id, hard: hard);
    await load();
  }

  Future<void> restore(String id) async {
    await _repository.restore(id);
    await load();
  }

  Future<void> deleteSelected({bool hard = false}) async {
    if (_selectedIds.isEmpty) return;
    await _repository.batchDelete(_selectedIds.toList(), hard: hard);
    _selectedIds.clear();
    await load();
  }
}
