import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_travaly/firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/hotel_provider.dart';
import 'providers/app_settings_provider.dart';
import 'services/api_service.dart';
import 'widgets/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  try {
    final apiService = ApiService();
    await apiService.registerDevice();
    print('✅ Device registration completed');
  } catch (e) {
    print('⚠️ Device registration failed: $e');
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
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: MaterialApp(
        title: 'MyTravaly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 2),
        ),
        home: const AppInitializer(),
      ),
    );
  }
}
