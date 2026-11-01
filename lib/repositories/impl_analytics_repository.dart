import '../core/hotel_data_store.dart';
import 'analytics_repository.dart';

class ImplAnalyticsRepository implements AnalyticsRepository {
  final HotelDataStore _store;
  ImplAnalyticsRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<HotelAnalytics> getHotelSummary() => _store.getAnalytics();
}
