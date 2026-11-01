import '../core/hotel_data_store.dart';
import '../models/page_result.dart';
import '../models/payment.dart';
import '../models/payment_query.dart';
import 'payment_repository.dart';

class ImplPaymentRepository implements PaymentRepository {
  final HotelDataStore _store;
  ImplPaymentRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Payment>> getAll(PaymentQuery query) => _store.getPayments(query);

  @override
  Future<Payment> getById(String id) => _store.getPaymentById(id);

  @override
  Future<Payment> create(Payment item) => _store.savePayment(item);

  @override
  Future<Payment> update(String id, Payment item) => _store.savePayment(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deletePayment(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restorePayment(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
