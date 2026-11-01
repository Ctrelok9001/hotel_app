import 'package:flutter/foundation.dart';
import '../repositories/analytics_repository.dart';
import 'load_status.dart';

class AnalyticsNotifier extends ChangeNotifier {
  final AnalyticsRepository _repository;

  HotelAnalytics? _analytics;
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  AnalyticsNotifier(this._repository);

  HotelAnalytics? get analytics => _analytics;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == LoadStatus.loading;
  bool get isSuccess => _status == LoadStatus.success;
  bool get isError => _status == LoadStatus.error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _analytics = await _repository.getHotelSummary();
      _status = LoadStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }
}
