class HotelAnalytics {
  final int totalRooms;
  final int availableRooms;
  final int occupiedRooms;
  final int cleaningRooms;
  final int maintenanceRooms;
  final double occupancyRate;
  final double totalRevenue;
  final int activeBookingsCount;
  final double averageBookingValue;
  final Map<String, int> popularServices;

  const HotelAnalytics({
    required this.totalRooms,
    required this.availableRooms,
    required this.occupiedRooms,
    required this.cleaningRooms,
    required this.maintenanceRooms,
    required this.occupancyRate,
    required this.totalRevenue,
    required this.activeBookingsCount,
    required this.averageBookingValue,
    required this.popularServices,
  });
}

abstract class AnalyticsRepository {
  Future<HotelAnalytics> getHotelSummary();
}
