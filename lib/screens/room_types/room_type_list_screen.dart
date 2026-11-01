import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/room_type_query.dart';
import '../../state/room_type_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';

class RoomTypeListScreen extends StatefulWidget {
  const RoomTypeListScreen({super.key});

  @override
  State<RoomTypeListScreen> createState() => _RoomTypeListScreenState();
}

class _RoomTypeListScreenState extends State<RoomTypeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = RoomTypeQuery.fromQueryParams(uri.queryParameters);
    context.read<RoomTypeListNotifier>().load(query: query);
  }

  void _updateQuery(RoomTypeQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/room-types', queryParameters: params).toString());
    context.read<RoomTypeListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<RoomTypeListNotifier>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Типы и тарифы номеров',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/room-types/new'),
          icon: const Icon(Icons.add),
          label: const Text('Добавить категорию'),
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
                    hintText: 'Поиск категории...',
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
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка типов номеров...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  title: 'Типы номеров не найдены',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/room-types/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить категорию'),
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

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item.capacity}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: theme.colorScheme.primary,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'чел',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.primary,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.description),
                                  const SizedBox(height: 4),
                                  Text('Базовый тариф: ${item.basePrice.toStringAsFixed(0)} ₽ / сутки', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                                  if (item.amenities.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: item.amenities.map((a) => Chip(
                                        label: Text(a, style: const TextStyle(fontSize: 10)),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.isDeleted)
                                    IconButton(
                                      icon: const Icon(Icons.restore, color: Colors.green),
                                      onPressed: () => notifier.restore(item.id),
                                    )
                                  else ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => context.go('/room-types/${item.id}/edit'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => notifier.delete(item.id, hard: false),
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
}
