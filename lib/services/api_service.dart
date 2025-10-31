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
        print('Using existing visitor token: $existingToken');
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

        print('Using device serial: $deviceSerial');

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

      print('Registering device...');
      print('Device Serial being sent: ${deviceData["deviceSerial"]}');

      final requestBody = {
        "action": "deviceRegister",
        "deviceRegister": deviceData,
      };

      final response = await http.post(
        uri,
        headers: {
          'authToken': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Registration Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final visitorToken = data['data']['visitorToken'] as String?;

          if (visitorToken != null && visitorToken.isNotEmpty) {
            await _saveVisitorToken(visitorToken);
            print(
              'Device registered successfully. Visitor token: $visitorToken',
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
      print('Registration Error: $e');
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
      print('Error loading hotels: $e');
      return [];
    }
  }

  // API-based autocomplete for location search
  Future<List<Map<String, String>>> getAutocomplete(String query) async {
    try {
      if (query.trim().isEmpty || query.trim().length < 3) return [];

      final visitorToken = await getVisitorToken();
      if (visitorToken == null || visitorToken.isEmpty) {
        print('No visitor token found, registering device...');
        await registerDevice();
      }

      final uri = Uri.parse(baseUrl);

      final headers = {
        'authToken': authToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_visitorToken != null && _visitorToken!.isNotEmpty) {
        headers['visitorToken'] = _visitorToken!;
      }

      final requestBody = {
        "action": "searchAutoComplete",
        "searchAutoComplete": {
          "inputText": query,
          "searchType": ["byCity", "byState", "byCountry", "byPropertyName"],
          "limit": 10,
        },
      };

      print('Autocomplete Request: ${json.encode(requestBody)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Autocomplete Status: ${response.statusCode}');
      print('Autocomplete Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Map<String, String>> suggestions = [];

        if (data['status'] == true && data['data'] != null) {
          final autoCompleteData = data['data'];
          final autoCompleteList = autoCompleteData['autoCompleteList'];

          if (autoCompleteList != null) {
            // Parse byCity results
            if (autoCompleteList['byCity'] != null &&
                autoCompleteList['byCity']['present'] == true) {
              final cityResults =
                  autoCompleteList['byCity']['listOfResult'] as List? ?? [];
              for (var item in cityResults) {
                suggestions.add({
                  'name': item['valueToDisplay']?.toString() ?? '',
                  'type': 'city',
                  'state': item['address']?['state']?.toString() ?? '',
                  'country': item['address']?['country']?.toString() ?? 'India',
                });
              }
            }

            // Parse byState results
            if (autoCompleteList['byState'] != null &&
                autoCompleteList['byState']['present'] == true) {
              final stateResults =
                  autoCompleteList['byState']['listOfResult'] as List? ?? [];
              for (var item in stateResults) {
                suggestions.add({
                  'name': item['valueToDisplay']?.toString() ?? '',
                  'type': 'state',
                  'state': item['valueToDisplay']?.toString() ?? '',
                  'country': item['address']?['country']?.toString() ?? 'India',
                });
              }
            }

            // Parse byCountry results
            if (autoCompleteList['byCountry'] != null &&
                autoCompleteList['byCountry']['present'] == true) {
              final countryResults =
                  autoCompleteList['byCountry']['listOfResult'] as List? ?? [];
              for (var item in countryResults) {
                suggestions.add({
                  'name': item['valueToDisplay']?.toString() ?? '',
                  'type': 'country',
                  'state': '',
                  'country': item['valueToDisplay']?.toString() ?? '',
                });
              }
            }

            // Parse byPropertyName results
            if (autoCompleteList['byPropertyName'] != null &&
                autoCompleteList['byPropertyName']['present'] == true) {
              final propertyResults =
                  autoCompleteList['byPropertyName']['listOfResult'] as List? ??
                  [];
              for (var item in propertyResults) {
                suggestions.add({
                  'name': item['valueToDisplay']?.toString() ?? '',
                  'type': 'property',
                  'state': item['address']?['state']?.toString() ?? '',
                  'country': item['address']?['country']?.toString() ?? 'India',
                });
              }
            }
          }

          print('Got ${suggestions.length} autocomplete suggestions');
        }

        return suggestions;
      } else {
        print('Autocomplete API failed, using empty list');
        return [];
      }
    } catch (e) {
      print('Autocomplete Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> searchHotels({
    required String query,
    String? searchType,
    String? state,
    String? city,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final visitorToken = await getVisitorToken();
      if (visitorToken == null || visitorToken.isEmpty) {
        print('No visitor token found, registering device...');
        await registerDevice();
      }

      final uri = Uri.parse(baseUrl);

      print('API Request: $uri');
      print('Auth Token: $authToken');
      print('Visitor Token: ${_visitorToken ?? "None"}');

      final headers = {
        'authToken': authToken,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_visitorToken != null && _visitorToken!.isNotEmpty) {
        headers['visitorToken'] = _visitorToken!;
      }
      Map<String, String> searchInfo;
      if (searchType != null && state != null && city != null) {
        searchInfo = {
          'searchType': searchType,
          'country': 'India',
          'state': state,
          'city': city,
        };
      } else {
        searchInfo = _parseSearchQuery(query);
      }

      final requestBody = {
        "action": "popularStay",
        "popularStay": {
          "limit": perPage,
          "entityType": "Any",
          "filter": {
            "searchType": searchInfo['searchType'],
            "searchTypeInfo": {
              "country": searchInfo['country'],
              "state": searchInfo['state'],
              "city": searchInfo['city'],
            },
          },
          "currency": "INR",
        },
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Status Code: ${response.statusCode}');
      print(
        'Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Hotel> hotels = [];
        int total = 0;
        int totalPages = 1;

        if (data['status'] == true) {
          var hotelData = data['data'];

          if (hotelData is List) {
            hotels = hotelData
                .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
                .toList();
          }

          total = hotels.length;
          totalPages = (total / perPage).ceil();

          print('Parsed ${hotels.length} hotels successfully');
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
      print('API Error: $e');
      throw Exception('Error searching hotels: $e');
    }
  }

  Map<String, String> _parseSearchQuery(String query) {
    if (query.trim().isEmpty) {
      return {
        'searchType': 'byCity',
        'country': 'India',
        'state': 'Jharkhand',
        'city': 'Jamshedpur',
      };
    }

    final queryLower = query.toLowerCase().trim();

    final indianStates = [
      'andhra pradesh',
      'arunachal pradesh',
      'assam',
      'bihar',
      'chhattisgarh',
      'goa',
      'gujarat',
      'haryana',
      'himachal pradesh',
      'jharkhand',
      'karnataka',
      'kerala',
      'madhya pradesh',
      'maharashtra',
      'manipur',
      'meghalaya',
      'mizoram',
      'nagaland',
      'odisha',
      'punjab',
      'rajasthan',
      'sikkim',
      'tamil nadu',
      'telangana',
      'tripura',
      'uttar pradesh',
      'uttarakhand',
      'west bengal',
      'delhi',
      'puducherry',
      'jammu and kashmir',
      'ladakh',
    ];

    // If it's a state, search by state
    if (indianStates.contains(queryLower)) {
      return {
        'searchType': 'byState',
        'country': 'India',
        'state': _capitalizeWords(queryLower),
        'city': 'Any',
      };
    }

    // City to State mapping
    final cityToState = {
      'mumbai': 'Maharashtra',
      'pune': 'Maharashtra',
      'nagpur': 'Maharashtra',
      'nashik': 'Maharashtra',
      'aurangabad': 'Maharashtra',
      'delhi': 'Delhi',
      'new delhi': 'Delhi',
      'bangalore': 'Karnataka',
      'bengaluru': 'Karnataka',
      'mysore': 'Karnataka',
      'mangalore': 'Karnataka',
      'kolkata': 'West Bengal',
      'darjeeling': 'West Bengal',
      'chennai': 'Tamil Nadu',
      'madurai': 'Tamil Nadu',
      'coimbatore': 'Tamil Nadu',
      'hyderabad': 'Telangana',
      'ahmedabad': 'Gujarat',
      'surat': 'Gujarat',
      'vadodara': 'Gujarat',
      'jaipur': 'Rajasthan',
      'udaipur': 'Rajasthan',
      'jodhpur': 'Rajasthan',
      'ajmer': 'Rajasthan',
      'lucknow': 'Uttar Pradesh',
      'agra': 'Uttar Pradesh',
      'varanasi': 'Uttar Pradesh',
      'kanpur': 'Uttar Pradesh',
      'kochi': 'Kerala',
      'thiruvananthapuram': 'Kerala',
      'kozhikode': 'Kerala',
      'chandigarh': 'Chandigarh',
      'goa': 'Goa',
      'panaji': 'Goa',
      'shimla': 'Himachal Pradesh',
      'manali': 'Himachal Pradesh',
      'patna': 'Bihar',
      'bhopal': 'Madhya Pradesh',
      'indore': 'Madhya Pradesh',
      'ranchi': 'Jharkhand',
      'jamshedpur': 'Jharkhand',
      'guwahati': 'Assam',
      'bhubaneswar': 'Odisha',
      'puri': 'Odisha',
      'amritsar': 'Punjab',
      'ludhiana': 'Punjab',
      'srinagar': 'Jammu And Kashmir',
      'jammu': 'Jammu And Kashmir',
      'dehradun': 'Uttarakhand',
      'haridwar': 'Uttarakhand',
      'rishikesh': 'Uttarakhand',
      'nainital': 'Uttarakhand',
      'mussoorie': 'Uttarakhand',
    };

    // Get the state for the city, or use a default
    final state = cityToState[queryLower] ?? 'Maharashtra';

    return {
      'searchType': 'byCity',
      'country': 'India',
      'state': state,
      'city': _capitalizeWords(queryLower),
    };
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  // Fetch App Settings
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final uri = Uri.parse(baseUrl);

      print('Fetching App Settings...');

      final response = await http.post(
        uri,
        headers: {
          'authToken': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({"action": "setting"}),
      );

      print('App Settings Status: ${response.statusCode}');
      print('App Settings Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true && data['data'] != null) {
          print('App Settings fetched successfully');
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch app settings');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to fetch app settings: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('App Settings Error: $e');
      throw Exception('Error fetching app settings: $e');
    }
  }
}
