// lib/main_fixed.dart - Clean web-compatible version
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

// Theme Provider
import 'providers/theme_provider.dart';
import 'screens/auth/login_chooser_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/customer_registration_screen.dart';

// Staff Screen
import 'screens/staff/staff_home.dart';
import 'screens/staff/staff_timekeeping_screen.dart';
import 'screens/staff/staff_schedule_screen.dart';
import 'screens/staff/staff_profile_screen.dart';
import 'screens/staff/staff_settings_screen.dart';
import 'screens/staff/staff_services_screen.dart';
import 'screens/staff/gig_details_screen.dart';
import 'screens/staff/staff_history_screen.dart';
import 'screens/staff/confirmation_screen.dart';
import 'screens/staff/staff_gig_acceptance_screen.dart';

// Customer Screen
import 'screens/customer/customer_home.dart';
import 'screens/customer/customer_services_screen.dart';
import 'screens/theme_settings_screen.dart';
import 'screens/customer/customer_bookings_screen.dart';
import 'screens/customer/booking_form_screen.dart';
import 'screens/customer/customer_profile_screen.dart';
import 'screens/customer/customer_settings_screen.dart';

// Admin Screens
import 'screens/admin/admin_home.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_total_users_screen.dart';
import 'screens/admin/admin_payment_management_screen.dart';
import 'screens/admin/admin_jobs_screen.dart';
import 'screens/admin/admin_timekeeping_screen.dart';
import 'screens/admin/admin_schedule_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/admin/admin_active_gigs_screen.dart';
import 'screens/admin/admin_upcoming_gigs_screen.dart';

// Customer Screens
import 'screens/customer/payment_selection_screen.dart';

// Services
import 'services/mock_data_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/admin_provider_web.dart';
import 'providers/staff_provider.dart';
import 'providers/timekeeping_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/jobs_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/scheduler_provider.dart';

// Repositories
import 'repositories/job_repository.dart';
import 'repositories/staff_schedule_repository.dart';

// Theme
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';

// Utils
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add Flutter error debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🐛 Flutter Error: ${details.exception}');
    print('🐛 Stack: ${details.stack}');
    print('🐛 Library: ${details.library}');
    print('🐛 Context: ${details.context}');
  };

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize theme manager
  try {
    ThemeManager.instance; // Initialize theme manager
  } catch (e) {
    print('Failed to initialize ThemeManager: $e');
  }

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize mock data service
  final mockDataService = MockDataService();

  // Initialize providers
  final authProvider = AuthProvider();
  final adminProvider = AdminProviderWeb();
  final staffProvider = StaffProvider();
  final timekeepingProvider = TimekeepingProvider();
  final bookingProvider = BookingProvider();
  final jobsProvider = JobsProvider();
  final paymentProvider = PaymentProvider();
  final schedulerProvider = SchedulerProvider(
    staffProvider: staffProvider,
    timekeepingProvider: timekeepingProvider,
    authProvider: authProvider,
  );

  // Initialize repositories
  final jobRepository = JobRepository();
  final staffScheduleRepository = StaffScheduleRepository();

  print('🔍 NCL App initialized - Web configuration complete');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AdminProviderWeb>.value(value: adminProvider),
        ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
        ChangeNotifierProvider<TimekeepingProvider>.value(value: timekeepingProvider),

        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
          lazy: true,
        ),

        ChangeNotifierProvider<JobsProvider>(
          create: (_) => JobsProvider(),
          lazy: true,
        ),

        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
          lazy: true,
        ),
        
        ChangeNotifierProvider<SchedulerProvider>(
          create: (context) => SchedulerProvider(
            staffProvider: context.read<StaffProvider>(),
            timekeepingProvider: context.read<TimekeepingProvider>(),
            authProvider: context.read<AuthProvider>(),
          ),
          lazy: true,
        ),
      ],
      child: NCLApp(),
    ),
  );
}

/// Main application widget
class NCLApp extends StatelessWidget {
  const NCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'NCL - Professional Home Services',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentThemeData,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    // Log all redirects for debugging
    print('🔄 GoRouter redirect called: ${state.uri.toString()}');
    return null; // No redirect
  },
  routes: [
    // Public routes
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const LoginChooserScreen(),
      ),
    ),
    GoRoute(
      path: '/login/:role',
      pageBuilder: (context, state) {
        final role = state.pathParameters['role'] ?? 'customer';
        return _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: LoginScreen(userRole: role),
        );
      },
    ),
    GoRoute(
      path: '/register/customer',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerRegistrationScreen(),
      ),
    ),
    
    // Customer routes
    GoRoute(
      path: '/customer/home',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerHome(),
      ),
    ),
    GoRoute(
      path: '/customer/services',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerServicesScreen(),
      ),
    ),
    GoRoute(
      path: '/customer/bookings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerBookingsScreen(),
      ),
    ),
    GoRoute(
      path: '/customer/booking/:serviceId',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: BookingFormScreen(serviceId: state.pathParameters['serviceId'] ?? '1'),
      ),
    ),
    GoRoute(
      path: '/customer/payment/:bookingId',
      builder: (context, state) => PaymentSelectionScreen(
        bookingId: state.pathParameters['bookingId'] ?? '1',
        amount: double.tryParse(state.uri.queryParameters['amount'] ?? '450.00') ?? 450.00,
        serviceTitle: state.uri.queryParameters['service'] ?? 'Cleaning Service',
      ),
    ),
    GoRoute(
      path: '/theme-settings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const ThemeSettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/customer/profile',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/customer/settings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerSettingsScreen(),
      ),
    ),
    
    // Staff routes
    GoRoute(
      path: '/staff/home',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffHome(),
      ),
    ),
    GoRoute(
      path: '/staff/timekeeping',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffTimekeepingScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/schedule',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffScheduleScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/profile',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/settings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffSettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/services',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffServicesScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/service/:serviceId',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: GigDetailsScreen(gigId: state.pathParameters['serviceId'] ?? '1'),
      ),
    ),
    GoRoute(
      path: '/staff/gig/:gigId',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: GigDetailsScreen(gigId: state.pathParameters['gigId'] ?? '1'),
      ),
    ),
    GoRoute(
      path: '/staff/history',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/confirm-service/:serviceId',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: ConfirmationScreen(serviceId: state.pathParameters['serviceId'] ?? '1'),
      ),
    ),
    GoRoute(
      path: '/staff/gig-acceptance',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const GigAcceptanceScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/cancel-gig/:gigId',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: ConfirmationScreen(
          serviceId: state.pathParameters['gigId'] ?? '1',
          gigId: state.pathParameters['gigId'] ?? '1',
          isAvailableService: false,
        ),
      ),
    ),
    
    // Admin routes
    GoRoute(
      path: '/admin/home',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/users',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminUsersScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/total-users',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminTotalUsersScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/active-gigs',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminActiveGigsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/upcoming-gigs',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminUpcomingGigsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/jobs',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminJobsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/timekeeping',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminTimekeepingScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/schedule',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminScheduleScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/payments',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminPaymentManagementScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/analytics',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminAnalyticsScreen(),
      ),
    ),
    GoRoute(
      path: '/admin/settings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminSettingsScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);

// Page transition helper
Page<T> _buildPageWithFadeTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
