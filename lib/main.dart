import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_travaly/firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hotel_provider.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Register device and get visitor token
  try {
    final apiService = ApiService();
    await apiService.registerDevice();
    print('✅ Device registration completed');
  } catch (e) {
    print('⚠️ Device registration failed: $e');
    // Continue anyway - the app will try to register again when making API calls
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
      ],
      child: MaterialApp(
        title: 'MyTravaly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 2),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Check if user is already signed in
            if (authProvider.isAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
