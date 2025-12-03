/// Centralized route definitions for NCL application
/// All routes should be defined here and referenced throughout the app
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Base paths
  static const String home = '/';
  static const String login = '/login';
  static const String customer = '/customer';
  static const String staff = '/staff';
  static const String admin = '/admin';

  // Auth routes
  static const String loginChooser = '/login';
  static const String customerLogin = '$login/customer';
  static const String staffLogin = '$login/staff';
  static const String adminLogin = '$login/admin';
  static const String customerRegistration = '$login/customer/register';
  static const String staffRegistration = '$login/staff/register';

  // Customer routes
  static const String customerHome = '$customer/home';
  static const String customerBookings = '$customer/bookings';
  static const String customerProfile = '$customer/profile';
  static const String customerSettings = '$customer/settings';
  static const String customerServices = '$customer/services';
  static const String customerContact = '$customer/contact';
  
  // Customer booking routes
  static const String booking = '$customer/booking';
  static const String bookingForm = '$booking/new';
  static const String bookingConfirmation = '$booking/confirmation';
  static const String paymentSelection = '$booking/payment';

  // Staff routes
  static const String staffHome = '$staff/home';
  static const String staffProfile = '$staff/profile';
  static const String staffSettings = '$staff/settings';
  static const String staffSchedule = '$staff/schedule';
  static const String staffTimekeeping = '$staff/timekeeping';
  static const String staffHistory = '$staff/history';
  static const String staffServices = '$staff/services';
  static const String staffShiftSwapInbox = '$staff/shift-swap/inbox';

  // Gig management routes
  static const String gigDetails = '$staff/gig-details';
  static const String gigAcceptance = '$staff/gig-acceptance';
  static const String gigCancel = '$staff/gig-cancel';
  static const String gigReport = '$staff/gig-report';

  // Admin routes
  static const String adminHome = '$admin/home';
  static const String adminDashboard = '$admin/dashboard';
  static const String adminProfile = '$admin/profile';
  static const String adminSettings = '$admin/settings';
  static const String adminSchedule = '$admin/schedule';
  static const String adminReports = '$admin/reports';
  static const String adminUsers = '$admin/users';
  static const String adminServices = '$admin/services';
  static const String adminBookings = '$admin/bookings';
  static const String adminPayments = '$admin/payments';
  static const String adminActiveGigs = '$admin/active-gigs';
  static const String adminStaffManagement = '$admin/staff';
  static const String adminTotalUsers = '$admin/total-users';
  static const String adminServiceManagement = '$admin/service-management';
  static const String adminTempCards = '$admin/temp-cards';

  // Utility routes
  static const String themeSettings = '/theme-settings';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';
  static const String contact = '/contact';
  static const String privacy = '/privacy';
  static const String terms = '/terms';

  // Dynamic route generators
  static String bookingDetails(String bookingId) => '$customer/bookings/$bookingId';
  static String bookingFormForService(String serviceId) => '$booking/$serviceId';
  static String gigDetailsById(String gigId) => '$gigDetails/$gigId';
  static String userProfile(String userId) => '/profile/$userId';
  static String serviceDetails(String serviceId) => '$customer/services/$serviceId';
  static String adminUserDetails(String userId) => '$admin/users/$userId';
  static String adminServiceDetails(String serviceId) => '$admin/services/$serviceId';
  static String paymentForBooking(String bookingId) => '$paymentSelection/$bookingId';
  static String confirmBooking(String serviceId) => '$bookingConfirmation/$serviceId';
  static String acceptGig(String gigId) => '$gigAcceptance/$gigId';
  static String reportGig(String gigId) => '$gigReport/$gigId';
  static String cancelGig(String gigId) => '$gigCancel/$gigId';

  // Route validation
  static bool isValidRoute(String route) {
    final allRoutes = [
      // Static routes
      home, loginChooser, customerLogin, staffLogin, adminLogin,
      customerRegistration, staffRegistration, customerHome, customerBookings, customerProfile, customerSettings, customerServices, customerContact, booking, bookingForm,
      bookingConfirmation, paymentSelection, staffHome, staffProfile,
      staffSettings, staffSchedule, staffTimekeeping, staffHistory,
      staffServices, staffShiftSwapInbox, gigAcceptance, gigDetails, gigReport, adminHome,
      adminDashboard, adminProfile, adminSettings, adminSchedule,
      adminReports, adminUsers, adminServices, adminBookings, adminActiveGigs,
      adminStaffManagement, adminServiceManagement, themeSettings,
      notifications, help, about, contact, privacy, terms, adminTotalUsers, adminPayments,
    ];

    // Check exact matches
    if (allRoutes.contains(route)) return true;

    // Check dynamic patterns
    final patterns = [
      RegExp(r'^/customer/booking/[\w-]+$'),           // /customer/booking/serviceId
      RegExp(r'^/customer/bookings/[\w-]+$'),          // /customer/bookings/bookingId
      RegExp(r'^/customer/services/[\w-]+$'),          // /customer/services/serviceId
      RegExp(r'^/staff/gig/details/[\w-]+$'),          // /staff/gig/details/gigId
      RegExp(r'^/staff/gig/accept/[\w-]+$'),           // /staff/gig/accept/gigId
      RegExp(r'^/staff/gig/report/[\w-]+$'),            // /staff/gig/report/gigId
      RegExp(r'^/staff/gig/cancel/[\w-]+$'),            // /staff/gig/cancel/gigId
      RegExp(r'^/admin/users/[\w-]+$'),                 // /admin/users/userId
      RegExp(r'^/admin/services/[\w-]+$'),              // /admin/services/serviceId
      RegExp(r'^/customer/booking/payment/[\w-]+$'),    // /customer/booking/payment/bookingId
      RegExp(r'^/customer/booking/confirmation/[\w-]+$'), // /customer/booking/confirmation/serviceId
      RegExp(r'^/profile/[\w-]+$'),                     // /profile/userId
    ];

    return patterns.any((pattern) => pattern.hasMatch(route));
  }

  // Helper method to get route name for display
  static String getRouteDisplayName(String route) {
    final routeMap = {
      home: 'Home',
      loginChooser: 'Login',
      customerLogin: 'Customer Login',
      staffLogin: 'Staff Login',
      adminLogin: 'Admin Login',
      customerHome: 'Customer Home',
      customerBookings: 'Customer Bookings',
      customerProfile: 'Customer Profile',
      customerSettings: 'Customer Settings',
      customerServices: 'Customer Services',
      staffHome: 'Staff Home',
      staffProfile: 'Staff Profile',
      staffSettings: 'Staff Settings',
      staffSchedule: 'Staff Schedule',
      staffTimekeeping: 'Staff Timekeeping',
      staffHistory: 'Staff History',
      staffServices: 'Staff Services',
      adminHome: 'Admin Home',
      adminDashboard: 'Admin Dashboard',
      adminProfile: 'Admin Profile',
      adminSettings: 'Admin Settings',
      adminSchedule: 'Admin Schedule',
      adminReports: 'Admin Reports',
      adminUsers: 'Admin Users',
      adminServices: 'Admin Services',
      adminBookings: 'Admin Bookings',
      adminActiveGigs: 'Admin Active Gigs',
      adminStaffManagement: 'Admin Staff Management',
      adminServiceManagement: 'Admin Service Management',
      adminPayments: 'Admin Payments',
      adminTotalUsers: 'Admin Total Users',
      themeSettings: 'Theme Settings',
      notifications: 'Notifications',
      help: 'Help',
      about: 'About',
      contact: 'Contact',
      privacy: 'Privacy Policy',
      terms: 'Terms of Service',
    };

    // Check exact matches first
    if (routeMap.containsKey(route)) {
      return routeMap[route]!;
    }

    // Handle dynamic routes
    if (route.startsWith(bookingFormForService(''))) {
      return 'Booking Form';
    }
    if (route.startsWith(acceptGig(''))) {
      return 'Accept Gig';
    }
    if (route.startsWith(gigDetailsById(''))) {
      return 'Gig Details';
    }
    if (route.startsWith(confirmBooking(''))) {
      return 'Booking Confirmation';
    }
    if (route.startsWith(paymentForBooking(''))) {
      return 'Payment Selection';
    }

    return 'Unknown Route';
  }
}
