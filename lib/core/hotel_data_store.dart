import 'dart:math';
import '../models/role.dart';
import '../models/app_user.dart';
import '../models/room_type.dart';
import '../models/room_type_query.dart';
import '../models/room.dart';
import '../models/room_query.dart';
import '../models/guest.dart';
import '../models/guest_query.dart';
import '../models/passport.dart';
import '../models/service.dart';
import '../models/service_query.dart';
import '../models/booking.dart';
import '../models/booking_query.dart';
import '../models/payment.dart';
import '../models/payment_query.dart';
import '../models/employee.dart';
import '../models/employee_query.dart';
import '../models/review.dart';
import '../models/review_query.dart';
import '../models/page_result.dart';
import '../repositories/analytics_repository.dart';
import 'api_exceptions.dart';

class HotelDataStore {
  static final HotelDataStore instance = HotelDataStore._internal();
  factory HotelDataStore() => instance;

  HotelDataStore._internal() {
    _seedData();
  }

  final List<RoomType> _roomTypes = [];
  final List<Room> _rooms = [];
  final List<Guest> _guests = [];
  final List<Passport> _passports = [];
  final List<Service> _services = [];
  final List<Booking> _bookings = [];
  final List<Payment> _payments = [];
  final List<Employee> _employees = [];
  final List<Review> _reviews = [];

  final List<AppUser> _users = [
    const AppUser(
      id: 'usr_guest_1',
      email: 'guest@hotel.ru',
      name: 'Иван Иванов',
      role: Role.guest,
      token: 'jwt_token_guest_1',
      guestId: 'gst_1',
    ),
    const AppUser(
      id: 'usr_recept_1',
      email: 'reception@hotel.ru',
      name: 'Анна Смирнова (Ресепшн)',
      role: Role.receptionist,
      token: 'jwt_token_recept_1',
    ),
    const AppUser(
      id: 'usr_manager_1',
      email: 'manager@hotel.ru',
      name: 'Михаил Орлов (Управляющий)',
      role: Role.manager,
      token: 'jwt_token_manager_1',
    ),
  ];

