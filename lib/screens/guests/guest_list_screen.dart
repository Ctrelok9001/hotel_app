import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/guest_query.dart';
import '../../state/guest_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = GuestQuery.fromQueryParams(uri.queryParameters);
    context.read<GuestListNotifier>().load(query: query);
  }

  void _updateQuery(GuestQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/guests', queryParameters: params).toString());
    context.read<GuestListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<GuestListNotifier>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Гости и паспортные данные',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/guests/new'),
          icon: const Icon(Icons.person_add),
          label: const Text('Новый гость'),
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
                    hintText: 'Поиск по ФИО, телефону или email...',
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
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка карточек гостей...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'Гости не найдены',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/guests/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить гостя'),
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
                          final guest = notifier.data.items[index];
                          final p = guest.passport;

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Text(guest.fullName.isNotEmpty ? guest.fullName[0] : '?'),
                              ),
                              title: Row(
                                children: [
                                  Text(guest.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  if (guest.discountPercent > 0) ...[
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text('Скидка ${guest.discountPercent.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Colors.indigo)),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Тел: ${guest.phone} • Email: ${guest.email}'),
                                    const SizedBox(height: 2),
                                    if (p != null)
                                      Text(
                                        'Паспорт (1:1): серия ${p.series} № ${p.number} • Выдан: ${p.issuedBy}',
                                        style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                                      )
                                    else
                                      const Text(
                                        'Паспортные данные не внесены',
                                        style: TextStyle(color: Colors.amber, fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (guest.isDeleted)
                                    IconButton(
                                      icon: const Icon(Icons.restore, color: Colors.green),
                                      onPressed: () => notifier.restore(guest.id),
                                    )
                                  else ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => context.go('/guests/${guest.id}/edit'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => notifier.delete(guest.id, hard: false),
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
