class BookingService {
  final String id;
  final String bookingId;
  final String serviceId;
  final String serviceName;
  final double price;
  final int quantity;
  final double totalAmount;

  const BookingService({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.quantity = 1,
    required this.totalAmount,
  });

  factory BookingService.fromJson(Map<String, dynamic> json) {
    final priceVal = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price']?.toString() ?? '') ?? 0.0;
    final qty = (json['quantity'] is num)
        ? (json['quantity'] as num).toInt()
        : int.tryParse(json['quantity']?.toString() ?? '') ?? 1;

    return BookingService(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ?? '',
      price: priceVal,
      quantity: qty,
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : priceVal * qty,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'price': price,
        'quantity': quantity,
        'totalAmount': totalAmount,
      };
}