  void _seedData() {
    final rtStandard = RoomType(
      id: 'rt_standard',
      name: 'Стандартный двухместный',
      description: 'Уютный светлый номер с двуспальной кроватью, Wi-Fi и кондиционером.',
      basePrice: 3500.0,
      capacity: 2,
      amenities: ['Wi-Fi', 'Кондиционер', 'Душ', 'Телевизор'],
    );
    final rtComfort = RoomType(
      id: 'rt_comfort',
      name: 'Комфорт улучшенный',
      description: 'Просторный номер повышенного комфорта с мини-баром и рабочей зоной.',
      basePrice: 5200.0,
      capacity: 3,
      amenities: ['Wi-Fi', 'Кондиционер', 'Ванна', 'Телевизор', 'Мини-бар', 'Сейф'],
    );
    final rtSuite = RoomType(
      id: 'rt_suite',
      name: 'Люкс Премиум',
      description: 'Двухкомнатный номер с панорамным видом на город, джакузи и гостиной.',
      basePrice: 9500.0,
      capacity: 4,
      amenities: ['Wi-Fi', 'Кондиционер', 'Джакузи', 'Smart TV', 'Мини-бар', 'Сейф', 'Панорамный вид', 'Халаты'],
    );
    final rtPresidential = RoomType(
      id: 'rt_presidential',
      name: 'Президентский Сьют',
      description: 'Роскошный представительский сьют с личной террасой и отдельной обеденной зоной.',
      basePrice: 18000.0,
      capacity: 5,
      amenities: ['Wi-Fi', 'Климат-контроль', 'Джакузи', 'Smart TV 65"', 'Премиум мини-бар', 'Терраса', 'Личный батлер'],
    );
    _roomTypes.addAll([rtStandard, rtComfort, rtSuite, rtPresidential]);

    final r101 = Room(id: 'rm_101', number: '101', floor: 1, roomTypeId: rtStandard.id, roomType: rtStandard, status: RoomStatus.available);
    final r102 = Room(id: 'rm_102', number: '102', floor: 1, roomTypeId: rtStandard.id, roomType: rtStandard, status: RoomStatus.available);
    final r103 = Room(id: 'rm_103', number: '103', floor: 1, roomTypeId: rtStandard.id, roomType: rtStandard, status: RoomStatus.cleaning);
    final r201 = Room(id: 'rm_201', number: '201', floor: 2, roomTypeId: rtComfort.id, roomType: rtComfort, status: RoomStatus.occupied);
    final r202 = Room(id: 'rm_202', number: '202', floor: 2, roomTypeId: rtComfort.id, roomType: rtComfort, status: RoomStatus.available);
    final r203 = Room(id: 'rm_203', number: '203', floor: 2, roomTypeId: rtComfort.id, roomType: rtComfort, status: RoomStatus.maintenance, notes: 'Плановый ремонт сантехники');
    final r301 = Room(id: 'rm_301', number: '301', floor: 3, roomTypeId: rtSuite.id, roomType: rtSuite, status: RoomStatus.available);
    final r302 = Room(id: 'rm_302', number: '302', floor: 3, roomTypeId: rtSuite.id, roomType: rtSuite, status: RoomStatus.occupied);
    final r401 = Room(id: 'rm_401', number: '401', floor: 4, roomTypeId: rtPresidential.id, roomType: rtPresidential, status: RoomStatus.available);
    _rooms.addAll([r101, r102, r103, r201, r202, r203, r301, r302, r401]);

    final sBreakfast = const Service(id: 'srv_1', name: 'Завтрак "Шведский стол"', price: 800.0, description: 'Разнообразный шведский стол с 07:00 до 11:00');
    final sSpa = const Service(id: 'srv_2', name: 'Посещение СПА-комплекса', price: 1500.0, description: 'Бассейн, финская сауна, хаммам');
    final sTransfer = const Service(id: 'srv_3', name: 'Трансфер из аэропорта', price: 2000.0, description: 'Встреча в зале прилета на комфортабельном седане');
    final sLaundry = const Service(id: 'srv_4', name: 'Прачечная и химчистка', price: 600.0, description: 'Срочная стирка и глажка одежды');
    final sLateCheckout = const Service(id: 'srv_5', name: 'Поздний выезд (до 18:00)', price: 1800.0, description: 'Продление проживания до вечера');
    _services.addAll([sBreakfast, sSpa, sTransfer, sLaundry, sLateCheckout]);

    final p1 = Passport(id: 'pass_1', guestId: 'gst_1', series: '4510', number: '123456', issuedBy: 'ГУ МВД по г. Москве', issueDate: DateTime(2015, 5, 20), registrationAddress: 'г. Москва, ул. Тверская, д. 12, кв. 45');
    final p2 = Passport(id: 'pass_2', guestId: 'gst_2', series: '4012', number: '654321', issuedBy: 'УФМС по г. Санкт-Петербургу', issueDate: DateTime(2018, 9, 14), registrationAddress: 'г. Санкт-Петербург, Невский пр-т, д. 88, кв. 12');
    final p3 = Passport(id: 'pass_3', guestId: 'gst_3', series: '2214', number: '789101', issuedBy: 'МВД по Нижегородской обл.', issueDate: DateTime(2020, 2, 10), registrationAddress: 'г. Нижний Новгород, ул. Белинского, д. 5, кв. 2');
    _passports.addAll([p1, p2, p3]);

    final g1 = Guest(id: 'gst_1', fullName: 'Иван Сергеевич Иванов', phone: '+79161234567', email: 'guest@hotel.ru', birthDate: DateTime(1990, 4, 15), discountPercent: 10.0, passport: p1);
    final g2 = Guest(id: 'gst_2', fullName: 'Елена Павловна Васильева', phone: '+79219876543', email: 'elena.v@example.com', birthDate: DateTime(1985, 11, 23), discountPercent: 5.0, passport: p2);
    final g3 = Guest(id: 'gst_3', fullName: 'Дмитрий Александрович Кузнецов', phone: '+79035554433', email: 'kuznetsov@example.com', birthDate: DateTime(1993, 7, 8), discountPercent: 0.0, passport: p3);
    _guests.addAll([g1, g2, g3]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final b1 = Booking(
      id: 'bk_1',
      guestId: g1.id,
      guest: g1,
      roomId: r201.id,
      room: r201,
      checkInDate: today.subtract(const Duration(days: 1)),
      checkOutDate: today.add(const Duration(days: 3)),
      status: BookingStatus.checkedIn,
      serviceIds: [sBreakfast.id, sSpa.id],
      services: [sBreakfast, sSpa],
      totalPrice: Booking.calculateTotal(
        roomPricePerNight: r201.roomType!.basePrice,
        checkIn: today.subtract(const Duration(days: 1)),
        checkOut: today.add(const Duration(days: 3)),
        discountPercent: g1.discountPercent,
        services: [sBreakfast, sSpa],
      ),
      notes: 'Гость просил номер с видом на парк',
    );

    final b2 = Booking(
      id: 'bk_2',
      guestId: g2.id,
      guest: g2,
      roomId: r302.id,
      room: r302,
      checkInDate: today,
      checkOutDate: today.add(const Duration(days: 2)),
      status: BookingStatus.checkedIn,
      serviceIds: [sBreakfast.id, sTransfer.id],
      services: [sBreakfast, sTransfer],
      totalPrice: Booking.calculateTotal(
        roomPricePerNight: r302.roomType!.basePrice,
        checkIn: today,
        checkOut: today.add(const Duration(days: 2)),
        discountPercent: g2.discountPercent,
        services: [sBreakfast, sTransfer],
      ),
    );

    final b3 = Booking(
      id: 'bk_3',
      guestId: g3.id,
      guest: g3,
      roomId: r101.id,
      room: r101,
      checkInDate: today.add(const Duration(days: 5)),
      checkOutDate: today.add(const Duration(days: 8)),
      status: BookingStatus.confirmed,
      serviceIds: [sBreakfast.id],
      services: [sBreakfast],
      totalPrice: Booking.calculateTotal(
        roomPricePerNight: r101.roomType!.basePrice,
        checkIn: today.add(const Duration(days: 5)),
        checkOut: today.add(const Duration(days: 8)),
        discountPercent: g3.discountPercent,
        services: [sBreakfast],
      ),
    );
    _bookings.addAll([b1, b2, b3]);

    _payments.addAll([
      Payment(id: 'pay_1', bookingId: b1.id, guestName: g1.fullName, amount: b1.totalPrice, method: PaymentMethod.card, status: PaymentStatus.completed, createdAt: today.subtract(const Duration(days: 1)), transactionCode: 'TX-948102'),
      Payment(id: 'pay_2', bookingId: b2.id, guestName: g2.fullName, amount: b2.totalPrice, method: PaymentMethod.sbp, status: PaymentStatus.completed, createdAt: today, transactionCode: 'TX-104928'),
      Payment(id: 'pay_3', bookingId: b3.id, guestName: g3.fullName, amount: 2000.0, method: PaymentMethod.card, status: PaymentStatus.completed, createdAt: today.subtract(const Duration(hours: 4)), transactionCode: 'TX-554433'),
    ]);

    _employees.addAll([
      Employee(id: 'emp_1', fullName: 'Орлов Михаил Юрьевич', position: EmployeePosition.manager, phone: '+79001112233', email: 'manager@hotel.ru', shift: 'Дневная', salary: 120000.0, hireDate: DateTime(2021, 3, 1)),
      Employee(id: 'emp_2', fullName: 'Смирнова Анна Викторовна', position: EmployeePosition.receptionist, phone: '+79004445566', email: 'reception@hotel.ru', shift: '1/3', salary: 65000.0, hireDate: DateTime(2022, 6, 15)),
      Employee(id: 'emp_3', fullName: 'Ковалева Мария Петровна', position: EmployeePosition.maid, phone: '+79007778899', email: 'kovaleva@hotel.ru', shift: '2/2', salary: 48000.0, hireDate: DateTime(2023, 1, 10)),
      Employee(id: 'emp_4', fullName: 'Романов Артем Игоревич', position: EmployeePosition.concierge, phone: '+79002223344', email: 'romanov@hotel.ru', shift: '2/2', salary: 55000.0, hireDate: DateTime(2023, 4, 20)),
    ]);

    _reviews.addAll([
      Review(id: 'rev_1', guestId: g1.id, guestName: g1.fullName, rating: 5, comment: 'Прекрасный отель! Завтрак превзошел ожидания, спа-зона очень чистая.', response: 'Спасибо за ваш теплый отзыв! Всегда рады видеть вас снова!', createdAt: today.subtract(const Duration(days: 10))),
      Review(id: 'rev_2', guestId: g2.id, guestName: g2.fullName, rating: 4, comment: 'Очень просторный люкс и отличная шумоизоляция. Единственное — трансфер задержался на 10 минут.', response: 'Приносим извинения за задержку трансфера из-за дорожных пробок. Будем рады новой встрече!', createdAt: today.subtract(const Duration(days: 2))),
    ]);
  }

  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _users.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () => throw const UnauthorizedException('Неверный логин или пароль'),
    );
    if (password.length < 4) {
      throw const UnauthorizedException('Неверный логин или пароль');
    }
    return user;
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (_users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      throw const ConflictException('Пользователь с таким email уже существует');
    }

