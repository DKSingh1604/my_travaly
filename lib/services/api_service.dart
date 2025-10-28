import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/hotel.dart';

class ApiService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';
  static const String _visitorTokenKey = 'visitor_token';

  String? _visitorToken;

  // Get stored visitor token
  Future<String?> getVisitorToken() async {
    if (_visitorToken != null) return _visitorToken;

    final prefs = await SharedPreferences.getInstance();
    _visitorToken = prefs.getString(_visitorTokenKey);
    return _visitorToken;
  }

  // Save visitor token
  Future<void> _saveVisitorToken(String token) async {
    _visitorToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_visitorTokenKey, token);
  }

  Future<String> registerDevice() async {
    try {
      final existingToken = await getVisitorToken();
      if (existingToken != null && existingToken.isNotEmpty) {
        print('✅ Using existing visitor token: $existingToken');
        return existingToken;
      }

      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;

        final serial = androidInfo.serialNumber;
        String deviceSerial;

        if (serial.isEmpty || serial.toLowerCase() == 'unknown') {
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          deviceSerial =
              '${androidInfo.brand.toUpperCase()}${timestamp.substring(timestamp.length - 10)}';
        } else {
          deviceSerial = serial;
        }

        print('🔢 Using device serial: $deviceSerial');

        deviceData = {
          "deviceModel": androidInfo.model,
          "deviceFingerprint": androidInfo.fingerprint,
          "deviceBrand": androidInfo.brand,
          "deviceId": androidInfo.id,
          "deviceName": androidInfo.device,
          "deviceManufacturer": androidInfo.manufacturer,
          "deviceProduct": androidInfo.product,
          "deviceSerialNumber": deviceSerial,
          "platformRelease": androidInfo.version.release,
          "platformSdk": androidInfo.version.sdkInt.toString(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          "deviceModel": iosInfo.model,
          "deviceFingerprint": iosInfo.identifierForVendor ?? iosInfo.name,
          "deviceBrand": "Apple",
          "deviceId": iosInfo.identifierForVendor ?? "unknown",
          "deviceName": iosInfo.name,
          "deviceManufacturer": "Apple",
          "deviceProduct": iosInfo.utsname.machine,
          "deviceSerialNumber": iosInfo.identifierForVendor ?? iosInfo.name,
          "platformRelease": iosInfo.systemVersion,
          "platformSdk": iosInfo.systemVersion,
        };
      } else {
        deviceData = {
          "deviceModel": "WebBrowser",
          "deviceFingerprint": "web-device",
          "deviceBrand": "Browser",
          "deviceId": "web-001",
          "deviceName": "WebDevice",
          "deviceManufacturer": "Browser",
          "deviceProduct": "Web",
          "deviceSerialNumber":
              "web-serial-${DateTime.now().millisecondsSinceEpoch}",
          "platformRelease": "Web",
          "platformSdk": "0",
        };
      }

      final uri = Uri.parse(baseUrl);

      print('🔐 Registering device...');
      print('📋 Device Serial being sent: ${deviceData["deviceSerial"]}');

      final requestBody = {
        "action": "deviceRegister",
        "deviceRegister": deviceData,
      };

      print('📤 Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        uri,
        headers: {
          'authToken': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 Registration Status Code: ${response.statusCode}');
      print('📄 Registration Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final visitorToken = data['data']['visitorToken'] as String?;

          if (visitorToken != null && visitorToken.isNotEmpty) {
            await _saveVisitorToken(visitorToken);
            print(
              '✅ Device registered successfully. Visitor token: $visitorToken',
            );
            return visitorToken;
          }
        }

        throw Exception('Invalid response format: No visitor token received');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to register device: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('💥 Registration Error: $e');
      throw Exception('Error registering device: $e');
    }
  }

  // Get popular hotels for home page
  Future<List<Hotel>> getSampleHotels() async {
    try {
      // Fetch popular hotels using the API
      final result = await searchHotels(query: 'hotel', page: 1, perPage: 10);
      return result['hotels'] as List<Hotel>;
    } catch (e) {
      print('💥 Error loading hotels: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> searchHotels({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      // Ensure device is registered and we have a visitor token
      final visitorToken = await getVisitorToken();
      if (visitorToken == null || visitorToken.isEmpty) {
        print('⚠️ No visitor token found, registering device...');
        await registerDevice();
      }

      // POST to base URL with action in body
      final uri = Uri.parse(baseUrl);

      print('🔍 API Request: $uri');
      print('🔑 Auth Token: $authToken');
      print('🎫 Visitor Token: ${_visitorToken ?? "None"}');

      final headers = {
        'authToken': authToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add visitor token if available
      if (_visitorToken != null && _visitorToken!.isNotEmpty) {
        headers['visitorToken'] = _visitorToken!;
      }

      // Request body with action
      final requestBody = {
        "action": "hotelList",
        if (query.trim().isNotEmpty) "search": query.trim(),
        "page": page,
        "limit": perPage,
      };

      print('📤 Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('📡 Status Code: ${response.statusCode}');
      print(
        '📄 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Hotel> hotels = [];
        int total = 0;
        int totalPages = 1;

        // Parse API response based on the structure you provided
        if (data['status'] == true) {
          var hotelData = data['data'];

          if (hotelData is List) {
            hotels = hotelData
                .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
                .toList();
          }

          total = hotels.length;
          totalPages = (total / perPage).ceil();

          print('✅ Parsed ${hotels.length} hotels successfully');
        }

        return {
          'hotels': hotels,
          'total': total,
          'page': page,
          'perPage': perPage,
          'totalPages': totalPages,
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to load hotels: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('💥 API Error: $e');
      throw Exception('Error searching hotels: $e');
    }
  }
}
