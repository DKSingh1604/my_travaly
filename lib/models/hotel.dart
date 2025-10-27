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
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      description: json['description'],
      rating: json['rating']?.toDouble(),
      price: json['price']?.toDouble(),
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
    };
  }
}
