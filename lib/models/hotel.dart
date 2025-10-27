class Hotel {
  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String? imageUrl;
  final String? description;
  final double? rating;
  final double? price;
  final int? stars;
  final String? propertyType;
  final String? zipcode;
  final String? street;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    this.imageUrl,
    this.description,
    this.rating,
    this.price,
    this.stars,
    this.propertyType,
    this.zipcode,
    this.street,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Extract address data
    final address = json['propertyAddress'] ?? {};

    // Extract review data
    final googleReview = json['googleReview']?['data'];
    final rating = googleReview?['overallRating']?.toDouble();

    // Extract price data
    final staticPrice = json['staticPrice'];
    final price = staticPrice?['amount']?.toDouble();

    return Hotel(
      id: json['propertyCode']?.toString() ?? '',
      name: json['propertyName'] ?? '',
      city: address['city'] ?? '',
      state: address['state'] ?? '',
      country: address['country'] ?? '',
      imageUrl: json['propertyImage'],
      description: address['street'],
      rating: rating,
      price: price,
      stars: json['propertyStar'],
      propertyType: json['propertyType'],
      zipcode: address['zipcode'],
      street: address['street'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'state': state,
      'country': country,
      'image_url': imageUrl,
      'description': description,
      'rating': rating,
      'price': price,
      'stars': stars,
      'propertyType': propertyType,
    };
  }
}
