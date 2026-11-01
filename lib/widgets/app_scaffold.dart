import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/breakpoints.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';

class NavDestinationItem {
  final String path;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Role minRole;
  final bool exactRoleOnly;

  const NavDestinationItem({
    required this.path,
    required this.title,
    required this.icon,
    required this.selectedIcon,
    this.minRole = Role.guest,
    this.exactRoleOnly = false,
  });
}

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  static const List<NavDestinationItem> _allDestinations = [
    NavDestinationItem(
      path: '/rooms/catalog',
      title: 'Каталог номеров',
      icon: Icons.hotel_outlined,
      selectedIcon: Icons.hotel,
      minRole: Role.guest,
    ),
    NavDestinationItem(
      path: '/bookings',
      title: 'Бронирования',
      icon: Icons.book_online_outlined,
      selectedIcon: Icons.book_online,
      minRole: Role.guest,
    ),
    NavDestinationItem(
      path: '/calendar',
      title: 'Шахматка отеля',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
      minRole: Role.receptionist,
    ),
    NavDestinationItem(
      path: '/rooms',
      title: 'Номера и уборка',
      icon: Icons.meeting_room_outlined,
      selectedIcon: Icons.meeting_room,
      minRole: Role.receptionist,
    ),
    NavDestinationItem(
      path: '/guests',
      title: 'Гости и паспорта',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      minRole: Role.receptionist,
    ),
    NavDestinationItem(
      path: '/services',
      title: 'Услуги отеля',
      icon: Icons.room_service_outlined,
      selectedIcon: Icons.room_service,
      minRole: Role.guest,
    ),
    NavDestinationItem(
      path: '/payments',
      title: 'Платежи и чеки',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      minRole: Role.guest,
    ),
    NavDestinationItem(
      path: '/reviews',
      title: 'Отзывы гостей',
      icon: Icons.star_outline,
      selectedIcon: Icons.star,
      minRole: Role.guest,
    ),
    NavDestinationItem(
      path: '/room-types',
      title: 'Типы номеров',
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      minRole: Role.manager,
    ),
    NavDestinationItem(
      path: '/employees',
      title: 'Штат сотрудников',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge,
      minRole: Role.manager,
    ),
    NavDestinationItem(
      path: '/analytics',
      title: 'Финансовая аналитика',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      minRole: Role.manager,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final currentRole = auth.currentRole ?? Role.guest;
    final currentPath = GoRouterState.of(context).matchedLocation;

    final availableDestinations = _allDestinations.where((item) {
      return currentRole.level >= item.minRole.level;
    }).toList();

    final isDesktop = Breakpoints.isExpanded(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context, auth, currentRole, availableDestinations, currentPath),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  actions: [
                    _buildUserPlate(context, auth),
                    if (actions != null) ...actions!,
                    const SizedBox(width: 8),
                  ],
                ),
                body: child,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          _buildUserPlate(context, auth),
          if (actions != null) ...actions!,
        ],
      ),
      drawer: Drawer(
        child: _buildSidebar(context, auth, currentRole, availableDestinations, currentPath, inDrawer: true),
      ),
      body: child,
    );
  }

  Widget _buildUserPlate(BuildContext context, AuthNotifier auth) {
    final currentRole = auth.currentRole ?? Role.guest;
    final userName = auth.user?.name.split(' ').first ?? 'Гость';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Chip(
        avatar: const Icon(Icons.account_circle, size: 18),
        label: Text(
          '$userName: ${currentRole.label}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    AuthNotifier auth,
    Role currentRole,
    List<NavDestinationItem> items,
    String currentPath, {
    bool inDrawer = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: inDrawer ? null : 260,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.apartment, color: theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Hotel',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Система отеля',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_circle, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.name ?? 'Пользователь',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentRole.label,
                          style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentPath.startsWith(item.path);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    onTap: () {
                      if (inDrawer) Navigator.of(context).pop();
                      context.go(item.path);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.user?.name ?? 'Гость',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentRole.label,
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  tooltip: 'Выйти из системы',
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