    final newGuestId = 'gst_${DateTime.now().millisecondsSinceEpoch}';
    final newGuest = Guest(
      id: newGuestId,
      fullName: name,
      phone: phone,
      email: email,
      discountPercent: 0.0,
    );
    _guests.add(newGuest);

    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: Role.guest,
      token: 'jwt_${DateTime.now().millisecondsSinceEpoch}',
      guestId: newGuestId,
    );
    _users.add(newUser);
    return newUser;
  }


  List<Booking> checkDateConflicts({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    String? excludeBookingId,
  }) {
    final activeStatuses = [
      BookingStatus.pending,
      BookingStatus.confirmed,
      BookingStatus.checkedIn,
    ];

    return _bookings.where((b) {
      if (b.isDeleted) return false;
      if (excludeBookingId != null && b.id == excludeBookingId) return false;
      if (b.roomId != roomId) return false;
      if (!activeStatuses.contains(b.status)) return false;


      final overlapStart = b.checkInDate.isAfter(checkIn) ? b.checkInDate : checkIn;
      final overlapEnd = b.checkOutDate.isBefore(checkOut) ? b.checkOutDate : checkOut;
      return overlapStart.isBefore(overlapEnd);
    }).toList();
  }

  Future<PageResult<RoomType>> getRoomTypes(RoomTypeQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _roomTypes.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(s) || e.description.toLowerCase().contains(s)).toList();
    }
    if (q.minCapacity != null) {
      list = list.where((e) => e.capacity >= q.minCapacity!).toList();
    }
    if (q.maxPrice != null) {
      list = list.where((e) => e.basePrice <= q.maxPrice!).toList();
    }
    return _paginate(list, q.page, q.perPage);
  }

  Future<RoomType> getRoomTypeById(String id) async {
    final item = _roomTypes.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Тип номера не найден'));
    return item;
  }

  Future<RoomType> saveRoomType(RoomType item) async {
    if (item.name.trim().isEmpty) {
      throw const ValidationException('Ошибка валидации', {'name': 'Укажите название типа номера'});
    }
    if (item.basePrice <= 0) {
      throw const ValidationException('Ошибка валидации', {'basePrice': 'Цена должна быть положительной'});
    }

    final index = _roomTypes.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _roomTypes[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(id: 'rt_${DateTime.now().millisecondsSinceEpoch}');
      _roomTypes.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteRoomType(String id, {bool hard = false}) async {
    final index = _roomTypes.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _roomTypes.removeAt(index);
      } else {
        _roomTypes[index] = _roomTypes[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreRoomType(String id) async {
    final index = _roomTypes.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _roomTypes[index] = _roomTypes[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Room>> getRooms(RoomQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _rooms.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.number.toLowerCase().contains(s) || (e.roomType?.name.toLowerCase().contains(s) ?? false)).toList();
    }
    if (q.roomTypeId != null && q.roomTypeId!.isNotEmpty) {
      list = list.where((e) => e.roomTypeId == q.roomTypeId).toList();
    }
    if (q.status != null) {
      list = list.where((e) => e.status == q.status).toList();
    }
    if (q.floor != null) {
      list = list.where((e) => e.floor == q.floor).toList();
    }
    if (q.checkInDate != null && q.checkOutDate != null) {
      list = list.where((room) {
        if (room.status == RoomStatus.maintenance) return false;
        final conflicts = checkDateConflicts(
          roomId: room.id,
          checkIn: q.checkInDate!,
          checkOut: q.checkOutDate!,
        );
        return conflicts.isEmpty;
      }).toList();
    }
    return _paginate(list, q.page, q.perPage);
  }

  Future<Room> getRoomById(String id) async {
    return _rooms.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Номер не найден'));
  }

  Future<Room> saveRoom(Room item) async {
    final errors = <String, String>{};
    if (item.number.trim().isEmpty) errors['number'] = 'Укажите номер комнаты';
    if (item.roomTypeId.isEmpty) errors['roomTypeId'] = 'Выберите тип номера';
    if (errors.isNotEmpty) throw ValidationException('Ошибка валидации', errors);

    final roomType = _roomTypes.firstWhere((rt) => rt.id == item.roomTypeId, orElse: () => _roomTypes.first);
    final updatedItem = item.copyWith(roomType: roomType);

    final index = _rooms.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _rooms[index] = updatedItem;
      return updatedItem;
    } else {
      final newItem = updatedItem.copyWith(id: 'rm_${DateTime.now().millisecondsSinceEpoch}');
      _rooms.add(newItem);
      return newItem;
    }
  }

  Future<void> updateRoomStatus(String id, RoomStatus status) async {
    final index = _rooms.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _rooms[index] = _rooms[index].copyWith(status: status);
    }
  }

  Future<void> deleteRoom(String id, {bool hard = false}) async {
    final index = _rooms.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _rooms.removeAt(index);
      } else {
        _rooms[index] = _rooms[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreRoom(String id) async {
    final index = _rooms.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _rooms[index] = _rooms[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Booking>> getBookings(BookingQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _bookings.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) =>
        (e.guest?.fullName.toLowerCase().contains(s) ?? false) ||
        (e.room?.number.toLowerCase().contains(s) ?? false)
      ).toList();
    }
    if (q.status != null) {
      list = list.where((e) => e.status == q.status).toList();
    }
    if (q.roomId != null && q.roomId!.isNotEmpty) {
      list = list.where((e) => e.roomId == q.roomId).toList();
    }
    if (q.guestId != null && q.guestId!.isNotEmpty) {
      list = list.where((e) => e.guestId == q.guestId).toList();
    }
    if (q.startDate != null) {
      list = list.where((e) => !e.checkInDate.isBefore(q.startDate!)).toList();
    }
    if (q.endDate != null) {
      list = list.where((e) => !e.checkOutDate.isAfter(q.endDate!)).toList();
    }

    list.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
    return _paginate(list, q.page, q.perPage);
  }

  Future<Booking> getBookingById(String id) async {
    return _bookings.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Бронирование не найдено'));
  }

  Future<Booking> saveBooking(Booking item) async {
    final errors = <String, String>{};
    if (item.guestId.isEmpty) errors['guestId'] = 'Выберите гостя';
    if (item.roomId.isEmpty) errors['roomId'] = 'Выберите номер для бронирования';
    if (!item.checkOutDate.isAfter(item.checkInDate)) {
      errors['checkOutDate'] = 'Дата выезда должна быть строго позже даты заезда';
    }
    if (errors.isNotEmpty) {
      throw ValidationException('Ошибка валидации формы', errors);
    }

    final room = _rooms.firstWhere((r) => r.id == item.roomId, orElse: () => throw const NotFoundException('Номер не найден'));
    if (room.status == RoomStatus.maintenance) {
      throw const ConflictException('Выбранный номер находится на техническом обслуживании / ремонте и недоступен для бронирования!');
    }

    final conflicts = checkDateConflicts(
      roomId: item.roomId,
      checkIn: item.checkInDate,
      checkOut: item.checkOutDate,
      excludeBookingId: item.id.isNotEmpty ? item.id : null,
    );

    if (conflicts.isNotEmpty && item.status != BookingStatus.cancelled) {
      final conflict = conflicts.first;
      final cIn = '${conflict.checkInDate.day.toString().padLeft(2, '0')}.${conflict.checkInDate.month.toString().padLeft(2, '0')}';
      final cOut = '${conflict.checkOutDate.day.toString().padLeft(2, '0')}.${conflict.checkOutDate.month.toString().padLeft(2, '0')}';
      throw ConflictException(
        'Номер ${room.number} уже забронирован на период с $cIn по $cOut! Пожалуйста, выберите другие даты или другой свободный номер.',
      );
    }

    final guest = _guests.firstWhere((g) => g.id == item.guestId, orElse: () => _guests.first);
    final services = _services.where((s) => item.serviceIds.contains(s.id)).toList();

    final computedTotal = Booking.calculateTotal(
      roomPricePerNight: room.roomType?.basePrice ?? 3000.0,
      checkIn: item.checkInDate,
      checkOut: item.checkOutDate,
      discountPercent: guest.discountPercent,
      services: services,
    );

    final updated = item.copyWith(
      guest: guest,
      room: room,
      services: services,
      totalPrice: computedTotal,
    );

    final index = _bookings.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _bookings[index] = updated;
      return updated;
    } else {
      final newItem = updated.copyWith(id: 'bk_${DateTime.now().millisecondsSinceEpoch}');
      _bookings.add(newItem);

      if (newItem.status == BookingStatus.checkedIn) {
        updateRoomStatus(room.id, RoomStatus.occupied);
      }
      return newItem;
    }
  }

  Future<void> deleteBooking(String id, {bool hard = false}) async {
    final index = _bookings.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _bookings.removeAt(index);
      } else {
        _bookings[index] = _bookings[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreBooking(String id) async {
    final index = _bookings.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _bookings[index] = _bookings[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Guest>> getGuests(GuestQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _guests.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.fullName.toLowerCase().contains(s) || e.phone.contains(s) || e.email.toLowerCase().contains(s)).toList();
    }
    if (q.minDiscount != null) {
      list = list.where((e) => e.discountPercent >= q.minDiscount!).toList();
    }
    return _paginate(list, q.page, q.perPage);
  }

  Future<Guest> getGuestById(String id) async {
    return _guests.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Гость не найден'));
  }

  Future<Guest> saveGuest(Guest item) async {
    final errors = <String, String>{};
    if (item.fullName.trim().isEmpty) errors['fullName'] = 'Укажите ФИО гостя';
    if (item.phone.trim().isEmpty) errors['phone'] = 'Укажите контактный телефон';
    if (errors.isNotEmpty) throw ValidationException('Ошибка валидации', errors);

    final index = _guests.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _guests[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(id: 'gst_${DateTime.now().millisecondsSinceEpoch}');
      _guests.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteGuest(String id, {bool hard = false}) async {
    final index = _guests.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _guests.removeAt(index);
      } else {
        _guests[index] = _guests[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreGuest(String id) async {
    final index = _guests.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _guests[index] = _guests[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Service>> getServices(ServiceQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _services.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.name.toLowerCase().contains(s) || e.description.toLowerCase().contains(s)).toList();
    }
    if (q.maxPrice != null) {
      list = list.where((e) => e.price <= q.maxPrice!).toList();
    }
    if (q.isAvailable != null) {
      list = list.where((e) => e.isAvailable == q.isAvailable).toList();
    }
    return _paginate(list, q.page, q.perPage);
  }

  Future<Service> getServiceById(String id) async {
    return _services.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Услуга не найдена'));
  }

  Future<Service> saveService(Service item) async {
    if (item.name.trim().isEmpty) {
      throw const ValidationException('Ошибка валидации', {'name': 'Укажите название услуги'});
    }
    if (item.price < 0) {
      throw const ValidationException('Ошибка валидации', {'price': 'Стоимость не может быть отрицательной'});
    }

    final index = _services.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _services[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(id: 'srv_${DateTime.now().millisecondsSinceEpoch}');
      _services.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteService(String id, {bool hard = false}) async {
    final index = _services.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _services.removeAt(index);
      } else {
        _services[index] = _services[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreService(String id) async {
    final index = _services.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _services[index] = _services[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Payment>> getPayments(PaymentQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _payments.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.guestName.toLowerCase().contains(s) || e.transactionCode.toLowerCase().contains(s)).toList();
    }
    if (q.bookingId != null && q.bookingId!.isNotEmpty) {
      list = list.where((e) => e.bookingId == q.bookingId).toList();
    }
    if (q.method != null) {
      list = list.where((e) => e.method == q.method).toList();
    }
    if (q.status != null) {
      list = list.where((e) => e.status == q.status).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _paginate(list, q.page, q.perPage);
  }

  Future<Payment> getPaymentById(String id) async {
    return _payments.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Платеж не найден'));
  }

  Future<Payment> savePayment(Payment item) async {
    if (item.amount <= 0) {
      throw const ValidationException('Ошибка валидации', {'amount': 'Сумма платежа должна быть больше нуля'});
    }
    final index = _payments.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _payments[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        transactionCode: 'TX-${Random().nextInt(900000) + 100000}',
        createdAt: DateTime.now(),
      );
      _payments.add(newItem);
      return newItem;
    }
  }

  Future<void> deletePayment(String id, {bool hard = false}) async {
    final index = _payments.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _payments.removeAt(index);
      } else {
        _payments[index] = _payments[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restorePayment(String id) async {
    final index = _payments.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _payments[index] = _payments[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Employee>> getEmployees(EmployeeQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _employees.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.fullName.toLowerCase().contains(s) || e.email.toLowerCase().contains(s)).toList();
    }
    if (q.position != null) {
      list = list.where((e) => e.position == q.position).toList();
    }
    return _paginate(list, q.page, q.perPage);
  }

  Future<Employee> getEmployeeById(String id) async {
    return _employees.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Сотрудник не найден'));
  }

  Future<Employee> saveEmployee(Employee item) async {
    final errors = <String, String>{};
    if (item.fullName.trim().isEmpty) errors['fullName'] = 'Укажите ФИО сотрудника';
    if (item.salary <= 0) errors['salary'] = 'Укажите корректный оклад';
    if (errors.isNotEmpty) throw ValidationException('Ошибка валидации', errors);

    final index = _employees.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _employees[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(id: 'emp_${DateTime.now().millisecondsSinceEpoch}');
      _employees.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteEmployee(String id, {bool hard = false}) async {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _employees.removeAt(index);
      } else {
        _employees[index] = _employees[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreEmployee(String id) async {
    final index = _employees.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _employees[index] = _employees[index].copyWith(isDeleted: false);
    }
  }

  Future<PageResult<Review>> getReviews(ReviewQuery q) async {
    await Future.delayed(const Duration(milliseconds: 100));
    var list = _reviews.where((e) => q.showDeleted || !e.isDeleted).toList();
    if (q.search != null && q.search!.isNotEmpty) {
      final s = q.search!.toLowerCase();
      list = list.where((e) => e.comment.toLowerCase().contains(s) || e.guestName.toLowerCase().contains(s)).toList();
    }
    if (q.minRating != null) {
      list = list.where((e) => e.rating >= q.minRating!).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _paginate(list, q.page, q.perPage);
  }

  Future<Review> getReviewById(String id) async {
    return _reviews.firstWhere((e) => e.id == id, orElse: () => throw const NotFoundException('Отзыв не найден'));
  }

  Future<Review> saveReview(Review item) async {
    if (item.comment.trim().isEmpty) {
      throw const ValidationException('Ошибка валидации', {'comment': 'Напишите текст отзыва'});
    }
    final index = _reviews.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _reviews[index] = item;
      return item;
    } else {
      final newItem = item.copyWith(id: 'rev_${DateTime.now().millisecondsSinceEpoch}', createdAt: DateTime.now());
      _reviews.add(newItem);
      return newItem;
    }
  }

  Future<void> deleteReview(String id, {bool hard = false}) async {
    final index = _reviews.indexWhere((e) => e.id == id);
    if (index >= 0) {
      if (hard) {
        _reviews.removeAt(index);
      } else {
        _reviews[index] = _reviews[index].copyWith(isDeleted: true);
      }
    }
  }

  Future<void> restoreReview(String id) async {
    final index = _reviews.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _reviews[index] = _reviews[index].copyWith(isDeleted: false);
    }
  }

  Future<HotelAnalytics> getAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final total = _rooms.where((r) => !r.isDeleted).length;
    final occupied = _rooms.where((r) => !r.isDeleted && r.status == RoomStatus.occupied).length;
    final available = _rooms.where((r) => !r.isDeleted && r.status == RoomStatus.available).length;
    final cleaning = _rooms.where((r) => !r.isDeleted && r.status == RoomStatus.cleaning).length;
    final maintenance = _rooms.where((r) => !r.isDeleted && r.status == RoomStatus.maintenance).length;

    final occupancyRate = total > 0 ? (occupied / total) * 100 : 0.0;
    final totalRevenue = _payments.where((p) => !p.isDeleted && p.status == PaymentStatus.completed).fold<double>(0.0, (sum, p) => sum + p.amount);
    final activeBookings = _bookings.where((b) => !b.isDeleted && (b.status == BookingStatus.confirmed || b.status == BookingStatus.checkedIn)).length;
    final averageBookingValue = activeBookings > 0 ? totalRevenue / activeBookings : 0.0;

    final popularServices = <String, int>{};
    for (final b in _bookings) {
      for (final s in b.services) {
        popularServices[s.name] = (popularServices[s.name] ?? 0) + 1;
      }
    }

    return HotelAnalytics(
      totalRooms: total,
      availableRooms: available,
      occupiedRooms: occupied,
      cleaningRooms: cleaning,
      maintenanceRooms: maintenance,
      occupancyRate: occupancyRate,
      totalRevenue: totalRevenue,
      activeBookingsCount: activeBookings,
      averageBookingValue: averageBookingValue,
      popularServices: popularServices,
    );
  }

  PageResult<T> _paginate<T>(List<T> items, int page, int perPage) {
    final validPage = page < 1 ? 1 : page;
    final validPerPage = perPage < 1 ? 10 : perPage;
    final total = items.length;
    final totalPages = (total / validPerPage).ceil();
    final start = (validPage - 1) * validPerPage;

    if (start >= total) {
      return PageResult(
        page: validPage,
        perPage: validPerPage,
        totalItems: total,
        totalPages: totalPages,
        items: const [],
      );
    }
    final end = (start + validPerPage) > total ? total : (start + validPerPage);
    return PageResult(
      page: validPage,
      perPage: validPerPage,
      totalItems: total,
      totalPages: totalPages,
      items: items.sublist(start, end),
    );
  }
}
