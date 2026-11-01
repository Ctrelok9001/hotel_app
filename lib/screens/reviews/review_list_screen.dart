import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/hotel_data_store.dart';
import '../../models/review_query.dart';
import '../../models/role.dart';
import '../../state/auth_notifier.dart';
import '../../state/review_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = ReviewQuery.fromQueryParams(uri.queryParameters);
    context.read<ReviewListNotifier>().load(query: query);
  }

  void _updateQuery(ReviewQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/reviews', queryParameters: params).toString());
    context.read<ReviewListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ReviewListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final canRespond = auth.hasRole(Role.receptionist);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Отзывы гостей отеля',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/reviews/new'),
          icon: const Icon(Icons.rate_review),
          label: const Text('Оставить отзыв'),
        ),
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                Expanded(
                  child: SearchFieldWidget(
                    initialValue: notifier.query.search,
                    hintText: 'Поиск по тексту отзыва...',
                    onSearch: (s) => _updateQuery(notifier.query.copyWith(search: s, page: 1)),
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Удаленные'),
                  selected: notifier.query.showDeleted,
                  onSelected: (val) => _updateQuery(notifier.query.copyWith(showDeleted: val, page: 1)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: switch (notifier.status) {
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка отзывов...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.reviews_outlined,
                  title: 'Отзывов пока нет',
                  subtitle: 'Будьте первым, кто поделится впечатлениями об отдыхе!',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/reviews/new'),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Оставить отзыв'),
                  ),
                ),
              _ => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifier.data.items.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifier.data.items[index];
                          final d = '${item.createdAt.day.toString().padLeft(2, '0')}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.year}';

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(item.guestName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < item.rating ? Icons.star : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(d, style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(item.comment, style: const TextStyle(fontSize: 14)),
                                  if (item.response.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Ответ администрации отеля:',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(item.response, style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (canRespond) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.reply, size: 16),
                                        label: Text(item.response.isEmpty ? 'Ответить гостю' : 'Изменить ответ'),
                                        onPressed: () => _replyDialog(context, item),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    PaginationWidget(
                      currentPage: notifier.data.page,
                      totalPages: notifier.data.totalPages,
                      totalItems: notifier.data.totalItems,
                      onPageChanged: (p) => _updateQuery(notifier.query.copyWith(page: p)),
                    ),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }

  void _replyDialog(BuildContext context, dynamic review) {
    final controller = TextEditingController(text: review.response);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ответ на отзыв от ${review.guestName}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Введите официальный ответ администрации...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () async {
              final updated = review.copyWith(response: controller.text.trim());
              await context.read<ReviewListNotifier>().load();
              await HotelDataStore.instance.saveReview(updated);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                context.read<ReviewListNotifier>().load();
              }
            },
            child: const Text('Сохранить ответ'),
          ),
        ],
      ),
    );
  }
}
