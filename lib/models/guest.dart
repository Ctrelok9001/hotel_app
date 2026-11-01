import 'passport.dart';

class Guest {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final DateTime? birthDate;
  final double discountPercent;
  final String notes;
  final Passport? passport;
  final bool isDeleted;

  const Guest({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    this.birthDate,
    this.discountPercent = 0.0,
    this.notes = '',
    this.passport,
    this.isDeleted = false,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    Passport? parsedPassport;
    if (json['expand'] is Map && json['expand']['passport'] is Map) {
      parsedPassport = Passport.fromJson(json['expand']['passport'] as Map<String, dynamic>);
    } else if (json['passport'] is Map) {
      parsedPassport = Passport.fromJson(json['passport'] as Map<String, dynamic>);
    }

    return Guest(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate'].toString()) : null,
      discountPercent: (json['discountPercent'] is num)
          ? (json['discountPercent'] as num).toDouble()
          : double.tryParse(json['discountPercent']?.toString() ?? '') ?? 0.0,
      notes: json['notes']?.toString() ?? '',
      passport: parsedPassport,
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'birthDate': birthDate?.toIso8601String().substring(0, 10),
        'discountPercent': discountPercent,
        'notes': notes,
        'isDeleted': isDeleted,
        if (passport != null) 'passport': passport!.toJson(),
      };

  Guest copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    DateTime? birthDate,
    double? discountPercent,
    String? notes,
    Passport? passport,
    bool? isDeleted,
  }) {
    return Guest(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      discountPercent: discountPercent ?? this.discountPercent,
      notes: notes ?? this.notes,
      passport: passport ?? this.passport,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
