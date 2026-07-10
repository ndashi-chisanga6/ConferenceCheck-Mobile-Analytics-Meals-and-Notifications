import 'package:conference_check_mobile/features/attendee/presentation/attendee_home_screen.dart';
import 'package:conference_check_mobile/features/attendee/presentation/my_qr_screen.dart';
import 'package:conference_check_mobile/features/auth/application/auth_providers.dart';
import 'package:conference_check_mobile/features/auth/presentation/login_screen.dart';
import 'package:conference_check_mobile/features/auth/presentation/splash_screen.dart';
import 'package:conference_check_mobile/features/dashboard/presentation/dashboard_screen.dart';
import 'package:conference_check_mobile/features/events/application/events_providers.dart';
import 'package:conference_check_mobile/features/events/presentation/event_selection_screen.dart';
import 'package:conference_check_mobile/features/meals/presentation/generate_vouchers_screen.dart';
import 'package:conference_check_mobile/features/meals/presentation/meal_redemptions_screen.dart';
import 'package:conference_check_mobile/features/meals/presentation/meal_scanner_screen.dart';
import 'package:conference_check_mobile/features/meals/presentation/meals_screen.dart';
import 'package:conference_check_mobile/features/notifications/data/notification_models.dart';
import 'package:conference_check_mobile/features/notifications/presentation/notification_details_screen.dart';
import 'package:conference_check_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:conference_check_mobile/features/notifications/presentation/send_notification_screen.dart';
import 'package:conference_check_mobile/features/profile/presentation/profile_screen.dart';
import 'package:conference_check_mobile/features/reports/presentation/reports_screen.dart';
import 'package:conference_check_mobile/features/sessions/presentation/session_details_screen.dart';
import 'package:conference_check_mobile/features/sessions/presentation/session_scanner_screen.dart';
import 'package:conference_check_mobile/features/sessions/presentation/sessions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const RoleHomeScreen(),
      ),
      GoRoute(
        path: '/meal-scan',
        builder: (context, state) => const MealScannerScreen(),
      ),
      GoRoute(
        path: '/meal-redemptions',
        builder: (context, state) => const MealRedemptionsScreen(),
      ),
      GoRoute(
        path: '/generate-vouchers',
        builder: (context, state) => const GenerateVouchersScreen(),
      ),
      GoRoute(
        path: '/session-scan',
        builder: (context, state) => const SessionScannerScreen(),
      ),
      GoRoute(
        path: '/sessions/:id',
        builder: (context, state) => SessionDetailsScreen(
          sessionId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/send-notification',
        builder: (context, state) => const SendNotificationScreen(),
      ),
      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) => NotificationDetailsScreen(
          notification: state.extra as EventNotification,
        ),
      ),
    ],
  );
});

class RoleHomeScreen extends ConsumerStatefulWidget {
  const RoleHomeScreen({super.key});

  @override
  ConsumerState<RoleHomeScreen> createState() => _RoleHomeScreenState();
}

class _RoleHomeScreenState extends ConsumerState<RoleHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final event = ref.watch(selectedEventProvider);
    final role = user?.role ?? 'attendee';
    final tabs = _tabsFor(role);
    final selectedIndex = _index.clamp(0, tabs.length - 1);
    final tab = tabs[selectedIndex];

    if (event == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go('/events'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tab.title),
        actions: [
          IconButton(
            tooltip: 'Change event',
            onPressed: () => context.go('/events'),
            icon: const Icon(Icons.event_repeat),
          ),
        ],
      ),
      body: tab.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          for (final item in tabs)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }

  List<_TabItem> _tabsFor(String role) {
    if (role == 'organiser') {
      return const [
        _TabItem(
          'Dashboard',
          'Dashboard',
          Icons.dashboard_outlined,
          DashboardScreen(),
        ),
        _TabItem('Meals', 'Meals', Icons.restaurant_outlined, MealsScreen()),
        _TabItem(
          'Sessions',
          'Sessions',
          Icons.meeting_room_outlined,
          SessionsScreen(),
        ),
        _TabItem(
          'Notifications',
          'Alerts',
          Icons.notifications_none,
          NotificationsScreen(canSend: true),
        ),
        _TabItem(
          'Reports',
          'Reports',
          Icons.description_outlined,
          ReportsScreen(),
        ),
      ];
    }
    if (role == 'scanner') {
      return const [
        _TabItem(
          'Meal scanner',
          'Meals',
          Icons.qr_code_scanner,
          MealScannerScreen(),
        ),
        _TabItem(
          'Session scanner',
          'Sessions',
          Icons.fact_check_outlined,
          SessionScannerScreen(),
        ),
        _TabItem(
          'Meal history',
          'History',
          Icons.history,
          MealRedemptionsScreen(),
        ),
        _TabItem('Profile', 'Profile', Icons.person_outline, ProfileScreen()),
      ];
    }
    return const [
      _TabItem('Home', 'Home', Icons.home_outlined, AttendeeHomeScreen()),
      _TabItem(
        'Notifications',
        'Alerts',
        Icons.notifications_none,
        NotificationsScreen(),
      ),
      _TabItem('My QR', 'My QR', Icons.qr_code_2, MyQrScreen()),
      _TabItem('Profile', 'Profile', Icons.person_outline, ProfileScreen()),
    ];
  }
}

class _TabItem {
  const _TabItem(this.title, this.label, this.icon, this.body);

  final String title;
  final String label;
  final IconData icon;
  final Widget body;
}
