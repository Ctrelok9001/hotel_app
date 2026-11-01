class Passport {
  final String id;
  final String guestId;
  final String series;
  final String number;
  final String issuedBy;
  final DateTime? issueDate;
  final String registrationAddress;

  const Passport({
    required this.id,
    required this.guestId,
    required this.series,
    required this.number,
    required this.issuedBy,
    this.issueDate,
    required this.registrationAddress,
  });

  String get formattedSeriesNumber => '$series $number';

  factory Passport.fromJson(Map<String, dynamic> json) {
    return Passport(
      id: json['id']?.toString() ?? '',
      guestId: json['guestId']?.toString() ?? json['guest_id']?.toString() ?? '',
      series: json['series']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      issuedBy: json['issuedBy']?.toString() ?? json['issued_by']?.toString() ?? '',
      issueDate: json['issueDate'] != null ? DateTime.tryParse(json['issueDate'].toString()) : null,
      registrationAddress: json['registrationAddress']?.toString() ?? json['registration_address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guestId': guestId,
        'series': series,
        'number': number,
        'issuedBy': issuedBy,
        'issueDate': issueDate?.toIso8601String().substring(0, 10),
        'registrationAddress': registrationAddress,
      };

  Passport copyWith({
    String? id,
    String? guestId,
    String? series,
    String? number,
    String? issuedBy,
    DateTime? issueDate,
    String? registrationAddress,
  }) {
    return Passport(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      series: series ?? this.series,
      number: number ?? this.number,
      issuedBy: issuedBy ?? this.issuedBy,
      issueDate: issueDate ?? this.issueDate,
      registrationAddress: registrationAddress ?? this.registrationAddress,
    );
  }
}
