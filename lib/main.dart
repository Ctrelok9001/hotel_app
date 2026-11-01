import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/booking_repository.dart';
import 'repositories/employee_repository.dart';
import 'repositories/guest_repository.dart';
import 'repositories/impl_analytics_repository.dart';
import 'repositories/impl_booking_repository.dart';
import 'repositories/impl_employee_repository.dart';
import 'repositories/impl_guest_repository.dart';
import 'repositories/impl_payment_repository.dart';
import 'repositories/impl_review_repository.dart';
import 'repositories/impl_room_repository.dart';
import 'repositories/impl_room_type_repository.dart';
import 'repositories/impl_service_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/room_repository.dart';
import 'repositories/room_type_repository.dart';
import 'repositories/service_repository.dart';
import 'state/analytics_notifier.dart';
import 'state/auth_notifier.dart';
import 'state/booking_list_notifier.dart';
import 'state/employee_list_notifier.dart';
import 'state/guest_list_notifier.dart';
import 'state/payment_list_notifier.dart';
import 'state/review_list_notifier.dart';
import 'state/room_list_notifier.dart';
import 'state/room_type_list_notifier.dart';
import 'state/service_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final authNotifier = AuthNotifier();
  await authNotifier.init();

  runApp(HotelApp(authNotifier: authNotifier));
}

class HotelApp extends StatefulWidget {
  final AuthNotifier authNotifier;
  const HotelApp({super.key, required this.authNotifier});

  @override
  State<HotelApp> createState() => _HotelAppState();
}

class _HotelAppState extends State<HotelApp> {
  late final RoomTypeRepository _roomTypeRepository;
  late final RoomRepository _roomRepository;
  late final GuestRepository _guestRepository;
  late final ServiceRepository _serviceRepository;
  late final BookingRepository _bookingRepository;
  late final PaymentRepository _paymentRepository;
  late final EmployeeRepository _employeeRepository;
  late final ReviewRepository _reviewRepository;
  late final AnalyticsRepository _analyticsRepository;

  @override
  void initState() {
    super.initState();
    _roomTypeRepository = ImplRoomTypeRepository();
    _roomRepository = ImplRoomRepository();
    _guestRepository = ImplGuestRepository();
    _serviceRepository = ImplServiceRepository();
    _bookingRepository = ImplBookingRepository();
    _paymentRepository = ImplPaymentRepository();
    _employeeRepository = ImplEmployeeRepository();
    _reviewRepository = ImplReviewRepository();
    _analyticsRepository = ImplAnalyticsRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authNotifier),
        Provider<RoomTypeRepository>.value(value: _roomTypeRepository),
        Provider<RoomRepository>.value(value: _roomRepository),
        Provider<GuestRepository>.value(value: _guestRepository),
        Provider<ServiceRepository>.value(value: _serviceRepository),
        Provider<BookingRepository>.value(value: _bookingRepository),
        Provider<PaymentRepository>.value(value: _paymentRepository),
        Provider<EmployeeRepository>.value(value: _employeeRepository),
        Provider<ReviewRepository>.value(value: _reviewRepository),
        Provider<AnalyticsRepository>.value(value: _analyticsRepository),

        ChangeNotifierProvider(create: (_) => RoomTypeListNotifier(_roomTypeRepository)),
        ChangeNotifierProvider(create: (_) => RoomListNotifier(_roomRepository)),
        ChangeNotifierProvider(create: (_) => GuestListNotifier(_guestRepository)),
        ChangeNotifierProvider(create: (_) => ServiceListNotifier(_serviceRepository)),
        ChangeNotifierProvider(create: (_) => BookingListNotifier(_bookingRepository)),
        ChangeNotifierProvider(create: (_) => PaymentListNotifier(_paymentRepository)),
        ChangeNotifierProvider(create: (_) => EmployeeListNotifier(_employeeRepository)),
        ChangeNotifierProvider(create: (_) => ReviewListNotifier(_reviewRepository)),
        ChangeNotifierProvider(create: (_) => AnalyticsNotifier(_analyticsRepository)),
      ],
      child: Builder(
        builder: (context) {
          final auth = context.watch<AuthNotifier>();
          final router = buildRouter(auth);

          return MaterialApp.router(
            title: 'Grand Hotel Management System',
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF1E3A8A),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              fontFamily: 'Roboto',
              cardTheme: CardThemeData(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          );
        },
      ),
    );
  }
}
