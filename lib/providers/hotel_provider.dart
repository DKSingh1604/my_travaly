import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/api_service.dart';

class HotelProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Hotel> _hotels = [];
  List<Hotel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  String _lastSearchQuery = '';

  List<Hotel> get hotels => _hotels;
  List<Hotel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMorePages => _currentPage < _totalPages;

  Future<void> loadSampleHotels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _hotels = await _apiService.getSampleHotels();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchHotels(String query, {bool resetPage = true}) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _currentPage = 1;
      _totalPages = 1;
      _lastSearchQuery = '';
      notifyListeners();
      return;
    }

    if (resetPage) {
      _currentPage = 1;
      _searchResults = [];
    }

    _isLoading = true;
    _errorMessage = null;
    _lastSearchQuery = query;
    notifyListeners();

    try {
      final result = await _apiService.searchHotels(
        query: query,
        page: _currentPage,
        perPage: 10,
      );

      if (resetPage) {
        _searchResults = result['hotels'] as List<Hotel>;
      } else {
        _searchResults.addAll(result['hotels'] as List<Hotel>);
      }

      _totalPages = result['totalPages'] as int;
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = _hotels.where((hotel) {
        final searchLower = query.toLowerCase();
        return hotel.name.toLowerCase().contains(searchLower) ||
            hotel.city.toLowerCase().contains(searchLower) ||
            hotel.state.toLowerCase().contains(searchLower) ||
            hotel.country.toLowerCase().contains(searchLower);
      }).toList();
      _totalPages = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (!hasMorePages || _isLoading) return;

    _currentPage++;
    await searchHotels(_lastSearchQuery, resetPage: false);
  }

  void resetSearch() {
    _searchResults = [];
    _currentPage = 1;
    _totalPages = 1;
    _lastSearchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }
}
