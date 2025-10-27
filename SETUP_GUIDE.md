# MyTravaly - Hotel Booking App

A Flutter application for browsing and searching hotels with Google Sign-In authentication.

## Features

- ✅ **Google Sign-In/Sign-Up** - Frontend implementation with Firebase Authentication
- ✅ **Home Page** - Display sample hotels with search functionality
- ✅ **Search Results** - API-integrated search with pagination
- ✅ **Beautiful UI** - Modern Material Design 3 interface
- ✅ **State Management** - Provider pattern for clean architecture

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── hotel.dart              # Hotel data model
├── services/
│   ├── api_service.dart        # API integration
│   └── auth_service.dart       # Google authentication
├── providers/
│   ├── auth_provider.dart      # Auth state management
│   └── hotel_provider.dart     # Hotel data management
├── screens/
│   ├── login_screen.dart       # Page 1: Google Sign In
│   ├── home_screen.dart        # Page 2: Hotel List
│   └── search_results_screen.dart  # Page 3: Search Results
└── widgets/
    └── hotel_card.dart         # Reusable hotel card widget
```

## Setup Instructions

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup (Required for Google Sign-In)

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or select existing project
3. Follow the setup wizard

#### B. Enable Google Sign-In

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Google** sign-in provider
3. Add support email

#### C. Android Configuration

1. In Firebase Console, click on Android icon to add Android app
2. Enter package name: `com.example.my_travaly`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

**Note:** The package name must match the one in `android/app/build.gradle.kts`

To get SHA-1 certificate fingerprint (needed for Google Sign-In):
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 from the debug certificate and add it to Firebase Console.

#### D. iOS Configuration

1. In Firebase Console, click on iOS icon to add iOS app
2. Enter iOS bundle ID: `com.example.myTravaly`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder (make sure "Copy items if needed" is checked)

**Note:** To find your iOS bundle ID:
```bash
cat ios/Runner.xcodeproj/project.pbxproj | grep PRODUCT_BUNDLE_IDENTIFIER
```

### 3. Run the Application

```bash
# Run on Android
flutter run

# Or run on iOS
flutter run -d ios

# Or run on web (limited Google Sign-In support)
flutter run -d chrome
```

## API Information

- **Base URL:** `https://api.mytravaly.com/public/v1/`
- **Auth Token:** `71523fdd8d26f585315b4233e39d9263`
- **Documentation:** Available on Postman

The app uses the provided API for searching hotels. If the API is unavailable, it falls back to displaying filtered sample data.

## Key Features Explained

### Page 1 - Login Screen
- Beautiful gradient UI with Google Sign-In button
- Firebase Authentication integration
- Error handling with user feedback
- Auto-navigation to home on successful sign-in

### Page 2 - Home Screen
- Displays sample hotel list
- Search bar for querying hotels
- User profile display with sign-out option
- Pull-to-refresh functionality
- Floating action button for quick search

### Page 3 - Search Results
- Real-time API search integration
- Pagination support (loads more on scroll)
- Results count and page indicator
- Fallback to filtered sample data if API fails
- Empty state and error handling

### Hotel Card Widget
- Cached network images for performance
- Displays hotel details (name, location, rating, price)
- Tap to view detailed modal with booking option
- Beautiful card design with shadows and rounded corners

## Dependencies Used

```yaml
dependencies:
  # Google Sign In
  google_sign_in: ^6.2.1
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  
  # HTTP requests
  http: ^1.2.2
  
  # State Management
  provider: ^6.1.2
  
  # Storage
  shared_preferences: ^2.3.2
  
  # UI Components
  cached_network_image: ^3.4.1
```

## Troubleshooting

### Google Sign-In not working on Android
1. Make sure `google-services.json` is in `android/app/`
2. Verify SHA-1 certificate is added in Firebase Console
3. Check package name matches in Firebase and `build.gradle.kts`
4. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   cd .. && flutter run
   ```

### Google Sign-In not working on iOS
1. Make sure `GoogleService-Info.plist` is added to Xcode project
2. Verify bundle ID matches in Firebase and Xcode
3. Clean and rebuild:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install
   cd .. && flutter run
   ```

### API not responding
- The app has fallback sample data that will be displayed
- Check internet connection
- Verify auth token is correct

## Development Notes

### State Management
The app uses Provider for state management with two main providers:
- `AuthProvider`: Manages authentication state
- `HotelProvider`: Manages hotel data and search results

### Error Handling
- All API calls have try-catch blocks
- User-friendly error messages
- Fallback data for better UX
- Loading indicators during async operations

### Pagination
The search results screen implements infinite scroll pagination:
- Loads 10 results per page
- Automatically loads next page when scrolling near bottom
- Shows loading indicator while fetching

### Image Caching
Uses `cached_network_image` package for:
- Better performance
- Reduced network usage
- Placeholder and error widgets

## Next Steps for Production

1. **Backend Integration**
   - Replace sample data with real API calls
   - Implement proper error handling for all API endpoints
   
2. **Security**
   - Store API tokens securely
   - Implement token refresh mechanism
   - Add request signing

3. **Features**
   - Implement actual booking functionality
   - Add favorites/wishlist
   - Hotel details page with reviews
   - Filter and sort options
   - Date picker for check-in/out
   
4. **Testing**
   - Add unit tests
   - Widget tests
   - Integration tests

5. **Performance**
   - Implement lazy loading
   - Optimize images
   - Add offline support

## License

This project is created for demonstration purposes.

---

**Built with ❤️ using Flutter**
