enum Role {
  guest(1, 'Гость'),
  receptionist(2, 'Администратор (Ресепшн)'),
  manager(3, 'Управляющий');

  final int level;
  final String label;
  const Role(this.level, this.label);

  static Role fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'manager' || 'admin' => Role.manager,
      'receptionist' || 'staff' => Role.receptionist,
      _ => Role.guest,
    };
  }
}
