import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_app/core/api_exceptions.dart';
import 'package:hotel_app/core/hotel_data_store.dart';
import 'package:hotel_app/core/validators.dart';
import 'package:hotel_app/models/booking.dart';
import 'package:hotel_app/models/booking_query.dart';
import 'package:hotel_app/models/role.dart';
import 'package:hotel_app/models/room.dart';
import 'package:hotel_app/models/room_type.dart';
import 'package:hotel_app/models/service.dart';
import 'package:hotel_app/models/service_query.dart';

void main() {
  group('1. Модульные тесты гостиничной системы (Unit Tests)', () {
    test('1.1. Проверка пересечения интервалов дат бронирования (Conflict Detection)', () {
      final store = HotelDataStore.instance;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final conflicts = store.checkDateConflicts(
        roomId: 'rm_201',
        checkIn: today,
        checkOut: today.add(const Duration(days: 2)),
      );

      expect(conflicts.isNotEmpty, isTrue, reason: 'Интервалы должны пересекаться');
      expect(conflicts.first.roomId, equals('rm_201'));

      final futureConflicts = store.checkDateConflicts(
        roomId: 'rm_201',
        checkIn: today.add(const Duration(days: 20)),
        checkOut: today.add(const Duration(days: 25)),
      );
      expect(futureConflicts.isEmpty, isTrue, reason: 'На свободные даты конфликтов быть не должно');
    });

    test('1.2. Автоматический расчет стоимости проживания с учетом скидки и услуг', () {
      final inDate = DateTime(2026, 11, 1);
      final outDate = DateTime(2026, 11, 5);
      const basePrice = 5000.0;
      const discountPercent = 10.0;

      final services = [
        const Service(id: 's1', name: 'Завтрак', price: 800.0),
        const Service(id: 's2', name: 'СПА', price: 1500.0),
      ];

      final total = Booking.calculateTotal(
        roomPricePerNight: basePrice,
        checkIn: inDate,
        checkOut: outDate,
        discountPercent: discountPercent,
        services: services,
      );


      expect(total, equals(20300.0));
    });

    test('1.3. Валидаторы email, телефона и дат', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('текст'), isNull);

      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('guest@hotel.ru'), isNull);

      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('+79991234567'), isNull);

      final d1 = DateTime(2026, 11, 5);
      final d2 = DateTime(2026, 11, 2);
      expect(Validators.dateOrder(d1, d2), isNotNull, reason: 'Выезд раньше заезда недопустим');
      expect(Validators.dateOrder(d2, d1), isNull);
    });

    test('1.4. Валидация серии и номера паспорта (10 цифр)', () {
      expect(Validators.passportSeriesNumber('123'), isNotNull);
      expect(Validators.passportSeriesNumber('4510 123456'), isNull);
      expect(Validators.passportSeriesNumber('4510123456'), isNull);
    });

    test('1.5. Проверка ролевой модели (Гость, Ресепшн, Управляющий)', () {
      expect(Role.guest.level, equals(1));
      expect(Role.receptionist.level, equals(2));
      expect(Role.manager.level, equals(3));

      expect(Role.manager.level >= Role.guest.level, isTrue);
      expect(Role.manager.level >= Role.receptionist.level, isTrue);
      expect(Role.guest.level >= Role.receptionist.level, isFalse);

      expect(Role.fromString('manager'), equals(Role.manager));
      expect(Role.fromString('receptionist'), equals(Role.receptionist));
      expect(Role.fromString('guest'), equals(Role.guest));
    });

    test('1.6. Сериализация и десериализация Booking (формат PocketBase/REST API)', () {
      final b = Booking(
        id: 'bk_test_100',
        guestId: 'gst_1',
        roomId: 'rm_101',
        checkInDate: DateTime(2026, 11, 10),
        checkOutDate: DateTime(2026, 11, 14),
        status: BookingStatus.confirmed,
        totalPrice: 15000.0,
      );

      final json = b.toJson();
      expect(json['id'], equals('bk_test_100'));
      expect(json['status'], equals('confirmed'));

      final fromJson = Booking.fromJson(json);
      expect(fromJson.id, equals(b.id));
      expect(fromJson.nights, equals(4));
      expect(fromJson.status, equals(BookingStatus.confirmed));
    });

    test('1.7. Сериализация и десериализация Room и RoomType', () {
      final rt = RoomType(
        id: 'rt_lux',
        name: 'Люкс Премиум',
        description: 'Двухкомнатный номер',
        basePrice: 9500.0,
        capacity: 3,
        amenities: ['Wi-Fi', 'Джакузи'],
      );

      final room = Room(
        id: 'rm_999',
        number: '999',
        floor: 9,
        roomTypeId: rt.id,
        roomType: rt,
        status: RoomStatus.available,
      );

      final json = room.toJson();
      expect(json['number'], equals('999'));
      expect(json['status'], equals('available'));

      final restored = Room.fromJson(json);
      expect(restored.number, equals('999'));
      expect(restored.roomType?.name, equals('Люкс Премиум'));
    });

    test('1.8. Построение URL Query параметров и обратный парсинг (п. 14)', () {
      const q = BookingQuery(
        page: 2,
        perPage: 15,
        search: 'Иванов',
        status: BookingStatus.checkedIn,
        showDeleted: true,
      );

      final params = q.toQueryParams();
      expect(params['page'], equals('2'));
      expect(params['perPage'], equals('15'));
      expect(params['search'], equals('Иванов'));
      expect(params['status'], equals('checkedIn'));
      expect(params['showDeleted'], equals('true'));

      final parsed = BookingQuery.fromQueryParams(params);
      expect(parsed.page, equals(2));
      expect(parsed.perPage, equals(15));
      expect(parsed.search, equals('Иванов'));
      expect(parsed.status, equals(BookingStatus.checkedIn));
      expect(parsed.showDeleted, isTrue);
    });

    test('1.9. Обработка серверных кодов HTTP 409 и 422', () {
      final conflictEx = mapHttpError(409, {'message': 'Номер уже занят'});
      expect(conflictEx, isA<ConflictException>());
      expect(conflictEx.message, contains('Номер уже занят'));

      final valEx = mapHttpError(422, {
        'message': 'Ошибка валидации',
        'errors': {'email': 'Некорректный email', 'room': 'Обязательное поле'},
      });
      expect(valEx, isA<ValidationException>());
      final v = valEx as ValidationException;
      expect(v.errors['email'], equals('Некорректный email'));
    });

    test('1.10. Логическое удаление, фильтр удаленных и восстановление записи', () async {
      final store = HotelDataStore.instance;

      final srv = await store.saveService(const Service(
        id: 'srv_temp',
        name: 'Временная услуга',
        price: 500.0,
      ));

      await store.deleteService(srv.id, hard: false);
      final activeList = await store.getServices(const ServiceQuery(showDeleted: false));
      expect(activeList.items.any((e) => e.id == srv.id), isFalse);

      final withDeleted = await store.getServices(const ServiceQuery(showDeleted: true));
      expect(withDeleted.items.any((e) => e.id == srv.id), isTrue);

      await store.restoreService(srv.id);
      final restoredList = await store.getServices(const ServiceQuery(showDeleted: false));
      expect(restoredList.items.any((e) => e.id == srv.id), isTrue);
    });
  });
}
