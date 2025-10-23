# 🚀 NCL Mobile App - Complete Setup Guide

## 📁 Project Structure

```
lib/
├── main.dart                          # ✅ Updated with Provider & new routes
├── models/
│   ├── job_service_models.dart        # ✅ Already exists
│   ├── timekeeping_models.dart        # 🆕 NEW
│   └── booking_models.dart            # 🆕 NEW
├── providers/
│   ├── timekeeping_provider.dart      # 🆕 NEW
│   └── booking_provider.dart          # 🆕 NEW
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          # ✅ Already exists
│   │   └── login_chooser_screen.dart  # ✅ Already exists
│   ├── staff/
│   │   ├── staff_home_screen.dart     # ✅ Already exists
│   │   ├── timekeeping_screen.dart    # 🆕 NEW
│   │   ├── timer_tab.dart             # 🆕 NEW
│   │   ├── schedule_tab.dart          # 🆕 NEW
│   │   └── history_tab.dart           # 🆕 NEW
│   └── customer/
│       ├── customer_home_screen.dart  # ✅ Already exists
│       ├── services_screen.dart       # 🆕 NEW
│       ├── booking_form_screen.dart   # 🆕 NEW
│       └── bookings_screen.dart       # 🆕 NEW
├── services/
│   └── auth_service.dart              # ✅ Already exists
└── widgets/
    ├── customer_nav_bar.dart          # ✅ Already exists
    ├── job_card.dart                  # ✅ Already exists
    └── service_card.dart              # ✅ Already exists
```

---

## 🔧 Installation Steps

### Step 1: Update pubspec.yaml
Replace your `pubspec.yaml` with the provided version that includes all new dependencies.

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Create New Directories
```bash
mkdir -p lib/providers
```

### Step 4: Add New Model Files
Create these files in `lib/models/`:
- `timekeeping_models.dart`
- `booking_models.dart`

### Step 5: Add Provider Files
Create these files in `lib/providers/`:
- `timekeeping_provider.dart`
- `booking_provider.dart`

### Step 6: Add Timekeeping Screens
Create these files in `lib/screens/staff/`:
- `timekeeping_screen.dart`
- `timer_tab.dart`
- `schedule_tab.dart`
- `history_tab.dart`

### Step 7: Add Booking Screens
Create these files in `lib/screens/customer/`:
- `services_screen.dart`
- `booking_form_screen.dart`
- `bookings_screen.dart`

### Step 8: Update main.dart
Replace your existing `main.dart` with the updated version.

### Step 9: Platform-Specific Setup for QR Scanner

#### Android Setup
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 33  // or higher
    
    defaultConfig {
        minSdkVersion 21    // mobile_scanner requires min SDK 21
    }
}
```

#### iOS Setup
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes for check-in</string>
```

Update `ios/Podfile`:
```ruby
platform :ios, '12.0'  # mobile_scanner requires iOS 12+
```

---

## 🎯 Features Implemented

### ✅ Timekeeping Module
- **Timer Tab**: 
  - QR code scanning for check-in
  - Manual check-out
  - Temp card/proxy check-in system
  - Recent time records display
  
- **Schedule Tab**: 
  - Monthly calendar view
  - External shifts (Hotel jobs)
  - NCL platform shifts
  - Available days indicator
  - Click to find jobs on free days
  
- **History Tab**: 
  - Complete time records list
  - Duration tracking
  - Self vs Proxy differentiation

### ✅ Booking Module
- **Services Screen**: 
  - Service catalog with filtering
  - Category filters (All, Cleaning, Garden, Care)
  - Featured & Popular badges
  - Service details modal
  - Direct booking flow
  
- **Booking Form**: 
  - Date picker
  - Time slot selection
  - Property size selector
  - Special instructions
  - Frequency options (one-time, weekly, etc.)
  
- **My Bookings**: 
  - Booking list with filters (All, Upcoming, Completed)
  - Status badges
  - Booking details modal
  - Reschedule & cancel options
  - Rating functionality

---

## 🧪 Testing the App

### Test Credentials
```dart
// Customer Login
Email: user@example.com
Password: password

// Staff Login
Staff ID: staff001
PIN: 1234

// Temp Cards for Proxy Check-in
Card: A1B2C3 (Maria Lopez)
Card: D4E5F6 (James Kim)
```

### Testing Flow

#### Customer Flow:
1. Start app → Select "Customer Login"
2. Login with customer credentials
3. Navigate to "Services" tab
4. Browse services, select one
5. Fill booking form
6. View in "Bookings" tab

#### Staff Flow:
1. Start app → Select "Staff / Cleaner Access"
2. Login with staff credentials
3. Navigate to "Clock" (Timekeeping)
4. **Timer Tab**: Try QR scan or temp card check-in
5. **Schedule Tab**: View calendar with shifts
6. **History Tab**: See completed time records

---

## 🔥 Mock Data Included

### Timekeeping:
- 2 available jobs for check-in
- 2 temp cards for proxy system
- Pre-populated work shifts (Hotel + NCL)
- Sample time record

### Booking:
- 7 services across 3 categories
- 3 existing bookings (confirmed, pending, completed)
- Realistic pricing and details

---

## 🐛 Common Issues & Solutions

### Issue: QR Scanner not working
**Solution**: Ensure camera permissions are granted and device has a camera

### Issue: Provider error on hot reload
**Solution**: Full restart the app (Stop → Run)

### Issue: Table calendar not showing
**Solution**: Run `flutter pub get` and rebuild

### Issue: Navigation not working
**Solution**: Check GoRouter configuration and route names

---

## 🎨 Customization

### Change Primary Color
In `main.dart`:
```dart
final Color primaryColor = const Color(0xFF5D3F6A); // Change this
```

### Add More Mock Data
Edit the provider files:
- `timekeeping_provider.dart` → `_initializeMockData()`
- `booking_provider.dart` → `_initializeMockData()`

### Customize Navigation Items
In each screen's nav items list:
```dart
final List<NavigationItem> _navItems = [
  NavigationItem(label: 'Custom', icon: Icons.star, route: 'custom'),
];
```

---

## 📱 Running the App

```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

---

## 🚀 Next Steps

1. Replace mock data with real API calls
2. Implement user authentication with backend
3. Add push notifications
4. Integrate payment gateway
5. Add real-time job tracking
6. Implement chat/messaging
7. Add image upload for job completion
8. Integrate maps for navigation

---

## 📝 Notes

- All screens are fully functional with mock data
- QR scanning requires physical device (not emulator)
- Provider pattern allows easy state management
- GoRouter handles navigation and auth guards
- Responsive design works on all screen sizes

---

## 💡 Tips

1. Use **Hot Reload** (r) during development
2. Use **Hot Restart** (R) after Provider changes
3. Check console logs for navigation events
4. Mock data resets on app restart
5. Test on real devices for QR functionality

---

## 🤝 Support

For issues or questions:
1. Check the console for error messages
2. Verify all files are in correct locations
3. Ensure all dependencies are installed
4. Try `flutter clean` and rebuild

**Happy Coding! 🎉**