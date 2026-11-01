import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/breakpoints.dart';
import '../../state/analytics_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsNotifier>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AnalyticsNotifier>();
    final theme = Theme.of(context);
    final isDesktop = Breakpoints.isExpanded(context);

    return AppScaffold(
      title: 'Финансово-операционная аналитика',
      child: switch (notifier.status) {
        _ when notifier.isLoading => const LoadingState(message: 'Расчет сводных показателей отеля...'),
        _ when notifier.isError => ErrorState(
            error: notifier.errorMessage ?? 'Ошибка загрузки аналитики',
            onRetry: () => notifier.load(),
          ),
        _ when notifier.analytics == null => const EmptyState(title: 'Нет данных для аналитики'),
        _ => SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ключевые показатели эффективности', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: isDesktop ? 4 : (Breakpoints.isMedium(context) ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildKpiCard(
                      title: 'Загрузка отеля',
                      value: '${notifier.analytics!.occupancyRate.toStringAsFixed(1)}%',
                      subtitle: 'Номерной фонд: ${notifier.analytics!.occupiedRooms} из ${notifier.analytics!.totalRooms}',
                      icon: Icons.pie_chart,
                      color: Colors.blue,
                    ),
                    _buildKpiCard(
                      title: 'Общая выручка',
                      value: '${notifier.analytics!.totalRevenue.toStringAsFixed(0)} ₽',
                      subtitle: 'Оплаченные бронирования',
                      icon: Icons.monetization_on,
                      color: Colors.green,
                    ),
                    _buildKpiCard(
                      title: 'Активные брони',
                      value: '${notifier.analytics!.activeBookingsCount}',
                      subtitle: 'Заселенные и подтвержденные',
                      icon: Icons.event_available,
                      color: Colors.orange,
                    ),
                    _buildKpiCard(
                      title: 'Средний чек',
                      value: '${notifier.analytics!.averageBookingValue.toStringAsFixed(0)} ₽',
                      subtitle: 'ADR на одну бронь',
                      icon: Icons.analytics,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text('Распределение номерного фонда', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildStatusRow('Свободно', notifier.analytics!.availableRooms, notifier.analytics!.totalRooms, Colors.green),
                        const SizedBox(height: 12),
                        _buildStatusRow('Занято постояльцами', notifier.analytics!.occupiedRooms, notifier.analytics!.totalRooms, Colors.indigo),
                        const SizedBox(height: 12),
                        _buildStatusRow('Уборка горничными', notifier.analytics!.cleaningRooms, notifier.analytics!.totalRooms, Colors.orange),
                        const SizedBox(height: 12),
                        _buildStatusRow('Ремонт и ТО', notifier.analytics!.maintenanceRooms, notifier.analytics!.totalRooms, Colors.red),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('Популярность дополнительных услуг', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: notifier.analytics!.popularServices.isEmpty
                        ? const Text('Пока не заказано ни одной дополнительной услуги.')
                        : Column(
                            children: notifier.analytics!.popularServices.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.teal, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                                    ),
                                    Chip(
                                      label: Text('Заказано: ${entry.value} раз'),
                                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percent = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('$count из $total (${(percent * 100).toStringAsFixed(0)}%)'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
