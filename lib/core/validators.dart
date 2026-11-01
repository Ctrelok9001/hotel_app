class Validators {
  static String? required(String? value, [String message = 'Поле обязательно для заполнения']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? message]) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) {
      return message ?? 'Минимальная длина — $min симв.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, [String? message]) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return message ?? 'Максимальная длина — $max симв.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Введите корректный email (например, ivan@example.com)';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final regex = RegExp(r'^\+?[0-9]{10,12}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Введите корректный телефон (например, +79991234567)';
    }
    return null;
  }

  static String? passportSeriesNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(' ', '');
    if (!RegExp(r'^\d{10}$').hasMatch(cleaned)) {
      return 'Паспорт должен содержать 10 цифр (серия 4 + номер 6)';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) return null;
    final numVal = num.tryParse(value.replaceAll(',', '.'));
    if (numVal == null || numVal <= 0) {
      return message ?? 'Введите положительное число';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) return null;
    final numVal = num.tryParse(value.replaceAll(',', '.'));
    if (numVal == null || numVal < 0) {
      return message ?? 'Число не может быть отрицательным';
    }
    return null;
  }

  static String? numberRange(String? value, num min, num max, [String? message]) {
    if (value == null || value.trim().isEmpty) return null;
    final numVal = num.tryParse(value.replaceAll(',', '.'));
    if (numVal == null || numVal < min || numVal > max) {
      return message ?? 'Значение должно быть от $min до $max';
    }
    return null;
  }

  static String? dateOrder(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (!end.isAfter(start)) {
      return 'Дата выезда должна быть строго позже даты заезда';
    }
    return null;
  }
}
