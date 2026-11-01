import '../models/payment.dart';
import '../models/payment_query.dart';
import 'base_repository.dart';

abstract class PaymentRepository extends BaseRepository<Payment, PaymentQuery> {}
