import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/role.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/auth/forbidden_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/bookings/booking_form_screen.dart';
import '../screens/bookings/booking_list_screen.dart';
import '../screens/calendar/hotel_calendar_screen.dart';
import '../screens/employees/employee_form_screen.dart';
import '../screens/employees/employee_list_screen.dart';
import '../screens/guests/guest_form_screen.dart';
import '../screens/guests/guest_list_screen.dart';
import '../screens/payments/payment_form_screen.dart';
import '../screens/payments/payment_list_screen.dart';
import '../screens/reviews/review_form_screen.dart';
import '../screens/reviews/review_list_screen.dart';
import '../screens/room_types/room_type_form_screen.dart';
import '../screens/room_types/room_type_list_screen.dart';
import '../screens/rooms/room_catalog_screen.dart';
import '../screens/rooms/room_form_screen.dart';
import '../screens/rooms/room_list_screen.dart';
import '../screens/services/service_form_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../state/auth_notifier.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: auth,
    initialLocation: '/rooms/catalog',
    redirect: (context, state) {
      if (!auth.isInitialized) return null;

      final loggedIn = auth.isAuthenticated;
      final target = state.matchedLocation;
      final isPublic = target == '/login' || target == '/register';

      if (!loggedIn && !isPublic) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      if (loggedIn && isPublic) {
        return '/rooms/catalog';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/forbidden', builder: (c, s) => const ForbiddenScreen()),

      GoRoute(
        path: '/rooms/catalog',
        pageBuilder: (c, s) => const NoTransitionPage(child: RoomCatalogScreen()),
      ),

      GoRoute(
        path: '/bookings',
        pageBuilder: (c, s) => const NoTransitionPage(child: BookingListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            builder: (c, s) {
              final roomId = s.uri.queryParameters['roomId'];
              final inStr = s.uri.queryParameters['checkIn'];
              final outStr = s.uri.queryParameters['checkOut'];
              return BookingFormScreen(
                initialRoomId: roomId,
                initialCheckIn: inStr != null ? DateTime.tryParse(inStr) : null,
                initialCheckOut: outStr != null ? DateTime.tryParse(outStr) : null,
              );
            },
          ),
          GoRoute(
            path: ':id/edit',
            builder: (c, s) => BookingFormScreen(bookingId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/calendar',
        redirect: (c, s) => auth.hasRole(Role.receptionist) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: HotelCalendarScreen()),
      ),

      GoRoute(
        path: '/rooms',
        redirect: (c, s) => auth.hasRole(Role.receptionist) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: RoomListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
            builder: (c, s) => const RoomFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
            builder: (c, s) => RoomFormScreen(roomId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/room-types',
        redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: RoomTypeListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            builder: (c, s) => const RoomTypeFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (c, s) => RoomTypeFormScreen(typeId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/guests',
        redirect: (c, s) => auth.hasRole(Role.receptionist) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: GuestListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            builder: (c, s) => const GuestFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (c, s) => GuestFormScreen(guestId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/services',
        pageBuilder: (c, s) => const NoTransitionPage(child: ServiceListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
            builder: (c, s) => const ServiceFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
            builder: (c, s) => ServiceFormScreen(serviceId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/payments',
        pageBuilder: (c, s) => const NoTransitionPage(child: PaymentListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            redirect: (c, s) => auth.hasRole(Role.receptionist) ? null : '/forbidden',
            builder: (c, s) => PaymentFormScreen(bookingId: s.uri.queryParameters['bookingId']),
          ),
        ],
      ),

      GoRoute(
        path: '/reviews',
        pageBuilder: (c, s) => const NoTransitionPage(child: ReviewListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            builder: (c, s) => const ReviewFormScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/employees',
        redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: EmployeeListScreen()),
        routes: [
          GoRoute(
            path: 'new',
            builder: (c, s) => const EmployeeFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            builder: (c, s) => EmployeeFormScreen(employeeId: s.pathParameters['id']),
          ),
        ],
      ),

      GoRoute(
        path: '/analytics',
        redirect: (c, s) => auth.hasRole(Role.manager) ? null : '/forbidden',
        pageBuilder: (c, s) => const NoTransitionPage(child: AnalyticsScreen()),
      ),
    ],
  );
}
