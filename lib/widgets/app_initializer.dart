import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/force_update_dialog.dart';
import '../screens/maintenance_mode_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

/// Initializes app settings and checks for force updates and maintenance mode
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isMaintenanceMode = false;
  bool _needsForceUpdate = false;
  String _updateTitle = '';
  String _updateMessage = '';
  String _storeLink = '';

  @override
  void initState() {
    super.initState();
    // Delay the API call until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppSettings();
    });
  }

  Future<void> _checkAppSettings() async {
    try {
      final appSettingsProvider = context.read<AppSettingsProvider>();
      await appSettingsProvider.fetchAppSettings();

      if (appSettingsProvider.settings != null) {
        final settings = appSettingsProvider.settings!;

        // Check maintenance mode
        if (settings.appMaintenanceMode) {
          setState(() {
            _isMaintenanceMode = true;
            _isLoading = false;
          });
          return;
        }

        // Check for force update
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        bool needsUpdate = false;
        String storeLink = '';

        if (Platform.isAndroid) {
          needsUpdate = appSettingsProvider.needsForceUpdateAndroid(
            currentVersion,
          );
          storeLink = settings.playStoreLink;
        } else if (Platform.isIOS) {
          needsUpdate = appSettingsProvider.needsForceUpdateIOS(currentVersion);
          storeLink = settings.appStoreLink;
        }

        if (needsUpdate) {
          setState(() {
            _needsForceUpdate = true;
            _updateTitle = settings.updateTitle;
            _updateMessage = settings.updateMessage;
            _storeLink = storeLink;
            _isLoading = false;
          });
          return;
        }
      }

      // All checks passed, proceed normally
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking app settings: $e');
      // On error, allow app to continue
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0EB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE86A4D)),
        ),
      );
    }

    if (_isMaintenanceMode) {
      return const MaintenanceModeScreen();
    }

    if (_needsForceUpdate) {
      // Show force update dialog overlay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ForceUpdateDialog(
            title: _updateTitle,
            message: _updateMessage,
            storeLink: _storeLink,
          ),
        );
      });
    }

    // Normal app flow
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
