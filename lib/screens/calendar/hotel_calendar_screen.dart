import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import '../../state/booking_list_notifier.dart';
import '../../state/room_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class HotelCalendarScreen extends StatefulWidget {
  const HotelCalendarScreen({super.key});

  @override
  State<HotelCalendarScreen> createState() => _HotelCalendarScreenState();
}

class _HotelCalendarScreenState extends State<HotelCalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomListNotifier>().load();
      context.read<BookingListNotifier>().load();
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomNotifier = context.watch<RoomListNotifier>();
    final bookingNotifier = context.watch<BookingListNotifier>();
    final theme = Theme.of(context);

    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final monthName = _getMonthName(_currentMonth.month);

    return AppScaffold(
      title: 'Шахматка занятости номеров отеля',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 16),
                      onPressed: _prevMonth,
                      tooltip: 'Предыдущий месяц',
                    ),
                    Text(
                      '$monthName ${_currentMonth.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: _nextMonth,
                      tooltip: 'Следующий месяц',
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    _buildLegendItem(Colors.green.shade400, 'Свободно'),
                    _buildLegendItem(Colors.indigo.shade400, 'Заселен'),
                    _buildLegendItem(Colors.amber.shade700, 'Бронь'),
                    _buildLegendItem(Colors.red.shade400, 'Ремонт/ТО'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: switch (roomNotifier.status) {
              _ when roomNotifier.isLoading => const LoadingState(message: 'Построение шахматки занятости...'),
              _ when roomNotifier.isError => ErrorState(
                  error: roomNotifier.errorMessage ?? 'Ошибка загрузки данных',
                  onRetry: () {
                    roomNotifier.load();
                    bookingNotifier.load();
                  },
                ),
              _ when roomNotifier.isEmpty => const EmptyState(title: 'Номера не добавлены в систему'),
              _ => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: {
                          0: const FixedColumnWidth(140),
                          for (int i = 1; i <= daysInMonth; i++) i: const FixedColumnWidth(44),
                        },
                        border: TableBorder.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh),
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text('Номер / День', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              for (int day = 1; day <= daysInMonth; day++)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      '$day',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _isToday(day) ? theme.colorScheme.primary : null,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          for (final room in roomNotifier.data.items)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('№ ${room.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text(room.roomType?.name ?? '', style: TextStyle(color: theme.colorScheme.outline, fontSize: 10), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                for (int day = 1; day <= daysInMonth; day++)
                                  _buildDayCell(context, room, day, bookingNotifier.data.items),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _currentMonth.year && now.month == _currentMonth.month && now.day == day;
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDayCell(BuildContext context, Room room, int day, List<Booking> bookings) {
    final cellDate = DateTime(_currentMonth.year, _currentMonth.month, day);

    if (room.status == RoomStatus.maintenance) {
      return Container(
        height: 38,
        color: Colors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.build, size: 14, color: Colors.red),
      );
    }

    final booking = bookings.cast<Booking?>().firstWhere(
      (b) {
        if (b == null || b.isDeleted || b.roomId != room.id) return false;
        if (b.status == BookingStatus.cancelled) return false;
        final inD = DateTime(b.checkInDate.year, b.checkInDate.month, b.checkInDate.day);
        final outD = DateTime(b.checkOutDate.year, b.checkOutDate.month, b.checkOutDate.day);
        return (cellDate.isAtSameMomentAs(inD) || cellDate.isAfter(inD)) && cellDate.isBefore(outD);
      },
      orElse: () => null,
    );

    if (booking != null) {
      final isOccupied = booking.status == BookingStatus.checkedIn;
      final color = isOccupied ? Colors.indigo : Colors.amber.shade700;

      return Tooltip(
        message: '№ ${room.number}: ${booking.guest?.fullName ?? "Гость"}\n'
            'Период: ${booking.checkInDate.day}.${booking.checkInDate.month} — ${booking.checkOutDate.day}.${booking.checkOutDate.month}\n'
            'Статус: ${booking.status.label}\n'
            'Сумма: ${booking.totalPrice.toStringAsFixed(0)} ₽',
        child: InkWell(
          onTap: () => _showBookingDetails(context, booking),
          child: Container(
            height: 38,
            color: color.withValues(alpha: 0.25),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        final inStr = cellDate.toIso8601String().substring(0, 10);
        final outStr = cellDate.add(const Duration(days: 1)).toIso8601String().substring(0, 10);
        context.go('/bookings/new?roomId=${room.id}&checkIn=$inStr&checkOut=$outStr');
      },
      child: Container(
        height: 38,
        color: Colors.green.withValues(alpha: 0.05),
        child: const Center(
          child: Icon(Icons.add, size: 12, color: Colors.black26),
        ),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Бронирование #${booking.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Гость: ${booking.guest?.fullName ?? "—"}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Номер: ${booking.room?.number ?? "—"} (${booking.room?.roomType?.name ?? ""})'),
            Text('Заезд: ${booking.checkInDate.day}.${booking.checkInDate.month}.${booking.checkInDate.year}'),
            Text('Выезд: ${booking.checkOutDate.day}.${booking.checkOutDate.month}.${booking.checkOutDate.year} (${booking.nights} ноч.)'),
            Text('Статус: ${booking.status.label}'),
            Text('Итоговая стоимость: ${booking.totalPrice.toStringAsFixed(0)} ₽'),
            if (booking.services.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Выбранные услуги:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...booking.services.map((s) => Text('• ${s.name} (${s.price.toStringAsFixed(0)} ₽)')),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Закрыть')),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/bookings/${booking.id}/edit');
            },
            child: const Text('Открыть бронь'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return names[month - 1];
  }
}
