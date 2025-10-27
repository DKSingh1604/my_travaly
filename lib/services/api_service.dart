import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

class ApiService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';

  Future<Map<String, dynamic>> searchHotels({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/hotels/search').replace(
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'auth-token': authToken,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Hotel> hotels = [];
        if (data['data'] != null) {
          if (data['data'] is List) {
            hotels = (data['data'] as List)
                .map((json) => Hotel.fromJson(json))
                .toList();
          }
        } else if (data['hotels'] != null) {
          hotels = (data['hotels'] as List)
              .map((json) => Hotel.fromJson(json))
              .toList();
        }

        return {
          'hotels': hotels,
          'total': data['total'] ?? hotels.length,
          'page': data['page'] ?? page,
          'perPage': data['per_page'] ?? perPage,
          'totalPages': data['total_pages'] ?? 1,
        };
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching hotels: $e');
    }
  }

  Future<List<Hotel>> getSampleHotels() async {
    return [
      Hotel(
        id: '1',
        name: 'Grand Hotel Mumbai',
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
        description: 'Luxury hotel in the heart of Mumbai',
        rating: 4.5,
        price: 5000,
      ),
      Hotel(
        id: '2',
        name: 'Royal Palace Delhi',
        city: 'Delhi',
        state: 'Delhi',
        country: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400',
        description: 'Experience royalty in the capital',
        rating: 4.8,
        price: 7000,
      ),
      Hotel(
        id: '3',
        name: 'Beach Resort Goa',
        city: 'Goa',
        state: 'Goa',
        country: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
        description: 'Beachfront paradise',
        rating: 4.6,
        price: 4500,
      ),
      Hotel(
        id: '4',
        name: 'Heritage Inn Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
        country: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
        description: 'Traditional Rajasthani hospitality',
        rating: 4.4,
        price: 3500,
      ),
      Hotel(
        id: '5',
        name: 'Lake View Udaipur',
        city: 'Udaipur',
        state: 'Rajasthan',
        country: 'India',
        imageUrl:
            'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400',
        description: 'Scenic views of Lake Pichola',
        rating: 4.7,
        price: 6000,
      ),
    ];
  }
}
