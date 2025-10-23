// lib/main.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/auth/login_chooser_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/staff/staff_home_screen.dart';
import 'screens/customer/customer_home_screen.dart';
import 'screens/staff/timekeeping_screen.dart';
import 'screens/customer/services_screen.dart';
import 'screens/customer/booking_form_screen.dart';
import 'screens/customer/bookings_screen.dart';
import 'screens/customer/booking_confirmation_screen.dart';

// Services and Providers
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/timekeeping_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/jobs_provider.dart';

// Models - ADD THIS LINE
import 'models/booking_models.dart';

// Theme
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final authService = AuthService();
  
  runApp(NCLApp(authService: authService));
}

class NCLApp extends StatefulWidget {
  final AuthService authService;

  const NCLApp({super.key, required this.authService});

  @override
  State<NCLApp> createState() => _NCLAppState();
}

class _NCLAppState extends State<NCLApp> {
  late final GoRouter _router;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    
    _authProvider = AuthProvider(widget.authService);
    _authProvider.initialize();
    
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider,
      redirect: (context, state) async {
        final isAuthenticated = _authProvider.isAuthenticated;
        final isInitialized = _authProvider.isInitialized;
        final isStaff = _authProvider.isStaff;
        final path = state.matchedLocation;

        if (!isInitialized) return null;

        // Public routes
        final publicRoutes = ['/', '/login/customer', '/login/staff'];
        if (publicRoutes.contains(path)) {
          if (isAuthenticated) {
            return isStaff ? '/staff/home' : '/customer/home';
          }
          return null;
        }

        // Protected routes
        if (!isAuthenticated) return '/';

        // Staff-only routes
        if (path.startsWith('/staff') && !isStaff) {
          return '/customer/home';
        }

        // Customer-only routes
        if (path.startsWith('/customer') && isStaff) {
          return '/staff/home';
        }

        return null;
      },
      routes: [
        // Auth Routes
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginChooserScreen(),
        ),
        GoRoute(
          path: '/login/:role',
          builder: (context, state) {
            final role = state.pathParameters['role'];
            final isStaff = role == 'staff';
            return LoginScreen(isStaffLogin: isStaff);
          },
        ),

        // Staff Routes
        GoRoute(
          path: '/staff/home',
          builder: (context, state) => const StaffHomeScreen(),
        ),
        GoRoute(
          path: '/staff/timekeeping',
          builder: (context, state) => const TimekeepingScreen(),
        ),

        // Customer Routes
        GoRoute(
          path: '/customer/home',
          builder: (context, state) => const CustomerHomeScreen(),
        ),
        GoRoute(
          path: '/customer/services',
          builder: (context, state) => const ServicesScreen(),
        ),
        GoRoute(
          path: '/customer/booking/:serviceId',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            return BookingFormScreen(serviceId: serviceId);
          },
        ),
        GoRoute(
          path: '/customer/bookings',
          builder: (context, state) => const BookingsScreen(),
        ),
        GoRoute(
          path: '/customer/booking-confirmation',
          builder: (context, state) {
            final booking = state.extra as Booking;
            return BookingConfirmationScreen(booking: booking);
          },
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(error: state.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => TimekeepingProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => JobsProvider()),
      ],
      child: MaterialApp.router(
        title: 'NCL Mobile App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}