import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../services/api_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AppSettings? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  AppSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch app settings from API
  Future<void> fetchAppSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getAppSettings();
      _settings = AppSettings.fromJson(data);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _settings = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if app needs force update (Android)
  bool needsForceUpdateAndroid(String currentVersion) {
    if (_settings == null) return false;
    if (!_settings!.appAndroidForceUpdate) return false;

    return _compareVersions(currentVersion, _settings!.appAndroidVersion) < 0;
  }

  // Check if app needs force update (iOS)
  bool needsForceUpdateIOS(String currentVersion) {
    if (_settings == null) return false;
    if (!_settings!.appIosForceUpdate) return false;

    return _compareVersions(currentVersion, _settings!.appIosVersion) < 0;
  }

  // Compare version strings (e.g., "2.0.2" vs "2.0.3")
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return parts1.length.compareTo(parts2.length);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
