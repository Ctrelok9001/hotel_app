import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../models/payment.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  factory StatusBadge.room(RoomStatus status) {
    return switch (status) {
      RoomStatus.available => const StatusBadge(
          label: 'Свободен',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
      RoomStatus.occupied => const StatusBadge(
          label: 'Занят',
          color: Colors.indigo,
          icon: Icons.person_outline,
        ),
      RoomStatus.cleaning => const StatusBadge(
          label: 'Уборка',
          color: Colors.orange,
          icon: Icons.cleaning_services_outlined,
        ),
      RoomStatus.maintenance => const StatusBadge(
          label: 'Ремонт / ТО',
          color: Colors.red,
          icon: Icons.build_outlined,
        ),
    };
  }

  factory StatusBadge.booking(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => const StatusBadge(
          label: 'Ожидает',
          color: Colors.amber,
          icon: Icons.hourglass_empty,
        ),
      BookingStatus.confirmed => const StatusBadge(
          label: 'Подтверждено',
          color: Colors.blue,
          icon: Icons.event_available,
        ),
      BookingStatus.checkedIn => const StatusBadge(
          label: 'Заселен',
          color: Colors.teal,
          icon: Icons.meeting_room,
        ),
      BookingStatus.checkedOut => const StatusBadge(
          label: 'Выселен',
          color: Colors.grey,
          icon: Icons.no_meeting_room_outlined,
        ),
      BookingStatus.cancelled => const StatusBadge(
          label: 'Отменено',
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
    };
  }

  factory StatusBadge.payment(PaymentStatus status) {
    return switch (status) {
      PaymentStatus.completed => const StatusBadge(
          label: 'Оплачено',
          color: Colors.green,
          icon: Icons.check_circle,
        ),
      PaymentStatus.pending => const StatusBadge(
          label: 'В обработке',
          color: Colors.orange,
          icon: Icons.access_time,
        ),
      PaymentStatus.refunded => const StatusBadge(
          label: 'Возврат',
          color: Colors.purple,
          icon: Icons.replay,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
