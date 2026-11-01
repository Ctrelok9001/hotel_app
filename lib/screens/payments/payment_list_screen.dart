import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/payment_query.dart';
import '../../models/role.dart';
import '../../state/auth_notifier.dart';
import '../../state/payment_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';
import '../../widgets/status_badge.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = PaymentQuery.fromQueryParams(uri.queryParameters);
    context.read<PaymentListNotifier>().load(query: query);
  }

  void _updateQuery(PaymentQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/payments', queryParameters: params).toString());
    context.read<PaymentListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PaymentListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final canCreate = auth.hasRole(Role.receptionist);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Платежи и финансовые чеки',
      actions: [
        if (canCreate)
          FilledButton.icon(
            onPressed: () => context.go('/payments/new'),
            icon: const Icon(Icons.add),
            label: const Text('Принять оплату'),
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
                    hintText: 'Поиск по номеру чека или гостю...',
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
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка истории платежей...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Платежи не найдены',
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
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.payment),
                              ),
                              title: Row(
                                children: [
                                  Text('${item.amount.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text('• ${item.method.label}', style: TextStyle(color: theme.colorScheme.outline, fontSize: 13)),
                                  const Spacer(),
                                  StatusBadge.payment(item.status),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Гость: ${item.guestName.isNotEmpty ? item.guestName : "Клиент отеля"} • Чек: ${item.transactionCode}'),
                                    Text('Дата: $d • Бронь #${item.bookingId}', style: TextStyle(color: theme.colorScheme.outline, fontSize: 11)),
                                  ],
                                ),
                              ),
                              trailing: canCreate && !item.isDeleted
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => notifier.delete(item.id, hard: false),
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
