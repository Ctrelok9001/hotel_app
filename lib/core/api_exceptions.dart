import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(
      [super.message = 'Сервер недоступен. Проверьте соединение.']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Требуется вход в систему.']);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(
      [super.message = 'Недостаточно прав для выполнения действия.']);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Запись не найдена.']);
}

class ConflictException extends ApiException {
  const ConflictException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, String> errors;
  const ValidationException(super.message, this.errors);
}

class ServerException extends ApiException {
  const ServerException(
      [super.message = 'Ошибка на сервере. Попробуйте позже.']);
}

ApiException mapHttpError(int status, dynamic body) {
  final message = (body is Map && body['message'] is String)
      ? body['message'] as String
      : null;

  Map<String, String> extractErrors() {
    if (body is Map && body['data'] is Map) {
      final dataMap = body['data'] as Map;
      return dataMap.map((k, v) {
        if (v is Map && v['message'] is String) {
          return MapEntry('$k', v['message'] as String);
        }
        return MapEntry('$k', '$v');
      });
    }
    if (body is Map && body['errors'] is Map) {
      return (body['errors'] as Map).map((k, v) => MapEntry('$k', '$v'));
    }
    return const {};
  }

  return switch (status) {
    401 => UnauthorizedException(message ?? 'Требуется вход в систему.'),
    403 => ForbiddenException(message ?? 'Недостаточно прав для этого действия.'),
    404 => NotFoundException(message ?? 'Запись не найдена.'),
    409 => ConflictException(message ?? 'Конфликт данных: операция невозможна.'),
    422 => ValidationException(
        message ?? 'Ошибка валидации данных',
        extractErrors(),
      ),
    _ => ServerException(message ?? 'Неизвестная ошибка (код $status).'),
  };
}

ApiException mapDioError(DioException e) {
  final existing = e.error;
  if (existing is ApiException) return existing;
  if (existing is DioException) return mapDioError(existing);
  if (e.response != null && e.response?.statusCode != null) {
    return mapHttpError(e.response!.statusCode!, e.response?.data);
  }
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout =>
      const NetworkException('Сервер не ответил вовремя (таймаут соединения).'),
    DioExceptionType.connectionError => const NetworkException(
        'Не удалось соединиться с сервером. Убедитесь, что сервер запущен.'),
    DioExceptionType.cancel => const NetworkException('Запрос был отменен.'),
    _ => const ServerException(),
  };
}

Future<T> guard<T>(Future<T> Function() action,
    {bool retryOnNetwork = false}) async {
  int attempt = 0;
  while (true) {
    try {
      return await action();
    } on DioException catch (e) {
      final ex = mapDioError(e);
      if (retryOnNetwork &&
          ex is NetworkException &&
          !(e.message ?? '').contains('отмен') &&
          attempt < 2) {
        attempt++;
        await Future.delayed(Duration(milliseconds: 300 * attempt));
        continue;
      }
      throw ex;
    }
  }
}
