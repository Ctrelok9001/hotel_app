import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_app/models/booking.dart';
import 'package:hotel_app/models/room.dart';
import 'package:hotel_app/models/service.dart';
import 'package:hotel_app/screens/auth/forbidden_screen.dart';
import 'package:hotel_app/state/auth_notifier.dart';
import 'package:hotel_app/widgets/multi_select_field.dart';
import 'package:hotel_app/widgets/pagination.dart';
import 'package:hotel_app/widgets/search_field.dart';
import 'package:hotel_app/widgets/states.dart';
import 'package:hotel_app/widgets/status_badge.dart';
import 'package:provider/provider.dart';

void main() {
  group('2. Тесты виджетов гостиничного интерфейса (Widget Tests)', () {
    testWidgets('2.1. Виджеты состояний: LoadingState, EmptyState, ErrorState', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: LoadingState(message: 'Загрузка данных...')),
      ));
      expect(find.text('Загрузка данных...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EmptyState(title: 'Номера не найдены', subtitle: 'Попробуйте сбросить фильтр')),
      ));
      expect(find.text('Номера не найдены'), findsOneWidget);
      expect(find.text('Попробуйте сбросить фильтр'), findsOneWidget);

      bool retryPressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ErrorState(error: 'Сервер 500', onRetry: () => retryPressed = true)),
      ));
      expect(find.text('Сервер 500'), findsOneWidget);
      await tester.tap(find.text('Повторить попытку'));
      expect(retryPressed, isTrue);
    });

    testWidgets('2.2. StatusBadge корректно отображает метки статусов', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge.room(RoomStatus.available),
              StatusBadge.room(RoomStatus.maintenance),
              StatusBadge.booking(BookingStatus.checkedIn),
            ],
          ),
        ),
      ));

      expect(find.text('Свободен'), findsOneWidget);
      expect(find.text('Ремонт / ТО'), findsOneWidget);
      expect(find.text('Заселен'), findsOneWidget);
    });

    testWidgets('2.3. ForbiddenScreen отображает ошибку 403 Forbidden и текущую роль', (tester) async {
      final auth = AuthNotifier();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(
            home: ForbiddenScreen(),
          ),
        ),
      );

      expect(find.textContaining('Доступ ограничен (403 Forbidden)'), findsOneWidget);
      expect(find.textContaining('недостаточно полномочий'), findsOneWidget);
    });

    testWidgets('2.4. MultiSelectField отображает элементы и реагирует на выбор', (tester) async {
      final services = [
        const Service(id: '1', name: 'Завтрак', price: 800),
        const Service(id: '2', name: 'СПА', price: 1500),
      ];
      List<Service> selected = [services[0]];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MultiSelectField<Service>(
                  label: 'Дополнительные услуги',
                  items: services,
                  selectedItems: selected,
                  itemLabel: (s) => s.name,
                  onChanged: (newSel) => setState(() => selected = newSel),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Завтрак'), findsOneWidget);
      expect(find.text('СПА'), findsOneWidget);

      await tester.tap(find.text('СПА'));
      await tester.pumpAndSettle();

      expect(selected.length, equals(2));
    });

    testWidgets('2.5. PaginationWidget отображает страницы и реагирует на клики', (tester) async {
      int page = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PaginationWidget(
                  currentPage: page,
                  totalPages: 5,
                  totalItems: 48,
                  onPageChanged: (newPage) => setState(() => page = newPage),
                );
              },
            ),
          ),
        ),
      );

      expect(find.textContaining('Всего: 48'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byTooltip('Следующая страница'));
      await tester.pumpAndSettle();

      expect(page, equals(2));
    });

    testWidgets('2.6. SearchFieldWidget ввод текста и кнопка очистки', (tester) async {
      String searchQuery = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchFieldWidget(
              hintText: 'Поиск номера...',
              onSearch: (q) => searchQuery = q,
            ),
          ),
        ),
      );

      final input = find.byType(TextField);
      expect(input, findsOneWidget);

      await tester.enterText(input, '101');
      await tester.pump(const Duration(milliseconds: 400));
      expect(searchQuery, equals('101'));

      final clearBtn = find.byIcon(Icons.clear);
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();
      expect(searchQuery, equals(''));
    });
  });
}
