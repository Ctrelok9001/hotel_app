import '../core/hotel_data_store.dart';
import '../models/page_result.dart';
import '../models/review.dart';
import '../models/review_query.dart';
import 'review_repository.dart';

class ImplReviewRepository implements ReviewRepository {
  final HotelDataStore _store;
  ImplReviewRepository([HotelDataStore? store]) : _store = store ?? HotelDataStore.instance;

  @override
  Future<PageResult<Review>> getAll(ReviewQuery query) => _store.getReviews(query);

  @override
  Future<Review> getById(String id) => _store.getReviewById(id);

  @override
  Future<Review> create(Review item) => _store.saveReview(item);

  @override
  Future<Review> update(String id, Review item) => _store.saveReview(item.copyWith(id: id));

  @override
  Future<void> delete(String id, {bool hard = false}) => _store.deleteReview(id, hard: hard);

  @override
  Future<void> restore(String id) => _store.restoreReview(id);

  @override
  Future<void> batchDelete(List<String> ids, {bool hard = false}) async {
    for (final id in ids) {
      await delete(id, hard: hard);
    }
  }
}
