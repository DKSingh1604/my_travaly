// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hotel_provider.dart';
import '../widgets/hotel_card.dart';
import 'search_results_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelProvider = Provider.of<HotelProvider>(context, listen: false);
      hotelProvider.clearSearchError();
      hotelProvider.loadSampleHotels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTravaly'),
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
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.blue.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by hotel name, city, state, or country...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) => setState(() {}),
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
