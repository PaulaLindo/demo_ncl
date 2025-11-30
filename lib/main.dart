// lib/main_fixed.dart - Clean web-compatible version
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

// Import for web-specific functionality
import 'dart:html' as html show window, sessionStorage;

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
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_service_management.dart';

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

  print('🔍 Starting NCL App initialization...');

  // Handle GitHub Pages routing for SPA
  if (kIsWeb) {
    final redirect = html.window.sessionStorage['spa-path'];
    if (redirect != null && redirect.isNotEmpty) {
      print('🔍 Found redirect path: $redirect');
      html.window.sessionStorage.remove('spa-path');
      // Store redirect for later use after app initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (router.routeInformationProvider.value.location != redirect) {
          print('🔍 Redirecting to: $redirect');
          router.go(redirect);
        }
      });
    }
  }

  // Add Flutter error debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    print('🐛 Flutter Error: ${details.exception}');
    print('🐛 Stack: ${details.stack}');
    print('🐛 Library: ${details.library}');
    print('🐛 Context: ${details.context}');
  };

  print('🔍 Initializing timezone...');
  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize theme manager
  try {
    ThemeManager.instance; // Initialize theme manager
    print('🔍 ThemeManager initialized');
  } catch (e) {
    print('Failed to initialize ThemeManager: $e');
  }

  print('🔍 Initializing shared preferences...');
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  print('🔍 Initializing mock data service...');
  // Initialize mock data service
  final mockDataService = MockDataService();

  print('🔍 Initializing providers...');
  // Initialize providers
  final authProvider = AuthProvider();
  final adminProvider = AdminProviderWeb();
  final staffProvider = StaffProvider();
  final timekeepingProvider = TimekeepingProvider();
  final schedulerProvider = SchedulerProvider(
    staffProvider: staffProvider,
    timekeepingProvider: timekeepingProvider,
    authProvider: authProvider,
  );

  print('🔍 Providers initialized');

  // Initialize repositories
  final jobRepository = JobRepository();
  final staffScheduleRepository = StaffScheduleRepository();

  print('🔍 NCL App initialized - Web configuration complete');

  print('🔍 Starting runApp...');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AdminProviderWeb>.value(value: adminProvider),
        ChangeNotifierProvider<StaffProvider>.value(value: staffProvider),
        ChangeNotifierProvider<TimekeepingProvider>.value(value: timekeepingProvider),
        ChangeNotifierProvider<SchedulerProvider>.value(value: schedulerProvider),
        
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
      ],
      child: NCLApp(),
    ),
  );
  print('🔍 runApp completed');
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
    // Login Chooser Route
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const LoginChooserScreen(),
      ),
    ),

    // Customer Login Route
    GoRoute(
      path: '/login/customer',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const LoginScreen(userRole: 'customer'),
      ),
    ),

    // Staff Login Route
    GoRoute(
      path: '/login/staff',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const LoginScreen(userRole: 'staff'),
      ),
    ),

    // Admin Login Route
    GoRoute(
      path: '/login/admin',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const LoginScreen(userRole: 'admin'),
      ),
    ),

    // Customer Registration Route
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
      path: '/customer/bookings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerBookingsScreen(),
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
      path: '/customer/profile',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const CustomerSettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/customer/payment-selection',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const PaymentSelectionScreen(
        bookingId: 'temp',
        amount: 0.0,
        serviceTitle: '',
      ),
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
      path: '/staff/history',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const StaffHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/staff/confirm',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const ConfirmationScreen(
        serviceId: 'temp',
      ),
      ),
    ),
    GoRoute(
      path: '/staff/gig-details/:gigId',
      pageBuilder: (context, state) {
        final gigId = state.pathParameters['gigId'] ?? '';
        return _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: GigDetailsScreen(gigId: gigId),
        );
      },
    ),
    GoRoute(
      path: '/staff/gig-acceptance/:gigId',
      pageBuilder: (context, state) {
        final gigId = state.pathParameters['gigId'] ?? '';
        return _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: GigAcceptanceScreen(),
        );
      },
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
      path: '/admin/dashboard',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminDashboard(),
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
      path: '/admin/schedule',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminScheduleScreen(),
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
      path: '/admin/services',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminServiceManagementScreen(),
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
    GoRoute(
      path: '/admin/jobs',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminJobsScreen(),
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
      path: '/admin/total-users',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const AdminTotalUsersScreen(),
      ),
    ),

    // Service booking routes
    GoRoute(
      path: '/booking/:serviceId',
      pageBuilder: (context, state) {
        final serviceId = state.pathParameters['serviceId'] ?? '';
        return _buildPageWithFadeTransition(
          context: context,
          state: state,
          child: BookingFormScreen(serviceId: serviceId),
        );
      },
    ),

    // Theme settings route
    GoRoute(
      path: '/theme-settings',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: const ThemeSettingsScreen(),
      ),
    ),

    // Catch-all route for 404
    GoRoute(
      path: '/:path(.*)',
      pageBuilder: (context, state) => _buildPageWithFadeTransition(
        context: context,
        state: state,
        child: Scaffold(
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

// Global router getter for GitHub Pages redirect
GoRouter get router => _router;
