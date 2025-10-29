// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../providers/hotel_provider.dart';
import '../services/api_service.dart';
import '../widgets/hotel_card.dart';
import 'search_results_screen.dart';
import 'login_screen.dart';
import 'app_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ApiService _apiService = ApiService();
  List<Map<String, String>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus && _suggestions.isNotEmpty;
      });
    });

    _searchController.addListener(() {
      _onSearchChanged();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      hotelProvider.clearSearchError();
      hotelProvider.loadSampleHotels();
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAutocompleteSuggestions();
    });
  }

  Future<void> _fetchAutocompleteSuggestions() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final suggestions = await _apiService.getAutocomplete(query);
      setState(() {
        _suggestions = suggestions;
        _showSuggestions = _searchFocusNode.hasFocus && suggestions.isNotEmpty;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      print('Error fetching autocomplete: $e');
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'city':
        return '🏙️';
      case 'state':
        return '📍';
      case 'country':
        return '🌏';
      case 'property':
        return '🏨';
      default:
        return '📌';
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SearchResultsScreen(query: query)),
      );
    }
  }

  Future<void> _handleSignOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _goQuick(String query) {
    _searchFocusNode.unfocus();
    setState(() {
      _searchController.text = query;
      _showSuggestions = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'MyTravaly',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (authProvider.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  if (authProvider.user!.photoURL != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        authProvider.user!.photoURL!,
                      ),
                      radius: 16,
                    )
                  else
                    const CircleAvatar(child: Icon(Icons.person), radius: 16),
                  const SizedBox(width: 8),
                  Text(
                    authProvider.user!.displayName?.split(' ').first ?? 'User',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header + Search with Autocomplete
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFE86A4D), const Color(0xFFD85840)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Find your next stay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Search field with shadow
                  Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search by city, state or hotel…',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _suggestions = [];
                                      _showSuggestions = false;
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (query) {
                          if (query.isNotEmpty) {
                            _searchFocusNode.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SearchResultsScreen(query: query),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  // Suggestions List
                  if (_showSuggestions)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: _isLoadingSuggestions
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                final icon = _getIconForType(
                                  suggestion['type'] ?? 'city',
                                );

                                return ListTile(
                                  leading: Text(
                                    icon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  title: Text(
                                    suggestion['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${suggestion['type']}${suggestion['state']?.isNotEmpty == true ? ' • ${suggestion['state']}' : ''}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.black54,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _searchController.text =
                                          suggestion['name']!;
                                      _showSuggestions = false;
                                    });
                                    _searchFocusNode.unfocus();

                                    String searchType;
                                    String city = 'Any';
                                    String state = suggestion['state'] ?? 'Any';

                                    switch (suggestion['type']?.toLowerCase()) {
                                      case 'city':
                                        searchType = 'byCity';
                                        city = suggestion['name']!;
                                        break;
                                      case 'state':
                                        searchType = 'byState';
                                        state = suggestion['name']!;
                                        break;
                                      case 'country':
                                        searchType = 'byCountry';
                                        break;
                                      case 'property':
                                        searchType = 'byCity';
                                        city = suggestion['name']!;
                                        break;
                                      default:
                                        searchType = 'byCity';
                                        city = suggestion['name']!;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchResultsScreen(
                                              query: suggestion['name']!,
                                              searchType: searchType,
                                              state: state,
                                              city: city,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  const SizedBox(height: 12),
                  // Quick filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickChip(
                          label: 'Mumbai',
                          onTap: () => _goQuick('Mumbai'),
                        ),
                        _QuickChip(
                          label: 'Delhi',
                          onTap: () => _goQuick('Delhi'),
                        ),
                        _QuickChip(label: 'Goa', onTap: () => _goQuick('Goa')),
                        _QuickChip(
                          label: 'Nainital',
                          onTap: () => _goQuick('Nainital'),
                        ),
                        _QuickChip(
                          label: 'Jaipur',
                          onTap: () => _goQuick('Jaipur'),
                        ),
                        _QuickChip(
                          label: 'Shimla',
                          onTap: () => _goQuick('Shimla'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hotels List
          Expanded(
            child: hotelProvider.isLoading && hotelProvider.hotels.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : hotelProvider.hotels.isEmpty
                ? const Center(
                    child: Text(
                      'No hotels available',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => hotelProvider.loadSampleHotels(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: hotelProvider.hotels.length,
                      itemBuilder: (context, index) {
                        return HotelCard(hotel: hotelProvider.hotels[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _searchController.text.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _performSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            )
          : null,
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.place_rounded,
                size: 16,
                color: Color(0xFFE86A4D),
              ),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
