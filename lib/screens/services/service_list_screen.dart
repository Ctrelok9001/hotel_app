import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../models/service_query.dart';
import '../../state/auth_notifier.dart';
import '../../state/service_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = ServiceQuery.fromQueryParams(uri.queryParameters);
    context.read<ServiceListNotifier>().load(query: query);
  }

  void _updateQuery(ServiceQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/services', queryParameters: params).toString());
    context.read<ServiceListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ServiceListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.hasRole(Role.manager);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Услуги и сервис отеля',
      actions: [
        if (canManage)
          FilledButton.icon(
            onPressed: () => context.go('/services/new'),
            icon: const Icon(Icons.add),
            label: const Text('Добавить услугу'),
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
                    hintText: 'Поиск услуги...',
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
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка услуг...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.room_service_outlined,
                  title: 'Услуги не найдены',
                  action: canManage
                      ? FilledButton.icon(
                          onPressed: () => context.go('/services/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить услугу'),
                        )
                      : null,
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
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.room_service),
                              ),
                              title: Row(
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Spacer(),
                                  Text('${item.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(item.description),
                              ),
                              trailing: canManage
                                  ? Row(
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
                                            onPressed: () => context.go('/services/${item.id}/edit'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            onPressed: () => notifier.delete(item.id, hard: false),
                                          ),
                                        ],
                                      ],
                                    )
                                  : null,
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
