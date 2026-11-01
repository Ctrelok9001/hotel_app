enum PaymentMethod {
  card('Банковская карта'),
  cash('Наличные'),
  sbp('СБП'),
  transfer('Безналичный расчет');

  final String label;
  const PaymentMethod(this.label);

  static PaymentMethod fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'cash' => PaymentMethod.cash,
      'sbp' => PaymentMethod.sbp,
      'transfer' => PaymentMethod.transfer,
      _ => PaymentMethod.card,
    };
  }
}

enum PaymentStatus {
  completed('Оплачено'),
  pending('В обработке'),
  refunded('Возврат');

  final String label;
  const PaymentStatus(this.label);

  static PaymentStatus fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'pending' => PaymentStatus.pending,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.completed,
    };
  }
}

class Payment {
  final String id;
  final String bookingId;
  final String guestName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final String transactionCode;
  final bool isDeleted;

  const Payment({
    required this.id,
    required this.bookingId,
    this.guestName = '',
    required this.amount,
    this.method = PaymentMethod.card,
    this.status = PaymentStatus.completed,
    required this.createdAt,
    this.transactionCode = '',
    this.isDeleted = false,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? json['booking']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      method: PaymentMethod.fromString(json['method']?.toString()),
      status: PaymentStatus.fromString(json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      transactionCode: json['transactionCode']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'guestName': guestName,
        'amount': amount,
        'method': method.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'transactionCode': transactionCode,
        'isDeleted': isDeleted,
      };

  Payment copyWith({
    String? id,
    String? bookingId,
    String? guestName,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    String? transactionCode,
    bool? isDeleted,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      guestName: guestName ?? this.guestName,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      transactionCode: transactionCode ?? this.transactionCode,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
