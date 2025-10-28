class LocationService {
  static final List<Map<String, String>> _locations = [
    // Major Cities
    {'name': 'Mumbai', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Delhi', 'type': 'city', 'state': 'Delhi'},
    {'name': 'Bangalore', 'type': 'city', 'state': 'Karnataka'},
    {'name': 'Hyderabad', 'type': 'city', 'state': 'Telangana'},
    {'name': 'Chennai', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Kolkata', 'type': 'city', 'state': 'West Bengal'},
    {'name': 'Pune', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Ahmedabad', 'type': 'city', 'state': 'Gujarat'},
    {'name': 'Jaipur', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Surat', 'type': 'city', 'state': 'Gujarat'},
    {'name': 'Lucknow', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Kanpur', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Nagpur', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Indore', 'type': 'city', 'state': 'Madhya Pradesh'},
    {'name': 'Thane', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Bhopal', 'type': 'city', 'state': 'Madhya Pradesh'},
    {'name': 'Visakhapatnam', 'type': 'city', 'state': 'Andhra Pradesh'},
    {'name': 'Pimpri-Chinchwad', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Patna', 'type': 'city', 'state': 'Bihar'},
    {'name': 'Vadodara', 'type': 'city', 'state': 'Gujarat'},
    {'name': 'Ghaziabad', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Ludhiana', 'type': 'city', 'state': 'Punjab'},
    {'name': 'Agra', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Nashik', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Faridabad', 'type': 'city', 'state': 'Haryana'},
    {'name': 'Meerut', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Rajkot', 'type': 'city', 'state': 'Gujarat'},
    {'name': 'Varanasi', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Srinagar', 'type': 'city', 'state': 'Jammu and Kashmir'},
    {'name': 'Amritsar', 'type': 'city', 'state': 'Punjab'},
    {'name': 'Allahabad', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Ranchi', 'type': 'city', 'state': 'Jharkhand'},
    {'name': 'Howrah', 'type': 'city', 'state': 'West Bengal'},
    {'name': 'Coimbatore', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Jabalpur', 'type': 'city', 'state': 'Madhya Pradesh'},
    {'name': 'Gwalior', 'type': 'city', 'state': 'Madhya Pradesh'},
    {'name': 'Vijayawada', 'type': 'city', 'state': 'Andhra Pradesh'},
    {'name': 'Jodhpur', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Madurai', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Raipur', 'type': 'city', 'state': 'Chhattisgarh'},
    {'name': 'Kota', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Chandigarh', 'type': 'city', 'state': 'Chandigarh'},
    {'name': 'Guwahati', 'type': 'city', 'state': 'Assam'},
    {'name': 'Mysore', 'type': 'city', 'state': 'Karnataka'},
    {'name': 'Bareilly', 'type': 'city', 'state': 'Uttar Pradesh'},
    {'name': 'Goa', 'type': 'city', 'state': 'Goa'},
    {'name': 'Jamshedpur', 'type': 'city', 'state': 'Jharkhand'},
    {'name': 'Udaipur', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Shimla', 'type': 'city', 'state': 'Himachal Pradesh'},
    {'name': 'Manali', 'type': 'city', 'state': 'Himachal Pradesh'},
    {'name': 'Nainital', 'type': 'city', 'state': 'Uttarakhand'},
    {'name': 'Darjeeling', 'type': 'city', 'state': 'West Bengal'},
    {'name': 'Ooty', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Pondicherry', 'type': 'city', 'state': 'Puducherry'},
    {'name': 'Gangtok', 'type': 'city', 'state': 'Sikkim'},
    {'name': 'Leh', 'type': 'city', 'state': 'Ladakh'},
    {'name': 'Munnar', 'type': 'city', 'state': 'Kerala'},
    {'name': 'Kochi', 'type': 'city', 'state': 'Kerala'},
    {'name': 'Trivandrum', 'type': 'city', 'state': 'Kerala'},
    {'name': 'Rishikesh', 'type': 'city', 'state': 'Uttarakhand'},
    {'name': 'Haridwar', 'type': 'city', 'state': 'Uttarakhand'},
    {'name': 'Dehradun', 'type': 'city', 'state': 'Uttarakhand'},
    {'name': 'Mussoorie', 'type': 'city', 'state': 'Uttarakhand'},
    {'name': 'Mount Abu', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Pushkar', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Ajmer', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Bikaner', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Jaisalmer', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Ranthambore', 'type': 'city', 'state': 'Rajasthan'},
    {'name': 'Alibaug', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Lonavala', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Mahabaleshwar', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Aurangabad', 'type': 'city', 'state': 'Maharashtra'},
    {'name': 'Hampi', 'type': 'city', 'state': 'Karnataka'},
    {'name': 'Mangalore', 'type': 'city', 'state': 'Karnataka'},
    {'name': 'Coorg', 'type': 'city', 'state': 'Karnataka'},
    {'name': 'Wayanad', 'type': 'city', 'state': 'Kerala'},
    {'name': 'Alleppey', 'type': 'city', 'state': 'Kerala'},
    {'name': 'Kodaikanal', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Mahabalipuram', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Rameshwaram', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Kanyakumari', 'type': 'city', 'state': 'Tamil Nadu'},
    {'name': 'Port Blair', 'type': 'city', 'state': 'Andaman and Nicobar'},
    {'name': 'Dispur', 'type': 'city', 'state': 'Assam'},
    {'name': 'Shillong', 'type': 'city', 'state': 'Meghalaya'},
    {'name': 'Imphal', 'type': 'city', 'state': 'Manipur'},
    {'name': 'Aizawl', 'type': 'city', 'state': 'Mizoram'},
    {'name': 'Kohima', 'type': 'city', 'state': 'Nagaland'},
    {'name': 'Itanagar', 'type': 'city', 'state': 'Arunachal Pradesh'},
    {'name': 'Agartala', 'type': 'city', 'state': 'Tripura'},

    // All Indian States
    {'name': 'Andhra Pradesh', 'type': 'state', 'state': 'Andhra Pradesh'},
    {
      'name': 'Arunachal Pradesh',
      'type': 'state',
      'state': 'Arunachal Pradesh',
    },
    {'name': 'Assam', 'type': 'state', 'state': 'Assam'},
    {'name': 'Bihar', 'type': 'state', 'state': 'Bihar'},
    {'name': 'Chhattisgarh', 'type': 'state', 'state': 'Chhattisgarh'},
    {'name': 'Goa', 'type': 'state', 'state': 'Goa'},
    {'name': 'Gujarat', 'type': 'state', 'state': 'Gujarat'},
    {'name': 'Haryana', 'type': 'state', 'state': 'Haryana'},
    {'name': 'Himachal Pradesh', 'type': 'state', 'state': 'Himachal Pradesh'},
    {'name': 'Jharkhand', 'type': 'state', 'state': 'Jharkhand'},
    {'name': 'Karnataka', 'type': 'state', 'state': 'Karnataka'},
    {'name': 'Kerala', 'type': 'state', 'state': 'Kerala'},
    {'name': 'Madhya Pradesh', 'type': 'state', 'state': 'Madhya Pradesh'},
    {'name': 'Maharashtra', 'type': 'state', 'state': 'Maharashtra'},
    {'name': 'Manipur', 'type': 'state', 'state': 'Manipur'},
    {'name': 'Meghalaya', 'type': 'state', 'state': 'Meghalaya'},
    {'name': 'Mizoram', 'type': 'state', 'state': 'Mizoram'},
    {'name': 'Nagaland', 'type': 'state', 'state': 'Nagaland'},
    {'name': 'Odisha', 'type': 'state', 'state': 'Odisha'},
    {'name': 'Punjab', 'type': 'state', 'state': 'Punjab'},
    {'name': 'Rajasthan', 'type': 'state', 'state': 'Rajasthan'},
    {'name': 'Sikkim', 'type': 'state', 'state': 'Sikkim'},
    {'name': 'Tamil Nadu', 'type': 'state', 'state': 'Tamil Nadu'},
    {'name': 'Telangana', 'type': 'state', 'state': 'Telangana'},
    {'name': 'Tripura', 'type': 'state', 'state': 'Tripura'},
    {'name': 'Uttar Pradesh', 'type': 'state', 'state': 'Uttar Pradesh'},
    {'name': 'Uttarakhand', 'type': 'state', 'state': 'Uttarakhand'},
    {'name': 'West Bengal', 'type': 'state', 'state': 'West Bengal'},
    {'name': 'Delhi', 'type': 'state', 'state': 'Delhi'},
    {'name': 'Puducherry', 'type': 'state', 'state': 'Puducherry'},
    {
      'name': 'Jammu and Kashmir',
      'type': 'state',
      'state': 'Jammu and Kashmir',
    },
    {'name': 'Ladakh', 'type': 'state', 'state': 'Ladakh'},
    {'name': 'Chandigarh', 'type': 'state', 'state': 'Chandigarh'},
    {
      'name': 'Andaman and Nicobar',
      'type': 'state',
      'state': 'Andaman and Nicobar',
    },

    // Country
    {'name': 'India', 'type': 'country', 'state': ''},
  ];

  /// Get location suggestions based on user input
  /// Returns up to 10 matching locations
  static List<Map<String, String>> getSuggestions(String query) {
    if (query.trim().isEmpty) return [];

    final queryLower = query.toLowerCase().trim();

    // Filter locations that contain the query string
    final matches = _locations.where((location) {
      final nameLower = location['name']!.toLowerCase();
      return nameLower.contains(queryLower) || nameLower.startsWith(queryLower);
    }).toList();

    // Sort by relevance: exact matches first, then starts-with, then contains
    matches.sort((a, b) {
      final aName = a['name']!.toLowerCase();
      final bName = b['name']!.toLowerCase();

      // Exact match
      if (aName == queryLower) return -1;
      if (bName == queryLower) return 1;

      // Starts with
      final aStarts = aName.startsWith(queryLower);
      final bStarts = bName.startsWith(queryLower);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      // Alphabetical
      return aName.compareTo(bName);
    });

    // Return top 10 suggestions
    return matches.take(10).toList();
  }

  /// Get icon for location type
  static String getIconForType(String type) {
    switch (type) {
      case 'city':
        return '🏙️';
      case 'state':
        return '📍';
      case 'country':
        return '🌏';
      default:
        return '📌';
    }
  }
}
