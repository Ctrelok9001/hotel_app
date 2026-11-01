enum EmployeePosition {
  receptionist('Администратор'),
  maid('Горничная'),
  concierge('Портье / Консьерж'),
  manager('Управляющий');

  final String label;
  const EmployeePosition(this.label);

  static EmployeePosition fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'maid' => EmployeePosition.maid,
      'concierge' => EmployeePosition.concierge,
      'manager' => EmployeePosition.manager,
      _ => EmployeePosition.receptionist,
    };
  }
}

class Employee {
  final String id;
  final String fullName;
  final EmployeePosition position;
  final String phone;
  final String email;
  final String shift;
  final double salary;
  final DateTime? hireDate;
  final bool isDeleted;

  const Employee({
    required this.id,
    required this.fullName,
    this.position = EmployeePosition.receptionist,
    required this.phone,
    required this.email,
    this.shift = 'Дневная',
    required this.salary,
    this.hireDate,
    this.isDeleted = false,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      position: EmployeePosition.fromString(json['position']?.toString()),
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      shift: json['shift']?.toString() ?? 'Дневная',
      salary: (json['salary'] is num)
          ? (json['salary'] as num).toDouble()
          : double.tryParse(json['salary']?.toString() ?? '') ?? 0.0,
      hireDate: json['hireDate'] != null ? DateTime.tryParse(json['hireDate'].toString()) : null,
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'position': position.name,
        'phone': phone,
        'email': email,
        'shift': shift,
        'salary': salary,
        'hireDate': hireDate?.toIso8601String().substring(0, 10),
        'isDeleted': isDeleted,
      };

  Employee copyWith({
    String? id,
    String? fullName,
    EmployeePosition? position,
    String? phone,
    String? email,
    String? shift,
    double? salary,
    DateTime? hireDate,
    bool? isDeleted,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      shift: shift ?? this.shift,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
